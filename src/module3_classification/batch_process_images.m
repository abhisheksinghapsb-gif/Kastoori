function [summaryTable, batchStats] = batch_process_images(inputDir, outputDir, options)
% BATCH_PROCESS_IMAGES High-Throughput Autonomous Retinal Screening Pipeline for Rural PHCs.
% Evaluates image batches for Image Quality Assessment (IQA), blood vessel arborization,
% diabetic lesion detection (microaneurysms, hemorrhages, hard exudates), eye orientation (OD/OS),
% ResNet-50 clinical severity grading (G0-G4), and ETDRS 4-2-1 referral triage.
%
% Syntax:
%   summaryTable = batch_process_images()
%   summaryTable = batch_process_images(inputDir)
%   summaryTable = batch_process_images(inputDir, outputDir)
%   [summaryTable, batchStats] = batch_process_images(inputDir, outputDir, options)
%
% Options:
%   .maxImages        - Max images to process (default: Inf)
%   .progressCallback - Function handle: @(idx, total, currentResult)
%   .saveCsv          - Boolean: Export results to CSV (default: true)
%   .verbose          - Boolean: Print terminal progress (default: true)
%
% Smart India Hackathon (SIH) Problem Statement 26038 | MathWorks Sponsored Prototype

    rootDir = fileparts(mfilename('fullpath'));
    if isempty(rootDir), rootDir = pwd; end

    % Ensure paths
    addpath(rootDir);
    addpath(genpath(fullfile(rootDir, 'src')));
    addpath(fullfile(rootDir, 'data'));
    addpath(fullfile(rootDir, 'assets'));

    % Default inputs
    if nargin < 1 || isempty(inputDir)
        inputDir = fullfile(rootDir, 'data', 'test_samples');
    end
    if nargin < 2 || isempty(outputDir)
        outputDir = rootDir;
    end
    if nargin < 3, options = struct(); end

    if ~isfield(options, 'maxImages'),        options.maxImages        = Inf; end
    if ~isfield(options, 'progressCallback'), options.progressCallback = []; end
    if ~isfield(options, 'saveCsv'),          options.saveCsv          = true; end
    if ~isfield(options, 'verbose'),          options.verbose          = true; end

    if ~exist(inputDir, 'dir')
        error('Input directory does not exist: %s', inputDir);
    end

    % Collect supported image formats
    exts = {'*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp'};
    imageFiles = [];
    for k = 1:length(exts)
        fList = dir(fullfile(inputDir, exts{k}));
        imageFiles = [imageFiles; fList]; %#ok<AGROW>
    end

    totalImages = length(imageFiles);
    if totalImages == 0
        warning('No valid fundus images found in: %s', inputDir);
        summaryTable = table();
        batchStats = struct('totalScans', 0, 'passedIQA', 0, 'rejectedIQA', 0, ...
            'referableCount', 0, 'urgentCount', 0, 'avgLatencySec', 0, 'csvPath', '');
        return;
    end

    if totalImages > options.maxImages
        imageFiles = imageFiles(1:options.maxImages);
        totalImages = length(imageFiles);
    end

    if options.verbose
        fprintf('====================================================================\n');
        fprintf('   RETINACARE AI - BATCH IMAGE PROCESSING & CLINICAL TRIAGE\n');
        fprintf('====================================================================\n');
        fprintf(' Target Folder : %s\n', inputDir);
        fprintf(' Total Images  : %d fundus photographs\n', totalImages);
        fprintf(' Pipeline      : IQA -> Enhancement -> Lesions -> Eye OD/OS -> ResNet-50 -> Triage\n');
        fprintf('--------------------------------------------------------------------\n');
    end

    % Preallocate data structures
    PatientID       = cell(totalImages, 1);
    Filename        = cell(totalImages, 1);
    EyeOrientation  = cell(totalImages, 1);
    IQA_Status      = cell(totalImages, 1);
    BRISQUE_Score   = zeros(totalImages, 1);
    DR_Grade        = zeros(totalImages, 1);
    ClinicalLabel   = cell(totalImages, 1);
    ReferableRisk   = zeros(totalImages, 1);
    TriageAction    = cell(totalImages, 1);
    UrgentFlag      = false(totalImages, 1);
    LatencySec      = zeros(totalImages, 1);
    ActionAdvice    = cell(totalImages, 1);

    tBatchStart = tic;

    for i = 1:totalImages
        tScan = tic;
        fName = imageFiles(i).name;
        fPath = fullfile(imageFiles(i).folder, fName);
        Filename{i} = fName;

        % Synthesize / Extract Patient ID
        [~, rawBase, ~] = fileparts(fName);
        cleanBase = regexprep(rawBase, '[^a-zA-Z0-9]', '');
        if length(cleanBase) > 10, cleanBase = cleanBase(1:10); end
        PatientID{i} = sprintf('IND-KA-%s', upper(cleanBase));

        try
            img = imread(fPath);
            if size(img, 3) == 1
                img = repmat(img, [1, 1, 3]);
            end
            if size(img, 1) > 512 || size(img, 2) > 512
                imgProc = imresize(img, [512, 512]);
            else
                imgProc = img;
            end

            % 1. Image Quality Assessment (IQA Gatekeeper)
            iqa = evaluate_image_quality(imgProc);
            IQA_Status{i}    = iqa.status;
            BRISQUE_Score(i) = round(iqa.brisqueScore, 1);

            if strcmp(iqa.status, 'REJECT')
                EyeOrientation{i} = 'UNKNOWN';
                DR_Grade(i)       = -1;
                ClinicalLabel{i}  = 'Ungradeable Scan';
                ReferableRisk(i)  = 0.0;
                TriageAction{i}   = 'RECAPTURE REQUIRED';
                UrgentFlag(i)     = false;
                ActionAdvice{i}   = iqa.feedback;
            else
                % 2. Retinal Enhancement
                enhancedGray = enhance_fundus(imgProc);

                % 3. Retinal Vessel Segmentation
                [vessels, ~, ~] = segment_vessels(enhancedGray);

                % 4. Lesion Detection
                lesions = detect_lesions(imgProc, enhancedGray, vessels);

                % 5. Eye Orientation (OD vs OS)
                eyeInfo = detect_eye_orientation(imgProc, enhancedGray, vessels);
                EyeOrientation{i} = eyeInfo.eyeName;

                % 6. ResNet-50 Severity Grading
                pred = classify_dr(imgProc, [], lesions);
                DR_Grade(i)      = pred.grade;
                ClinicalLabel{i} = pred.gradeName;
                ReferableRisk(i) = round(pred.referableScore * 100, 1);

                % 7. ETDRS 4-2-1 Referral Triage
                switch pred.grade
                    case 0
                        TriageAction{i} = 'CLEARED: ROUTINE ANNUAL RESCREEN';
                        UrgentFlag(i)   = false;
                        ActionAdvice{i} = 'No diabetic retinopathy. Rescreen in 12 months at PHC.';
                    case 1
                        TriageAction{i} = 'PHC MONITORING (NON-REFERABLE)';
                        UrgentFlag(i)   = false;
                        ActionAdvice{i} = 'Microaneurysms only. Review in 6-12 months with blood sugar control.';
                    case 2
                        TriageAction{i} = 'MODERATE REFERRAL (30 DAYS)';
                        UrgentFlag(i)   = false;
                        ActionAdvice{i} = 'Secondary Vision Centre within 30 days for dilated indirect ophthalmoscopy.';
                    case 3
                        TriageAction{i} = 'HIGH-RISK REFERRAL (<14 DAYS)';
                        UrgentFlag(i)   = true;
                        ActionAdvice{i} = 'Severe NPDR (ETDRS 4-2-1). Specialist consultation within 2 weeks.';
                    case 4
                        TriageAction{i} = 'URGENT REFERRAL (<48 HOURS)';
                        UrgentFlag(i)   = true;
                        ActionAdvice{i} = 'Proliferative DR. Urgent referral to Tertiary Eye Hospital for Panretinal Photocoagulation.';
                end
            end

        catch ME
            IQA_Status{i}     = 'ERROR';
            BRISQUE_Score(i)  = 99.9;
            EyeOrientation{i} = 'ERROR';
            DR_Grade(i)       = -1;
            ClinicalLabel{i}  = sprintf('Processing Error: %s', ME.message);
            ReferableRisk(i)  = 0.0;
            TriageAction{i}   = 'PIPELINE ERROR';
            UrgentFlag(i)     = false;
            ActionAdvice{i}   = 'Verify image format and integrity.';
        end

        LatencySec(i) = round(toc(tScan), 3);

        % Terminal progress printout
        if options.verbose
            fprintf('[%3d/%3d] %-28s | Eye: %-7s | IQA: %-6s | Grade %2d (%-14s) | Risk: %5.1f%% | %5.2fs\n', ...
                i, totalImages, fName, EyeOrientation{i}, IQA_Status{i}, DR_Grade(i), ClinicalLabel{i}, ReferableRisk(i), LatencySec(i));
        end

        % Invoke GUI progress callback if provided
        if ~isempty(options.progressCallback)
            curResult = struct('index', i, 'total', totalImages, 'file', fName, ...
                'patientId', PatientID{i}, 'eye', EyeOrientation{i}, 'iqa', IQA_Status{i}, ...
                'grade', DR_Grade(i), 'label', ClinicalLabel{i}, 'risk', ReferableRisk(i), ...
                'triage', TriageAction{i}, 'urgent', UrgentFlag(i), 'latency', LatencySec(i));
            try
                options.progressCallback(i, totalImages, curResult);
            catch
            end
        end
    end

    totalDuration = toc(tBatchStart);
    avgLatency = mean(LatencySec);

    % Build Summary Table
    summaryTable = table(PatientID, Filename, EyeOrientation, IQA_Status, BRISQUE_Score, ...
        DR_Grade, ClinicalLabel, ReferableRisk, TriageAction, UrgentFlag, LatencySec, ActionAdvice, ...
        'VariableNames', {'Patient_ID', 'Filename', 'Eye_Orientation', 'IQA_Status', 'BRISQUE', ...
        'DR_Grade', 'Clinical_Diagnosis', 'Referable_Risk_Pct', 'Triage_Action', 'Urgent_Intervention', 'Latency_sec', 'Clinical_Advice'});

    % Compute Aggregate Batch Statistics
    passCount     = sum(strcmp(IQA_Status, 'PASS'));
    rejectCount   = sum(strcmp(IQA_Status, 'REJECT'));
    referableCount= sum(DR_Grade >= 2);
    normalCount   = sum(DR_Grade == 0);
    mildCount     = sum(DR_Grade == 1);
    urgentCount   = sum(UrgentFlag == true);

    batchStats = struct();
    batchStats.totalScans       = totalImages;
    batchStats.passedIQA        = passCount;
    batchStats.passedIQAPct     = round((passCount / max(1, totalImages)) * 100, 1);
    batchStats.rejectedIQA      = rejectCount;
    batchStats.rejectedIQAPct   = round((rejectCount / max(1, totalImages)) * 100, 1);
    batchStats.referableCount   = referableCount;
    batchStats.referablePct     = round((referableCount / max(1, totalImages)) * 100, 1);
    batchStats.nonReferableCount= normalCount + mildCount;
    batchStats.urgentCount      = urgentCount;
    batchStats.avgLatencySec    = round(avgLatency, 3);
    batchStats.throughputHz     = round(totalImages / max(0.01, totalDuration), 1);
    batchStats.totalDurationSec = round(totalDuration, 2);
    batchStats.csvPath          = '';

    % Save CSV Audit File
    if options.saveCsv
        timestampStr = datestr(now, 'yyyymmdd_HHMMSS');
        csvFilename = sprintf('Batch_Screening_Summary_%s.csv', timestampStr);
        csvPath = fullfile(outputDir, csvFilename);
        writetable(summaryTable, csvPath);
        batchStats.csvPath = csvPath;
        if options.verbose
            fprintf('\nSaved Batch Screening Audit CSV to:\n  %s\n', csvPath);
        end
    end

    if options.verbose
        fprintf('\n====================================================================\n');
        fprintf('   BATCH SCREENING COMPLETE\n');
        fprintf('   Total Processed   : %d images in %.2f seconds (%.1f scans/sec)\n', totalImages, totalDuration, batchStats.throughputHz);
        fprintf('   IQA Usability Pass: %d / %d (%.1f%%)\n', passCount, totalImages, batchStats.passedIQAPct);
        fprintf('   Referable DR Rate : %d / %d (%.1f%%)\n', referableCount, totalImages, batchStats.referablePct);
        fprintf('   Urgent Laser/Surg : %d patients flagged\n', urgentCount);
        fprintf('   Mean Latency/Scan : %.3f seconds\n', avgLatency);
        fprintf('====================================================================\n\n');
    end
end
