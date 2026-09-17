function prediction = classify_dr(img, net, lesionStats, options)
% CLASSIFY_DR Multi-class Diabetic Retinopathy severity grading (Grades 0 to 4)
% and calibrated binary triage for rural tele-ophthalmology screening.
%
% Grades:
%   Grade 0: No Diabetic Retinopathy (Normal)
%   Grade 1: Mild NPDR (Microaneurysms only)
%   Grade 2: Moderate NPDR (Microaneurysms + dot hemorrhages + early exudates)
%   Grade 3: Severe NPDR (Extensive blot hemorrhages + cotton wool spots)
%   Grade 4: Proliferative DR (PDR: Neovascularization + heavy exudation)
%
% Clinical Triage:
%   - Non-Referable DR: Grade 0 - 1 (Clear at PHC level, annual routine rescreen)
%   - Referable DR:     Grade 2 - 4 (Urgent specialist consultation required)
%
% Benchmark Target: Sensitivity > 90%, Specificity > 85% for Referable DR
%
% Syntax:
%   prediction = classify_dr(img)
%   prediction = classify_dr(img, net)
%   prediction = classify_dr(img, net, lesionStats)
%   prediction = classify_dr(img, net, lesionStats, options)
%
% Outputs:
%   prediction - Struct containing:
%                .grade           : Integer [0, 4]
%                .gradeName       : Clinical label string
%                .probabilities   : 1x5 array of class probabilities [P0, P1, P2, P3, P4]
%                .isReferable     : Boolean flag (true if Level 2+)
%                .referableScore  : Cumulative risk probability P(Grade >= 2)
%                .referralUrgency : 'ROUTINE ANNUAL', 'REFERRAL 30-DAYS', or 'URGENT 48-HOURS'
%                .confidence      : Confidence score of predicted grade
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 2, net = []; end
    if nargin < 3, lesionStats = []; end
    if nargin < 4, options = struct(); end

    if ~isfield(options, 'referableThreshold')
        options.referableThreshold = [];
    end

    classNames = {
        'No DR (Normal)', ...
        'Mild NPDR', ...
        'Moderate NPDR', ...
        'Severe NPDR', ...
        'Proliferative DR'
    };

    % Prepare image for ResNet-50 (Resize to 224x224x3 uint8)
    if isa(img, 'double')
        img255 = uint8(img * 255.0);
    else
        img255 = uint8(img);
    end
    if size(img255, 3) == 1
        img255 = repmat(img255, [1, 1, 3]);
    end
    imgResized = imresize(img255, [224, 224]);

    % ---------------------------------------------------------------------
    % Deep Learning / ResNet-50 Feature & Prediction Engine
    % ---------------------------------------------------------------------
    hasDeepNet = false;
    probsNet = zeros(1, 5);

    % Auto-load trained weights and multimodal model if available
    persistent cachedNet cachedSVM cachedTh
    if isempty(cachedNet)
        weightsFile = fullfile(fileparts(mfilename('fullpath')), 'trained_dr_resnet50.mat');
        if exist(weightsFile, 'file')
            try
                loadedData = load(weightsFile);
                if isfield(loadedData, 'trainedNet')
                    cachedNet = loadedData.trainedNet;
                end
                if isfield(loadedData, 'svmMdl')
                    cachedSVM = loadedData.svmMdl;
                end
                if isfield(loadedData, 'th')
                    cachedTh = loadedData.th;
                end
            catch
            end
        end
        if isempty(cachedTh)
            cachedTh = 0.6487;
        end
    end

    if isempty(net)
        net = cachedNet;
    end
    svmMdl = cachedSVM;
    svmTh = cachedTh;
    if isempty(svmTh)
        svmTh = 0.6487;
    end
    if isempty(options.referableThreshold)
        options.referableThreshold = svmTh;
    end

    imgNet = [];
    featTTA = [];
    if ~isempty(net)
        try
            if isa(net, 'DAGNetwork') || isa(net, 'SeriesNetwork') || isa(net, 'dlnetwork')
                inputSize = [227, 227];
                try
                    inputSize = net.Layers(1).InputSize(1:2);
                catch
                end
                
                % Apply Ben Graham contrast normalization if not already preprocessed / 224x224
                if (size(img255, 1) == inputSize(1) && size(img255, 2) == inputSize(2)) || ...
                   (isfield(options, 'preprocessed') && options.preprocessed)
                    imgNorm = img255;
                else
                    try
                        imgNorm = preprocess_fundus_bengraham(img255, inputSize, 10);
                    catch
                        imgNorm = imresize(img255, inputSize);
                    end
                end
                imgNet = imgNorm;
                
                % Auto-detect global pooling layer (SqueezeNet=pool10, ResNet-50/DenseNet=avg_pool)
                poolLayerName = 'pool10';
                try
                    layerNames = {net.Layers.Name};
                    if any(strcmp(layerNames, 'avg_pool'))
                        poolLayerName = 'avg_pool';
                    elseif any(strcmp(layerNames, 'pool5'))
                        poolLayerName = 'pool5';
                    end
                catch
                end
                
                % Default to 4-View Test-Time Augmentation (TTA) for rotation/angle invariance on unseen images
                useTTA = true;
                if isfield(options, 'useTTA')
                    useTTA = options.useTTA;
                end
                
                if useTTA
                    % 4-View Test-Time Augmentation (TTA: 0°, Flip-H, Flip-V, 180°)
                    v1 = imgNorm;
                    v2 = fliplr(imgNorm);
                    v3 = flipud(imgNorm);
                    v4 = rot90(imgNorm, 2);
                    
                    batchTTA = cat(4, v1, v2, v3, v4);
                    if isfield(options, 'useSVM') && options.useSVM
                        featsAll = activations(net, batchTTA, poolLayerName, 'OutputAs', 'rows');
                        featTTA = mean(featsAll, 1);
                    end
                    
                    pBase = predict(net, batchTTA);
                    rawProbs = mean(pBase, 1);
                else
                    % Single-pass forward inference (Fast batch execution)
                    if isfield(options, 'useSVM') && options.useSVM
                        featTTA = activations(net, imgNorm, poolLayerName, 'OutputAs', 'rows');
                    end
                    rawProbs = predict(net, imgNorm);
                end
                
                if numel(rawProbs) == 5
                    probsNet = double(rawProbs(:))';
                    hasDeepNet = true;
                end
            end
        catch
            hasDeepNet = false;
        end
    end

    % Clinically Grounded Multimodal Fusion (MathWorks PS 26038):
    % When optical lesion evidence is available, integrate deep CNN representations with
    % direct physical biomarker counts (microaneurysms, hemorrhages, hard exudates).
    if ~isempty(lesionStats) && isstruct(lesionStats) && ...
       (lesionStats.microaneurysmCount > 0 || lesionStats.hemorrhageCount > 0 || lesionStats.exudateArea > 0)
        probsBiomarker = compute_biomarker_probabilities(img255, lesionStats);
        if hasDeepNet
            netWeight = 0.80; % 80% Deep Residual CNN + 20% Direct Optical Lesion Evidence
            if isfield(options, 'netWeight')
                netWeight = options.netWeight;
            end
            probsNet = netWeight * probsNet + (1.0 - netWeight) * probsBiomarker;
        else
            probsNet = probsBiomarker;
        end
    end

    % Normalize probability distribution
    probs = probsNet / sum(probsNet);

    % Determine predicted grade
    [confidence, predIdx] = max(probs);
    grade = predIdx - 1; % 0-indexed [0, 4]

    % Referable DR Decision
    useSVM = isfield(options, 'useSVM') && options.useSVM;
    if hasDeepNet && useSVM && ~isempty(svmMdl) && ~isempty(featTTA)
        try
            if size(svmMdl.SupportVectors, 2) == size(featTTA, 2)
                [~, sScores] = predict(svmMdl, featTTA);
            else
                xMulti = [featTTA, log1p(lesionStats.exudateArea), log1p(lesionStats.exudateCount), ...
                          log1p(lesionStats.microaneurysmCount), lesionStats.hemorrhageCount];
                [~, sScores] = predict(svmMdl, xMulti);
            end
            svmDecision = sScores(2);
            
            % Sigmoid-calibrated risk probability
            referableScore = 1.0 / (1.0 + exp(-2.0 * (svmDecision - svmTh)));
            isReferable = (svmDecision >= svmTh);
            
            % Harmonize grade with referable decision
            if isReferable && grade < 2
                grade = 2;
            elseif ~isReferable && grade >= 2
                grade = 1;
            end
            confidence = probs(grade + 1);
        catch
            referableScore = sum(probs(3:5));
            th = options.referableThreshold;
            if isempty(th), th = 0.6487; end
            isReferable = (referableScore >= th);
            if isReferable && grade < 2
                grade = 2;
            elseif ~isReferable && grade >= 2
                grade = 1;
            end
            confidence = probs(grade + 1);
        end
    else
        referableScore = sum(probs(3:5));
        th = options.referableThreshold;
        if isempty(th), th = 0.6487; end
        isReferable = (referableScore >= th);
        if isReferable && grade < 2
            grade = 2;
        elseif ~isReferable && grade >= 2
            grade = 1;
        end
        confidence = probs(grade + 1);
    end

    % Clinical Referral Urgency Tier
    if grade >= 4
        referralUrgency = 'URGENT 48-HOURS (Tertiary Vitreoretinal Care)';
    elseif grade == 3
        referralUrgency = 'HIGH RISK 14-DAYS (Specialist Ophthalmology Evaluation)';
    elseif grade == 2
        referralUrgency = 'REFERRAL 30-DAYS (Secondary Ophthalmology Clinic)';
    elseif grade == 1
        referralUrgency = 'PHC MONITORING (Non-Referable, Rescreen in 6-12 mo)';
    else
        referralUrgency = 'ROUTINE ANNUAL (Primary Health Centre Rescreen)';
    end

    % Package output struct
    prediction.grade           = grade;
    prediction.gradeName       = classNames{grade + 1};
    prediction.probabilities   = probs;
    prediction.isReferable     = isReferable;
    prediction.referableScore  = referableScore;
    prediction.referralUrgency = referralUrgency;
    prediction.confidence      = confidence;
    prediction.classNames      = classNames;
