function eyeInfo = detect_eye_orientation(img, enhancedGray, vesselMask)
% DETECT_EYE_ORIENTATION Automatically identifies eye lateralization (OD vs OS)
% and localizes the Macula/Fovea anatomical center in retinal fundus images.
%
% Anatomical Rule:
%   - The Optic Disc is always positioned NASALLY (towards the nose).
%   - The Macula / Fovea is always positioned TEMPORALLY (towards the ear).
%   - In a Right Eye (OD - Oculus Dexter):
%       Optic Disc is to the LEFT (nasal), Macula is to the RIGHT (temporal) -> X_od < X_macula.
%   - In a Left Eye (OS - Oculus Sinister):
%       Optic Disc is to the RIGHT (nasal), Macula is to the LEFT (temporal) -> X_od > X_macula.
%
% Syntax:
%   eyeInfo = detect_eye_orientation(img)
%   eyeInfo = detect_eye_orientation(img, enhancedGray, vesselMask)
%
% Outputs:
%   eyeInfo - Struct containing:
%             .eyeCode      : 'OD' or 'OS'
%             .eyeName      : 'Right Eye (OD)' or 'Left Eye (OS)'
%             .confidence   : Confidence score [0.5, 1.0]
%             .odCenter     : [X_od, Y_od] coordinates in 512x512 space
%             .odRadius     : Estimated optic disc radius in pixels
%             .foveaCenter  : [X_fovea, Y_fovea] coordinates in 512x512 space
%             .foveaRadius  : Foveal avascular zone (FAZ) radius (~30 px)
%             .discDiameter : Estimated optic disc diameter in pixels
%             .nasalSide    : 'Left' or 'Right'
%             .temporalSide : 'Right' or 'Left'
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 2 || isempty(enhancedGray)
        if isa(img, 'uint8')
            imgDbl = double(img) / 255.0;
        else
            imgDbl = double(img);
            if max(imgDbl(:)) > 1.0, imgDbl = imgDbl / max(imgDbl(:)); end
        end
        enhancedGray = imgDbl(:,:,2); % Green channel
    end

    % Standardize resolution to 512x512
    targetSize = [512, 512];
    if size(enhancedGray, 1) ~= targetSize(1) || size(enhancedGray, 2) ~= targetSize(2)
        G = imresize(enhancedGray, targetSize);
    else
        G = enhancedGray;
    end
    [H, W] = size(G);

    % Detect FOV mask
    fovMask = G > 0.05;
    fovMask = imfill(fovMask, 'holes');
    fovMask = imopen(fovMask, strel('disk', 5));
    imgCenterX = W / 2;

    % ---------------------------------------------------------------------
    % 1. Localize Optic Disc (Bright, vascular convergence region)
    % ---------------------------------------------------------------------
    seOD = strel('disk', 18);
    odCand = imclose(G, seOD);
    odCand(~fovMask) = 0;
    
    % If vessel mask is provided, use vessel convergence weighting
    if nargin >= 3 && ~isempty(vesselMask)
        vMaskResized = imresize(double(vesselMask > 0), targetSize);
        vDensity = conv2(vMaskResized, ones(31, 31), 'same') / (31 * 31);
        odMetric = conv2(G, fspecial('gaussian', [31 31], 8), 'same') .* (vDensity * 3.0 + 0.5);
    else
        odMetric = conv2(G, fspecial('gaussian', [31 31], 8), 'same');
    end
    odMetric(~fovMask) = 0;

    [~, maxIdx] = max(odMetric(:));
    [odY, odX] = ind2sub([H, W], maxIdx);
    
    % Normal anatomical optic disc diameter in a 512x512 image is ~65-80 px (radius ~35-40 px)
    odRadius = 38;
    discDiameter = odRadius * 2;

    % ---------------------------------------------------------------------
    % 2. Determine Eye Lateralization (OD vs OS)
    % ---------------------------------------------------------------------
    % The optic disc is always nasal. In most retinal photos:
    % - If OD center is in the left half of the FOV (odX < imgCenterX) -> Right Eye (OD)
    % - If OD center is in the right half of the FOV (odX >= imgCenterX) -> Left Eye (OS)
    
    distFromCenter = abs(odX - imgCenterX);
    maxPossibleDist = W / 2;
    conf = min(0.99, max(0.60, 0.60 + (distFromCenter / maxPossibleDist) * 0.38));

    if odX < imgCenterX
        eyeCode      = 'OD';
        eyeName      = 'Right Eye (OD)';
        nasalSide    = 'Left';
        temporalSide = 'Right';
        
        % In Right Eye (OD): Fovea lies TEMPORALLY (to the right of Optic Disc)
        foveaEstX = round(odX + 2.45 * discDiameter);
        foveaEstY = round(odY + 0.25 * discDiameter);
    else
        eyeCode      = 'OS';
        eyeName      = 'Left Eye (OS)';
        nasalSide    = 'Right';
        temporalSide = 'Left';
        
        % In Left Eye (OS): Fovea lies TEMPORALLY (to the left of Optic Disc)
        foveaEstX = round(odX - 2.45 * discDiameter);
        foveaEstY = round(odY + 0.25 * discDiameter);
    end

    % ---------------------------------------------------------------------
    % 3. Refine Foveal Avascular Zone (FAZ) Center (Darkest local region in macula)
    % ---------------------------------------------------------------------
    searchRadius = 35;
    xMin = max(1, foveaEstX - searchRadius);
    xMax = min(W, foveaEstX + searchRadius);
    yMin = max(1, foveaEstY - searchRadius);
    yMax = min(H, foveaEstY + searchRadius);

    if xMin < xMax && yMin < yMax
        macularROI = G(yMin:yMax, xMin:xMax);
        roiFov = fovMask(yMin:yMax, xMin:xMax);
        
        macularROI(~roiFov) = 1.0;
        macSmooth = conv2(macularROI, fspecial('gaussian', [11 11], 3.0), 'same');
        [~, minIdx] = min(macSmooth(:));
        [relY, relX] = ind2sub(size(macularROI), minIdx);
        
        foveaX = xMin + relX - 1;
        foveaY = yMin + relY - 1;
    else
        foveaX = max(40, min(W - 40, foveaEstX));
        foveaY = max(40, min(H - 40, foveaEstY));
    end

    foveaRadius = 28;

    % Package results
    eyeInfo = struct();
    eyeInfo.eyeCode      = eyeCode;
    eyeInfo.eyeName      = eyeName;
    eyeInfo.confidence   = conf;
    eyeInfo.odCenter     = [odX, odY];
    eyeInfo.odRadius     = odRadius;
    eyeInfo.discDiameter = discDiameter;
    eyeInfo.foveaCenter  = [foveaX, foveaY];
    eyeInfo.foveaRadius  = foveaRadius;
    eyeInfo.nasalSide    = nasalSide;
    eyeInfo.temporalSide = temporalSide;
end
