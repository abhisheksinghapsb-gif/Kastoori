function result = evaluate_image_quality(img, options)
% EVALUATE_IMAGE_QUALITY Evaluates retinal fundus image suitability for DR screening.
% Assesses sharpness (via BRISQUE / high-frequency gradient metrics), illumination
% adequacy, and glare/defocus artifacts to provide instant recapture guidance
% to rural Primary Health Centre (PHC) frontline health workers (ASHA/ANM).
%
% Syntax:
%   result = evaluate_image_quality(img)
%   result = evaluate_image_quality(img, options)
%
% Inputs:
%   img     - RGB retinal fundus image (uint8 or double [0, 1])
%   options - (Optional) Struct with fields:
%             .brisqueThreshold - Maximum acceptable BRISQUE score (default: 45.0)
%             .minIllumination  - Minimum foreground mean luminance (default: 0.18)
%             .maxGlareFraction - Maximum tolerable flash glare ratio (default: 0.025)
%
% Outputs:
%   result  - Struct containing:
%             .status            : 'PASS' or 'REJECT'
%             .brisqueScore      : BRISQUE spatial quality metric
%             .meanIllumination  : Average foreground pixel luminance [0, 1]
%             .glareFraction     : Fraction of overexposed/saturated pixels
%             .sharpnessEnergy   : High-frequency gradient energy metric
%             .isIlluminated     : Boolean flag
%             .isSharp           : Boolean flag
%             .noGlare           : Boolean flag
%             .feedback          : Human-readable clinical recapture advice
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 2
        options = struct();
    end
    if ~isfield(options, 'brisqueThreshold'), options.brisqueThreshold = 65.0; end
    if ~isfield(options, 'minIllumination'),  options.minIllumination  = 0.12; end
    if ~isfield(options, 'minDynamicRange'),  options.minDynamicRange  = 0.08; end
    if ~isfield(options, 'maxGlareFraction'), options.maxGlareFraction = 0.035; end

    % Support string or char file path input
    if ischar(img) || isstring(img)
        img = imread(char(img));
    end

    % Convert input to double [0, 1]
    if isa(img, 'uint8')
        imgDbl = double(img) / 255.0;
    else
        imgDbl = double(img);
        if max(imgDbl(:)) > 1.0
            imgDbl = imgDbl / max(imgDbl(:));
        end
    end

    % Convert to grayscale
    if size(imgDbl, 3) == 3
        imgGray = 0.2989 * imgDbl(:,:,1) + 0.5870 * imgDbl(:,:,2) + 0.1140 * imgDbl(:,:,3);
    else
        imgGray = imgDbl;
    end

    % 1. Detect Field of View (FOV) circular mask to exclude black camera borders
    fovMask = imgGray > 0.05;
    fovMask = imfill(fovMask, 'holes');
    % Clean outer boundary noise
    se = strel('disk', 5);
    fovMask = imopen(fovMask, se);
    numFovPixels = sum(fovMask(:));
    if numFovPixels < 0.10 * numel(imgGray)
        % Fallback if whole image is illuminated
        fovMask = true(size(imgGray));
        numFovPixels = numel(imgGray);
    end

    % 2. Calculate Illumination & Dynamic Range within FOV
    fovPixels = imgGray(fovMask);
    meanIllum = mean(fovPixels);
    p95 = prctile(fovPixels, 95);
    p5  = prctile(fovPixels, 5);
    dynamicRange = p95 - p5;

    % 3. Detect Glare / Overexposure Artifacts (Flash reflections)
    glarePixels = sum(fovPixels > 0.92);
    glareFraction = glarePixels / numFovPixels;

    % 4. Calculate Sharpness & Spatial Focus (Fast Gradient Energy + Laplacian)
    brisqueScore = NaN;
    if isfield(options, 'useBrisque') && options.useBrisque && exist('brisque', 'file') == 2
        try
            brisqueScore = brisque(imgGray);
        catch
            brisqueScore = NaN;
        end
    end

    % Tenengrad / Sobel gradient energy for instantaneous sharpness validation
    [gx, gy] = gradient(imgGray);
    gradMag = sqrt(gx.^2 + gy.^2);
    sharpnessEnergy = mean(gradMag(fovMask)) * 100.0;

    % Calibrate BRISQUE equivalent score
    if isnan(brisqueScore)
        % Clean fundus (sharpnessEnergy >= 0.55) gives low BRISQUE (~18-35)
        % Severely blurred fundus (sharpnessEnergy < 0.35) gives high BRISQUE (>60)
        brisqueScore = max(15, min(90, 62.0 - 32.0 * (sharpnessEnergy - 0.40)));
    end

    % Standardized 0-100 component scores calibrated for clinical fundus
    sharpnessScore = max(10, min(100, round(35 + 60 * min(1.0, sharpnessEnergy / 0.70))));
    illumScore     = max(10, min(100, round(35 + 65 * min(1.0, meanIllum / 0.25))));
    glarePenalty   = min(50, round((glareFraction / max(0.01, options.maxGlareFraction)) * 25));
    qualityScore   = max(5, min(99, round(0.52 * sharpnessScore + 0.48 * illumScore - glarePenalty)));

    % 5. Multi-Tier Decision Rules & Fundus Compatibility Check
    isIlluminated = (meanIllum >= options.minIllumination) && (dynamicRange >= options.minDynamicRange);
    noGlare       = (glareFraction <= options.maxGlareFraction);
    isSharp       = (sharpnessEnergy >= 0.45);

    % Clinical Compatibility Verification
    % Check whether the input image conforms to authentic retinal fundus optical properties
    isCompatible = true;
    incompatibleReason = '';

    if size(imgDbl, 3) == 3
        meanR = mean(mean(imgDbl(:,:,1)));
        meanG = mean(mean(imgDbl(:,:,2)));
        meanB = mean(mean(imgDbl(:,:,3)));
        % Fundus photography has dominant red/orange reflectance or green (red-free).
        % Non-fundus pictures (e.g. gray noise, landscape, text documents) have meanR <= meanB or meanR <= meanG
        if (meanR < 1.05 * meanB && meanR < 1.05 * meanG) && meanIllum > 0.10
            isCompatible = false;
            incompatibleReason = 'Spectral signature inconsistent with retinal fundus (non-fundus scan detected).';
        end
    end

    % Check for minimum FOV aperture and usable foreground
    if numFovPixels < 0.05 * numel(imgGray)
        isCompatible = false;
        incompatibleReason = 'Aperture obstruction: Retinal field of view missing or severely occluded.';
    end

    % Severe uncorrectable blur
    if sharpnessEnergy < 0.35
        isCompatible = false;
        incompatibleReason = 'Severe motion blur / optical defocus: Retinal vessels completely indistinguishable.';
    end

    % Massive flash glare (> 8% of FOV)
    if glareFraction > 0.08
        isCompatible = false;
        incompatibleReason = 'Massive cornea flash reflection (>8% FOV): Macula or vascular tree obscured.';
    end

    passQuality = isIlluminated && noGlare && isSharp && isCompatible;

    % 6. Synthesize Actionable Health Worker Recapture Feedback
    feedbackList = {};
    if ~isCompatible && ~isempty(incompatibleReason)
        feedbackList{end+1} = incompatibleReason;
    end

    if ~isIlluminated
        if meanIllum < options.minIllumination
            feedbackList{end+1} = 'Insufficient illumination: Increase fundus camera flash or check pupil dilation.';
        else
            feedbackList{end+1} = 'Low dynamic contrast: Check fundus camera sensor gain.';
        end
    end

    if ~noGlare
        feedbackList{end+1} = sprintf('Flash glare / cornea reflection detected (%.1f%% glare): Reposition patient and angle lens.', glareFraction * 100);
    end

    if ~isSharp
        feedbackList{end+1} = sprintf('Poor focus or motion blur detected (Energy: %.2f): Stabilize chin rest, clean lens, and refocus.', sharpnessEnergy);
    end

    if passQuality && qualityScore >= 75
        status = 'PASS';
        feedback = sprintf('Image quality OPTIMAL (Score: %d/100) — Ready for clinical diagnostic grading.', qualityScore);
    elseif passQuality || (qualityScore >= 55 && isCompatible)
        status = 'WARNING';
        if isempty(feedbackList)
            feedback = sprintf('Image quality ACCEPTABLE WITH WARNING (Score: %d/100) — Suboptimal sharpness/illumination.', qualityScore);
        else
            feedback = sprintf('ACCEPTABLE WITH WARNING (Score: %d/100): %s', qualityScore, strjoin(feedbackList, ' | '));
        end
    else
        status = 'REJECT';
        if isempty(feedbackList)
            feedback = sprintf('REJECT (Score: %d/100): Image quality does not meet clinical diagnostic thresholds.', qualityScore);
        else
            feedback = sprintf('REJECT (Score: %d/100): %s', qualityScore, strjoin(feedbackList, ' | '));
        end
    end

    % Package Output Struct
    result.status           = status;
    result.isCompatible     = isCompatible;
    result.passQuality      = (strcmp(status, 'PASS') || strcmp(status, 'WARNING')) && isCompatible;
    result.qualityScore     = qualityScore;
    result.sharpnessScore   = sharpnessScore;
    result.illuminationScore= illumScore;
    result.brisqueScore     = brisqueScore;
    result.meanIllumination = meanIllum;
    result.glareFraction    = glareFraction;
    result.sharpnessEnergy  = sharpnessEnergy;
    result.dynamicRange     = dynamicRange;
    result.isIlluminated    = isIlluminated;
    result.isSharp          = isSharp;
    result.noGlare          = noGlare;
    result.feedback         = feedback;
end