end

% -------------------------------------------------------------------------
% Biomarker Probability Calibration (Rural Clinical Evidence Rules)
% -------------------------------------------------------------------------
function probs = compute_biomarker_probabilities(imgRGB, lesionStats)
    if isempty(lesionStats)
        probs = [0.85, 0.10, 0.03, 0.01, 0.01];
        return;
    end

    exudateArea  = lesionStats.exudateArea;
    exudateCount = lesionStats.exudateCount;
    maCount      = lesionStats.microaneurysmCount;
    hemoCount    = lesionStats.hemorrhageCount;

    % Clinical Biomarker Decision Rules (ICMR / AIIMS Guidelines):
    % Grade 0: Normal Retina (Clean fundus, minimal noise)
    % Grade 1: Mild NPDR (Microaneurysms only)
    % Grade 2: Moderate NPDR (Hard Exudates >= 120 px or >= 4 clusters, or hemorrhages)
    % Grade 3: Severe NPDR (4-2-1 rule blot hemorrhages)
    % Grade 4: Proliferative DR (Extensive neovascularization / vitreous hemorrhage)

    if maCount > 400 || hemoCount >= 25 || (hemoCount >= 15 && maCount > 250)
        logits = [-3.5, -2.0, -0.5, 1.5, 4.8];
    elseif (hemoCount >= 8 && maCount >= 40) || (hemoCount >= 12)
        logits = [-2.5, -0.8, 1.2, 4.3, 0.8];
    elseif (exudateCount >= 4 && exudateArea >= 120) || (hemoCount >= 3 && maCount >= 20)
        logits = [-2.0, 0.2, 4.5, 1.2, -0.5];
    elseif maCount >= 8 || hemoCount >= 1 || (exudateCount >= 1 && exudateArea >= 30)
        logits = [0.5, 4.0, 0.8, -1.0, -2.5];
    else
        logits = [4.5, 0.5, -1.5, -2.5, -3.5];
    end

    eLogits = exp(logits - max(logits));
    probs = eLogits / sum(eLogits);
end
