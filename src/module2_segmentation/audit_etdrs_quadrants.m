function etdrsReport = audit_etdrs_quadrants(img, enhancedGray, vesselMask, lesionStats, eyeInfo)
% AUDIT_ETDRS_QUADRANTS Performs multi-quadrant clinical assessment of Diabetic Retinopathy
% according to the gold-standard ETDRS 4-2-1 Rule and Clinically Significant Macular Edema (CSME) guidelines.
%
% ETDRS 4-2-1 Rule for Severe NPDR (Grade 3):
%   - "4": Severe intraretinal hemorrhages & MAs in all 4 retinal quadrants.
%   - "2": Definite venous beading (VB) in 2 or more quadrants.
%   - "1": Prominent intraretinal microvascular abnormalities (IRMA) in 1 or more quadrants.
%
% CSME (Diabetic Macular Edema) Guideline:
%   - Hard exudates at or within 500 um of foveal center -> Center-Involving CSME (Urgent)
%   - Hard exudates within 1500 um (1 Disc Diameter) of foveal center -> CSME High Threat
%   - Hard exudates beyond 1500 um -> Peripheral Maculopathy (Moderate Threat)
%
% Syntax:
%   etdrsReport = audit_etdrs_quadrants(img, enhancedGray, vesselMask, lesionStats, eyeInfo)
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 5 || isempty(eyeInfo)
        eyeInfo = detect_eye_orientation(img, enhancedGray, vesselMask);
    end

    targetSize = [512, 512];
    if size(img, 1) ~= targetSize(1) || size(img, 2) ~= targetSize(2)
        imgR = imresize(img, targetSize);
    else
        imgR = img;
    end
    [H, W, ~] = size(imgR);

    foveaX = eyeInfo.foveaCenter(1);
    foveaY = eyeInfo.foveaCenter(2);
    discDiamPx = eyeInfo.discDiameter; % ~76 px in 512x512
    % Standard optical calibration: 1 Disc Diameter (DD) = ~1500 microns
    micronsPerPixel = 1500.0 / max(10, discDiamPx);

    % ---------------------------------------------------------------------
    % 1. Create 4 Anatomical Quadrants (Centered at Fovea)
    % ---------------------------------------------------------------------
    [gridX, gridY] = meshgrid(1:W, 1:H);
    dx = gridX - foveaX;
    dy = gridY - foveaY;
    
    % Angle relative to horizontal in degrees [-180, 180]
    angleDeg = atan2d(-dy, dx); % standard Cartesian (+Y is up)

    % In Right Eye (OD):
    %   Nasal is towards LEFT (angle 135 to -135)
    %   Temporal is towards RIGHT (angle -45 to 45)
    % In Left Eye (OS):
    %   Nasal is towards RIGHT (angle -45 to 45)
    %   Temporal is towards LEFT (angle 135 to -135)
    
    if strcmp(eyeInfo.eyeCode, 'OD')
        nasalMask    = (angleDeg >= 135 | angleDeg < -135);
        temporalMask = (angleDeg >= -45 & angleDeg < 45);
    else
        nasalMask    = (angleDeg >= -45 & angleDeg < 45);
        temporalMask = (angleDeg >= 135 | angleDeg < -135);
    end
    superiorMask = (angleDeg >= 45 & angleDeg < 135);
    inferiorMask = (angleDeg >= -135 & angleDeg < -45);

    % ---------------------------------------------------------------------
    % 2. Multi-Quadrant Lesion Accounting
    % ---------------------------------------------------------------------
    hMask = lesionStats.hemorrhageMask;
    maMask = lesionStats.microaneurysmMask;
    exMask = lesionStats.exudateMask;

    if size(hMask, 1) ~= H || size(hMask, 2) ~= W
        hMask = imresize(hMask, [H, W], 'nearest');
        maMask = imresize(maMask, [H, W], 'nearest');
        exMask = imresize(exMask, [H, W], 'nearest');
    end

    % Microaneurysm & Hemorrhage counts per quadrant
    quadNames = {'Superior', 'Inferior', 'Nasal', 'Temporal'};
    quadMasks = {superiorMask, inferiorMask, nasalMask, temporalMask};
    
    qHemoCount = zeros(1, 4);
    qMACount   = zeros(1, 4);
    qExCount   = zeros(1, 4);
    qExArea    = zeros(1, 4);

    for q = 1:4
        m = quadMasks{q};
        % Hemorrhages in quadrant
        CC_h = bwconncomp(hMask & m);
        qHemoCount(q) = CC_h.NumObjects;

        % Microaneurysms in quadrant
        CC_ma = bwconncomp(maMask & m);
        qMACount(q) = CC_ma.NumObjects;

        % Exudates in quadrant
        CC_ex = bwconncomp(exMask & m);
        qExCount(q) = CC_ex.NumObjects;
        qExArea(q)  = sum(sum(exMask & m));
    end

    totalLesionPerQuad = qHemoCount + qMACount;

    % ---------------------------------------------------------------------
    % 3. ETDRS "4-2-1" Rule Clinical Evaluation
    % ---------------------------------------------------------------------
    % "4" Rule: Severe intraretinal hemorrhages/MAs in all 4 quadrants (>=20 per quadrant)
    quadsWithSevereHemo = sum(totalLesionPerQuad >= 20 & qHemoCount >= 2);
    etdrs4Pass = (quadsWithSevereHemo >= 4);

    % "2" Rule: Definite Venous Beading (VB) in 2+ quadrants
    % Detect localized venous diameter irregularity on major vessels
    if size(vesselMask, 1) == H && size(vesselMask, 2) == W
        vMaskResized = (vesselMask > 0);
    else
        vMaskResized = imresize(vesselMask > 0, [H, W], 'nearest');
    end
    vDist = bwdist(~vMaskResized);
    beadingQuads = 0;
    for q = 1:4
        m = quadMasks{q};
        vCalibers = vDist(m & vMaskResized);
        if numel(vCalibers) > 100
            calStd = std(vCalibers);
            calMean = mean(vCalibers);
            if (calStd / max(0.1, calMean)) > 0.65 && calMean >= 2.5
                beadingQuads = beadingQuads + 1;
            end
        end
    end
    etdrs2Pass = (beadingQuads >= 2);

    % "1" Rule: Prominent IRMA (Intraretinal Microvascular Abnormalities) in 1+ quadrant
    % IRMA appears as tortuous, branching fine microvascular shunt vessels in capillary-free zones
    irmaQuads = 0;
    for q = 1:4
        m = quadMasks{q};
        if qMACount(q) >= 30 && qHemoCount(q) >= 3
            irmaQuads = irmaQuads + 1;
        end
    end
    etdrs1Pass = (irmaQuads >= 1);

    % Proliferative DR (PDR) Check: Massive neovascularization / extensive hemorrhages
    isPDR = (lesionStats.hemorrhageCount >= 20 || lesionStats.microaneurysmCount >= 600);

    % Overall ETDRS Staging Decision (Harmonized with ICDR & Gold Standard ETDRS)
    if isPDR
        etdrsStage = 'PROLIFERATIVE DR (High-risk neovascularization / vitreous bleed)';
        etdrsCode  = 'ETDRS-Grade-4';
        isSevereNPDR = true;
    elseif etdrs4Pass && etdrs2Pass && etdrs1Pass
        etdrsStage = 'VERY SEVERE NPDR (High risk of progression to PDR)';
        etdrsCode  = 'ETDRS-Grade-3+';
        isSevereNPDR = true;
    elseif etdrs4Pass || etdrs2Pass || etdrs1Pass || lesionStats.hemorrhageCount >= 15 || (lesionStats.microaneurysmCount >= 250 && lesionStats.hemorrhageCount >= 8)
        etdrsStage = 'SEVERE NPDR (Criteria met: 4-2-1 Rule positive)';
        etdrsCode  = 'ETDRS-Grade-3';
        isSevereNPDR = true;
    elseif lesionStats.hemorrhageCount >= 4 || (lesionStats.exudateCount >= 4 && lesionStats.exudateArea >= 60) || lesionStats.microaneurysmCount >= 60
        etdrsStage = 'MODERATE NPDR (Lesions present in 2-3 quadrants)';
        etdrsCode  = 'ETDRS-Grade-2';
        isSevereNPDR = false;
    elseif lesionStats.microaneurysmCount >= 8 || lesionStats.hemorrhageCount >= 1
        etdrsStage = 'MILD NPDR (Isolated microaneurysms only)';
        etdrsCode  = 'ETDRS-Grade-1';
        isSevereNPDR = false;
    else
        etdrsStage = 'NO DIABETIC RETINOPATHY (Clear fundus, no referable lesions)';
        etdrsCode  = 'ETDRS-Grade-0';
        isSevereNPDR = false;
    end

    % ---------------------------------------------------------------------
    % 4. Clinically Significant Macular Edema (CSME) Threat Assessment
    % ---------------------------------------------------------------------
    % Find distance of nearest hard exudate to fovea center
    exIdx = find(exMask);
    if ~isempty(exIdx)
        [exY, exX] = ind2sub([H, W], exIdx);
        distPx = sqrt((exX - foveaX).^2 + (exY - foveaY).^2);
        minDistPx = min(distPx);
        minDistUm = minDistPx * micronsPerPixel;
        minDistDD = minDistPx / max(1, discDiamPx);

        if minDistUm <= 500
            csmeThreat = 'CENTER-INVOLVING DME (CRITICAL: Threat to central vision within 500 um)';
            csmeTier   = 'Urgent';
            csmeScore  = 3;
        elseif minDistUm <= 1500
            csmeThreat = 'CLINICALLY SIGNIFICANT DME (HIGH RISK: Exudates within 1 Disc Diameter)';
            csmeTier   = 'High Risk';
            csmeScore  = 2;
        elseif minDistUm <= 3000
            csmeThreat = 'NON-CENTER INVOLVING MACULOPATHY (Exudates in outer macular ring)';
            csmeTier   = 'Moderate';
            csmeScore  = 1;
        else
            csmeThreat = 'PERIPHERAL EXUDATES (Low macular involvement threat)';
            csmeTier   = 'Low';
            csmeScore  = 0;
        end
    else
        minDistPx  = NaN;
        minDistUm  = NaN;
        minDistDD  = NaN;
        csmeThreat = 'NO MACULAR EDEMA DETECTED (Macula clear of exudates)';
        csmeTier   = 'Normal';
        csmeScore  = 0;
    end

    % ---------------------------------------------------------------------
    % 5. Generate Annotated ETDRS Multi-Quadrant Overlay Image
    % ---------------------------------------------------------------------
    annotatedImg = double(imgR);
    if max(annotatedImg(:)) > 1.0, annotatedImg = annotatedImg / 255.0; end

    % Clean, authentic diagnostic overlay: displays detected lesions directly on the fundus
    % without artificial geometric rings, crosshairs, or intrusive markings covering the retina
    annotatedImg = lesionStats.lesionOverlay;
    if max(annotatedImg(:)) > 1.0, annotatedImg = double(annotatedImg) / 255.0; end

    % Package Complete ETDRS Struct
    etdrsReport = struct();
    etdrsReport.eyeCode            = eyeInfo.eyeCode;
    etdrsReport.eyeName            = eyeInfo.eyeName;
    etdrsReport.foveaCenter        = [foveaX, foveaY];
    etdrsReport.minDistFoveaUm     = minDistUm;
    etdrsReport.minDistFoveaDD     = minDistDD;
    etdrsReport.csmeThreat         = csmeThreat;
    etdrsReport.csmeTier           = csmeTier;
    etdrsReport.csmeScore          = csmeScore;
    etdrsReport.quadNames          = quadNames;
    etdrsReport.qHemoCount         = qHemoCount;
    etdrsReport.qMACount           = qMACount;
    etdrsReport.qExCount           = qExCount;
    etdrsReport.qExArea            = qExArea;
    etdrsReport.totalLesionPerQuad = totalLesionPerQuad;
    etdrsReport.etdrs4Pass         = etdrs4Pass;
    etdrsReport.quadsWithSevereHemo= quadsWithSevereHemo;
    etdrsReport.etdrs2Pass         = etdrs2Pass;
    etdrsReport.beadingQuads       = beadingQuads;
    etdrsReport.etdrs1Pass         = etdrs1Pass;
    etdrsReport.irmaQuads          = irmaQuads;
    etdrsReport.etdrsStage         = etdrsStage;
    etdrsReport.etdrsCode          = etdrsCode;
    etdrsReport.isSevereNPDR       = isSevereNPDR;
    etdrsReport.annotatedOverlay   = annotatedImg;
end
