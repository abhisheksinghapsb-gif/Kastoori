function [videoPath, montagePath] = generate_empathy_video(outputVideoPath, options)
% GENERATE_EMPATHY_VIDEO Produces a broadcast-quality, clinically authentic
% Vision Loss Empathy Simulator video (1280x720 HD) demonstrating progressive
% vision decay across all 5 Diabetic Retinopathy severity stages (Grade 0 to 4).
%
% Features:
%   - Realistic high-definition visual test scene (Snellen Chart, Prescription, Family Photo, Road Scene)
%   - Picture-in-Picture (PiP) Retinal Scan Inset showing actual fundus pathology for each grade
%   - Clinically accurate vision loss physics:
%       * Stage 0: 20/20 Crisp Clear Vision (Normal)
%       * Stage 1: Subtle Contrast Loss & Micro-halos (Mild NPDR)
%       * Stage 2: Central Macular Blur & Metamorphopsia / Wavy Text (Moderate NPDR / DME)
%       * Stage 3: Dark Patchy Scotomas & Drifting Vitreous Floaters (Severe NPDR)
%       * Stage 4: Dense Vitreous Hemorrhage Curtains & Total Light Loss (Proliferative DR)
%   - Broadcast-grade lower-third HUD with real-time acuity and triage guidance
%   - High-fidelity 5-stage static montage card export
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1 || isempty(outputVideoPath)
        baseDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
        outputVideoPath = fullfile(baseDir, 'dr_vision_loss_empathy.mp4');
    end
    if nargin < 2, options = struct(); end
    if ~isfield(options, 'fps'),       options.fps = 30; end
    if ~isfield(options, 'duration'),  options.duration = 25; end % 25 seconds broadcast grade

    fprintf('========================================================================\n');
    fprintf('  GENERATING HD VISION LOSS EMPATHY SIMULATOR (1280x720 HD, 5 STAGES)\n');
    fprintf('========================================================================\n');

    baseDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    samplesDir = fullfile(baseDir, 'data', 'test_samples');

    % 1. Load Photorealistic Generative AI Visual Scene (1280 x 720)
    width  = 1280;
    height = 720;
    aiSceneFile = fullfile(baseDir, 'data', 'dr_base_scene.jpg');
    if exist(aiSceneFile, 'file')
        baseScene = imread(aiSceneFile);
        if size(baseScene, 1) ~= height || size(baseScene, 2) ~= width
            baseScene = imresize(baseScene, [height, width]);
        end
    else
        baseScene = create_realistic_scene_hd(width, height);
    end

    % 2. Load Real Clinical Fundus Inset Images for each of the 5 grades
    fundusScans = cell(1, 5);
    fundusFiles = {
        fullfile(samplesDir, 'idrid_grade0_normal.jpg'), ...
        fullfile(samplesDir, 'idrid_grade1_mild.jpg'), ...
        fullfile(samplesDir, 'idrid_grade2_moderate.jpg'), ...
        fullfile(samplesDir, 'idrid_grade3_severe.jpg'), ...
        fullfile(samplesDir, 'idrid_grade4_proliferative.jpg')
    };
    for i = 1:5
        if exist(fundusFiles{i}, 'file')
            fImg = imread(fundusFiles{i});
            fundusScans{i} = imresize(fImg, [210, 210]);
        else
            fundusScans{i} = repmat(uint8(50 + i*30), [210, 210, 3]);
        end
    end

    % 3. Setup Video Writer
    [outDir, outName, ~] = fileparts(outputVideoPath);
    if isempty(outDir), outDir = pwd; end
    if ~exist(outDir, 'dir'), mkdir(outDir); end

    profiles = VideoWriter.getProfiles();
    profileNames = {profiles.Name};
    useMp4 = any(strcmp(profileNames, 'MPEG-4'));

    if useMp4
        actualVideoPath = fullfile(outDir, [outName, '.mp4']);
        vw = VideoWriter(actualVideoPath, 'MPEG-4');
        vw.Quality = 95;
    else
        actualVideoPath = fullfile(outDir, [outName, '.avi']);
        vw = VideoWriter(actualVideoPath, 'Motion JPEG AVI');
        vw.Quality = 92;
    end
    vw.FrameRate = options.fps;
    open(vw);

    totalFrames = options.fps * options.duration;
    framesPerStage = floor(totalFrames / 5);

    % Stage metadata definitions
    stages = {
        struct('grade', 0, 'name', 'STAGE 0: NORMAL HEALTHY RETINA', ...
               'acuity', '20/20 Snellen (Normal)', ...
               'urgency', 'CLEAR (Routine Annual Check)', ...
               'color', [0.10, 0.65, 0.32], ...
               'desc', 'Crystal-clear 20/20 vision. No vascular leakage or macular edema.');
        struct('grade', 1, 'name', 'STAGE 1: MILD NPDR (MICROANEURYSMS)', ...
               'acuity', '20/25 Snellen (Subtle Loss)', ...
               'urgency', 'MONITOR (Non-Referable)', ...
               'color', [0.12, 0.60, 0.45], ...
               'desc', 'Subtle micro-contrast reduction and glare. Patient is often asymptomatic.');
        struct('grade', 2, 'name', 'STAGE 2: MODERATE NPDR (MACULAR EDEMA)', ...
               'acuity', '20/60 Snellen (Metamorphopsia)', ...
               'urgency', 'SECONDARY CLINIC (30 Days)', ...
               'color', [0.92, 0.55, 0.05], ...
               'desc', 'Central macular blur & wavy distortion. Reading medication labels becomes impossible.');
        struct('grade', 3, 'name', 'STAGE 3: SEVERE NPDR (BLOT HEMORRHAGES)', ...
               'acuity', '20/150 Snellen (Scotomas)', ...
               'urgency', 'TERTIARY REFERRAL (14 Days)', ...
               'color', [0.88, 0.32, 0.08], ...
               'desc', 'Dark patchy blind spots (scotomas) & floating blood spots obscuring vision and faces.');
        struct('grade', 4, 'name', 'STAGE 4: PROLIFERATIVE DR (VITREOUS BLEED)', ...
               'acuity', '20/400 Snellen (Legal Blindness)', ...
               'urgency', 'CRITICAL INTERVENTION (<48h)', ...
               'color', [0.85, 0.12, 0.18], ...
               'desc', 'Dense black vitreous hemorrhage curtains. High risk of tractional retinal detachment.');
    };

    stagePreviews = cell(1, 5);

    % 4. Render Video Frames with Smooth Transitions
    fprintf('  > Rendering %d HD frames across 5 clinical stages (%d fps, %d sec)...\n', ...
        totalFrames, options.fps, options.duration);
    transFrames = round(0.20 * framesPerStage); % 30 frames smooth cross-fade between stages
    for f = 1:totalFrames
        rawStage = (f - 1) / framesPerStage;
        sIdx = min(5, floor(rawStage) + 1);
        t = rawStage - floor(rawStage);

        % Smooth cosine easing curve
        smoothT = 0.5 - 0.5 * cos(pi * t);

        currentMeta = stages{sIdx};
        currentFundus = fundusScans{sIdx};

        % Render visual loss optical physics on the scene
        frameImg = render_simulated_frame_hd(baseScene, sIdx, smoothT, f);

        % Continuous cross-stage temporal blend to eliminate jumps
        stageFrameIdx = mod(f - 1, framesPerStage);
        if sIdx > 1 && stageFrameIdx < transFrames
            prevImg = render_simulated_frame_hd(baseScene, sIdx - 1, 1.0, f);
            blendWeight = 0.5 - 0.5 * cos(pi * (stageFrameIdx / transFrames));
            frameImg = uint8(double(prevImg) * (1.0 - blendWeight) + double(frameImg) * blendWeight);
        end

        % Composite Picture-in-Picture (PiP) Retinal Inset in top-right
        frameWithPiP = composite_retinal_pip(frameImg, currentFundus, currentMeta, f);

        % Render Broadcast HUD Overlay at bottom
        finalFrame = draw_hud_overlay_hd(frameWithPiP, currentMeta, f, totalFrames);

        writeVideo(vw, finalFrame);

        % Capture representative mid-stage frame for static montage card
        if f == floor((sIdx - 0.5) * framesPerStage)
            stagePreviews{sIdx} = finalFrame;
        end
    end

    close(vw);
    fprintf('  [OK] Vision Loss Empathy Video exported: %s\n', actualVideoPath);

    % 5. Generate 5-Panel Static Montage Card for PDF Reports & GUI
    montagePath = fullfile(outDir, 'empathy_stages_preview.png');
    export_montage_card_hd(stagePreviews, stages, montagePath);
    fprintf('  [OK] 5-Stage Empathy Card exported: %s\n', montagePath);

    % Export individual stage preview images for real-time interactive GUI explorer
    stagesDir = fullfile(baseDir, 'data', 'empathy_stages');
    if ~exist(stagesDir, 'dir'), mkdir(stagesDir); end
    for s = 1:5
        if ~isempty(stagePreviews{s})
            imwrite(stagePreviews{s}, fullfile(stagesDir, sprintf('stage_%d.png', s-1)));
        end
    end
    fprintf('  [OK] Exported 5 interactive stage viewcards to: %s\n', stagesDir);

    videoPath = actualVideoPath;
end

% -------------------------------------------------------------------------
% Render Individual Frame with DR Pathologies (1280 x 720)
% -------------------------------------------------------------------------
function simImg = render_simulated_frame_hd(baseScene, stageIdx, t, frameNum)
    [H, W, ~] = size(baseScene);
    simImg = double(baseScene) / 255.0;

    centerX = round(W * 0.36); % Centered directly on prescription bottle in patient hand
    centerY = round(H * 0.58);
    [X, Y] = meshgrid(1:W, 1:H);
    distFromCenter = sqrt((X - centerX).^2 + (Y - centerY).^2);

    meanVal = mean(simImg(:));

    switch stageIdx
        case 1 % Stage 0 (Healthy 20/20)
            % Crystal clear, pristine optical sharpness
            simImg = simImg;

        case 2 % Stage 1 (Mild NPDR)
            % Subtle contrast attenuation (up to 12%) & faint micro-halo
            contrastDrop = 0.04 + 0.10 * t;
            simImg = simImg * (1 - contrastDrop) + meanVal * contrastDrop;

        case 3 % Stage 2 (Moderate NPDR / Macular Edema - Metamorphopsia)
            % 1. Metamorphopsia (Amsler-grid wavy distortion of straight text)
            fovealRadius = W * 0.28;
            fovealWeight = exp(- (distFromCenter / fovealRadius).^2);
            
            % 2D wave displacement field
            waveAmp = (3.0 + 9.0 * t);
            dx = waveAmp * sin(2 * pi * Y / 75.0) .* fovealWeight;
            dy = waveAmp * cos(2 * pi * X / 85.0) .* fovealWeight;
            
            X_warp = min(W, max(1, X + dx));
            Y_warp = min(H, max(1, Y + dy));
            
            for c = 1:3
                simImg(:, :, c) = interp2(X, Y, simImg(:, :, c), X_warp, Y_warp, 'linear', meanVal);
            end

            % 2. Central foveal blur
            blurRadius = 1.0 + 10.0 * t;
            h = fspecial('gaussian', [25 25], blurRadius);
            blurred = imfilter(simImg, h, 'replicate');
            fovealMask3 = repmat(fovealWeight, [1, 1, 3]);
            simImg = simImg .* (1 - 0.78 * fovealMask3) + blurred .* (0.78 * fovealMask3);
            simImg = simImg * 0.95;

        case 4 % Stage 3 (Severe NPDR - Blot Hemorrhages & Scotomas)
            % 1. Generalized background blur
            h = fspecial('gaussian', [29 29], 12.0 + 6.0 * t);
            blurred = imfilter(simImg, h, 'replicate');
            simImg = 0.35 * simImg + 0.65 * blurred;

            % 2. Dark scattered blot scotomas (retinal hemorrhages)
            numScotomas = 14 + round(8 * t);
            rng(101); % Deterministic seed for stable positioning across frames
            scotomaMask = ones(H, W);
            for s = 1:numScotomas
                sx = round(W * (0.12 + 0.68 * rand()));
                sy = round(H * (0.15 + 0.62 * rand()));
                sRad = (22 + 30 * rand()) * (0.75 + 0.45 * t);
                sDist = sqrt((X - sx).^2 + (Y - sy).^2);
                spot = exp(- (sDist / sRad).^2);
                scotomaMask = scotomaMask .* (1.0 - 0.86 * spot);
            end

            % 3. Smooth animated drifting vitreous floaters
            floaterOffsetX = round(25 * sin(frameNum * 0.07));
            floaterOffsetY = round(18 * cos(frameNum * 0.05));
            fx1 = round(W * 0.38) + floaterOffsetX;
            fy1 = round(H * 0.35) + floaterOffsetY;
            fDist1 = sqrt((X - fx1).^2 + (Y - fy1).^2);
            floater1 = exp(- (fDist1 / 14.0).^2);

            fx2 = round(W * 0.52) - round(floaterOffsetX * 0.7);
            fy2 = round(H * 0.48) + round(floaterOffsetY * 0.8);
            fDist2 = sqrt((X - fx2).^2 + (Y - fy2).^2);
            floater2 = exp(- (fDist2 / 18.0).^2);

            scotomaMask = scotomaMask .* (1.0 - 0.80 * floater1) .* (1.0 - 0.75 * floater2);
            simImg = simImg .* repmat(scotomaMask, [1, 1, 3]);

        case 5 % Stage 4 (Proliferative DR - Massive Vitreous Hemorrhage Curtain)
            % 1. Heavy blur and significant light attenuation
            h = fspecial('gaussian', [39 39], 18.0);
            blurred = imfilter(simImg, h, 'replicate');
            simImg = 0.15 * simImg + 0.85 * blurred;

            % 2. Undulating descending vitreous bleed curtain
            curtainT = min(1.0, 0.35 + 0.65 * t);
            curtainY = H * (0.20 + 0.50 * curtainT) + 35 * sin(X * 0.012 + frameNum * 0.06);
            curtainMask = 1.0 ./ (1.0 + exp(- (Y - curtainY) / 28.0));

            % 3. Dense central obscuration
            centralBleed = exp(- (distFromCenter / (W * 0.36)).^2);
            totalOcclusion = min(1.0, (1.0 - curtainMask * 0.92) .* (1.0 - 0.94 * centralBleed * curtainT));
            totalOcclusion3 = repmat(totalOcclusion, [1, 1, 3]);

            % 4. Dark reddish-black tinge from intraocular hemorrhage
            simImg = simImg .* totalOcclusion3;
            simImg(:,:,1) = simImg(:,:,1) + 0.06 * (1.0 - totalOcclusion);
            simImg = min(1.0, simImg * (1.0 - 0.40 * curtainT));
    end

    simImg = uint8(min(1.0, max(0.0, simImg)) * 255.0);
end

% -------------------------------------------------------------------------
% Composite Picture-in-Picture (PiP) Retinal Inset in Top-Right Corner
% -------------------------------------------------------------------------
function frameOut = composite_retinal_pip(frameImg, fundusImg, meta, frameNum)
    [H, W, ~] = size(frameImg);
    frameOut = frameImg;

    insetW = 210;
    insetH = 210;
    insetX = W - insetW - 25;
    insetY = 32;

    % 1. Draw outer glowing border
    accentColor = uint8(meta.color * 255);
    borderPad = 4;
    bX1 = max(1, insetX - borderPad);
    bX2 = min(W, insetX + insetW + borderPad);
    bY1 = max(1, insetY - 24); % includes header tab
    bY2 = min(H, insetY + insetH + borderPad);

    % Background container behind inset
    for c = 1:3
        frameOut(bY1:bY2, bX1:bX2, c) = uint8(15);
    end

    % 2. Composite fundus image
    fResized = imresize(fundusImg, [insetH, insetW]);

    % Natural fundus image without artificial scanning lines
    frameOut(insetY:(insetY+insetH-1), insetX:(insetX+insetW-1), :) = fResized;

    % 3. Border outline
    for c = 1:3
        frameOut(bY1:min(H, bY1+2), bX1:bX2, c) = accentColor(c);
        frameOut(max(1, bY2-2):bY2, bX1:bX2, c) = accentColor(c);
        frameOut(bY1:bY2, bX1:min(W, bX1+2), c) = accentColor(c);
        frameOut(bY1:bY2, max(1, bX2-2):bX2, c) = accentColor(c);
    end

    % 4. Top Header Label on PiP: "PATIENT RETINA SCAN"
    try
        hdrStr = sprintf('PATIENT RETINA [GRADE %d]', meta.grade);
        frameOut = insertText(frameOut, [insetX + 6, insetY - 22], hdrStr, ...
            'FontSize', 11, 'TextColor', [255, 255, 255], 'BoxOpacity', 0, 'Font', 'Arial Bold');
    catch
    end
end

% -------------------------------------------------------------------------
% Draw Broadcast Lower-Third HUD Banner (1280 x 720)
% -------------------------------------------------------------------------
function frameOut = draw_hud_overlay_hd(frameImg, meta, frameNum, totalFrames)
    [H, W, ~] = size(frameImg);
    frameOut = frameImg;

    hudH = 92;
    hudY = H - hudH;

    % Semi-transparent dark navy HUD background
    hudAlpha = 0.90;
    hudColor = [10, 20, 38];
    for c = 1:3
        channel = double(frameOut(hudY:H, 1:W, c));
        frameOut(hudY:H, 1:W, c) = uint8(channel * (1 - hudAlpha) + hudColor(c) * hudAlpha);
    end

    % Colored progress indicator line at top of HUD
    progW = round(W * (frameNum / totalFrames));
    accentColor = uint8(meta.color * 255);
    for c = 1:3
        frameOut(hudY:hudY+3, 1:progW, c) = accentColor(c);
    end

    % Render HUD text
    txtLine1 = sprintf('%s    |    %s', meta.name, meta.acuity);
    txtLine2 = sprintf('Triage: %s    |    %s', meta.urgency, meta.desc);

    try
        frameOut = insertText(frameOut, [25, hudY + 14], txtLine1, ...
            'FontSize', 17, 'TextColor', [255, 255, 255], 'BoxOpacity', 0, 'Font', 'Arial Bold');
        frameOut = insertText(frameOut, [25, hudY + 50], txtLine2, ...
            'FontSize', 13, 'TextColor', [215, 228, 248], 'BoxOpacity', 0, 'Font', 'Arial');
    catch
    end
end

% -------------------------------------------------------------------------
% Generate 5-Stage Static Montage Card for PDF / Dashboard
% -------------------------------------------------------------------------
function export_montage_card_hd(stagePreviews, stages, outputPath)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [50, 50, 1200, 340]);

    % Header banner
    annotation(fig, 'rectangle', [0.03, 0.85, 0.94, 0.12], ...
        'FaceColor', [0.06, 0.16, 0.35], 'EdgeColor', 'none');
    annotation(fig, 'textbox', [0.04, 0.87, 0.92, 0.08], ...
        'String', 'DIABETIC RETINOPATHY: 5-STAGE VISION LOSS EMPATHY SIMULATION', ...
        'Color', 'w', 'FontSize', 13, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');

    wTile = 0.178;
    hTile = 0.58;
    spacing = 0.012;
    startX = 0.035;
    yPos = 0.22;

    for i = 1:5
        ax = axes(fig, 'Position', [startX + (i-1)*(wTile + spacing), yPos, wTile, hTile]);
        if ~isempty(stagePreviews{i})
            imshow(stagePreviews{i}, 'Parent', ax);
        end
        title(ax, sprintf('Grade %d', stages{i}.grade), 'FontSize', 10, 'FontWeight', 'bold', ...
            'Color', stages{i}.color);

        % Label beneath tile
        annotation(fig, 'textbox', [startX + (i-1)*(wTile + spacing), 0.05, wTile, 0.14], ...
            'String', {sprintf('\\bf%s\\rm', stages{i}.acuity), stages{i}.urgency}, ...
            'FontSize', 8, 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
            'Interpreter', 'tex');
    end

    drawnow;
    try
        exportgraphics(fig, outputPath, 'Resolution', 180);
    catch
        saveas(fig, outputPath);
    end
    close(fig);
end

% -------------------------------------------------------------------------
% Create Authentic High-Definition Examination Room Scene (1280 x 720)
% -------------------------------------------------------------------------
function scene = create_realistic_scene_hd(W, H)
    % Render rich scene using offscreen MATLAB figure
    fig = figure('Visible', 'off', 'Color', [0.94, 0.95, 0.97], 'Position', [0, 0, W, H]);
    ax = axes(fig, 'Position', [0, 0, 1, 1]);
    hold(ax, 'on');
    axis(ax, [0 W 0 H]);
    axis(ax, 'off');

    % 1. Wall background & floor
    rectangle('Position', [0, round(H*0.25), W, round(H*0.75)], 'FaceColor', [0.92, 0.93, 0.95], 'EdgeColor', 'none');
    rectangle('Position', [0, 0, W, round(H*0.25)], 'FaceColor', [0.70, 0.58, 0.45], 'EdgeColor', 'none'); % wooden floor

    % 2. Window looking out onto rural village landscape (Top right)
    winX = round(W * 0.65);
    winY = round(H * 0.40);
    winW = round(W * 0.30);
    winH = round(H * 0.52);
    % Sky & green fields
    rectangle('Position', [winX, winY + round(winH*0.45), winW, round(winH*0.55)], 'FaceColor', [0.55, 0.78, 0.95], 'EdgeColor', 'none');
    rectangle('Position', [winX, winY, winW, round(winH*0.45)], 'FaceColor', [0.38, 0.68, 0.35], 'EdgeColor', 'none');
    % Road in window
    plot([winX + winW*0.35, winX + winW*0.65], [winY, winY + winH*0.45], 'Color', [0.45, 0.45, 0.48], 'LineWidth', 18);
    % Window frame
    rectangle('Position', [winX, winY, winW, winH], 'EdgeColor', [0.25, 0.30, 0.40], 'LineWidth', 6);
    plot([winX + winW*0.5, winX + winW*0.5], [winY, winY + winH], 'Color', [0.25, 0.30, 0.40], 'LineWidth', 4);
    plot([winX, winX + winW], [winY + winH*0.5, winY + winH*0.5], 'Color', [0.25, 0.30, 0.40], 'LineWidth', 4);

    % 3. Snellen Eye Chart on Wall (Left side)
    chX = round(W * 0.05);
    chY = round(H * 0.16);
    chW = round(W * 0.28);
    chH = round(H * 0.78);
    rectangle('Position', [chX, chY, chW, chH], 'FaceColor', 'w', 'EdgeColor', [0.3, 0.35, 0.4], 'LineWidth', 3);

    text(chX + chW*0.5, chY + chH*0.94, 'S N E L L E N   C H A R T', 'FontSize', 11, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Color', [0.1, 0.15, 0.25]);

    % Snellen Letters
    text(chX + chW*0.5, chY + chH*0.80, 'E', 'FontSize', 48, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.65, 'F   P', 'FontSize', 32, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.52, 'T   O   Z', 'FontSize', 24, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.41, 'L   P   E   D', 'FontSize', 18, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.32, 'P   E   C   F   D', 'FontSize', 14, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.24, 'E   D   F   C   Z   P', 'FontSize', 11, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.17, 'F  E  L  O  P  Z  D', 'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');
    text(chX + chW*0.5, chY + chH*0.11, 'D  E  F  P  O  T  E  C', 'FontSize', 7.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontName', 'Courier New');

    % Red & green balance lines
    plot([chX + 15, chX + chW - 15], [chY + chH*0.20, chY + chH*0.20], 'Color', [0.85, 0.15, 0.15], 'LineWidth', 3);
    plot([chX + 15, chX + chW - 15], [chY + chH*0.14, chY + chH*0.14], 'Color', [0.15, 0.65, 0.25], 'LineWidth', 3);

    % 4. Consultation Desk (Center-Right)
    deskX = round(W * 0.36);
    deskY = round(H * 0.12);
    deskW = round(W * 0.58);
    deskH = round(H * 0.44);
    rectangle('Position', [deskX, deskY, deskW, deskH], 'FaceColor', [0.88, 0.82, 0.74], ...
        'EdgeColor', [0.55, 0.45, 0.38], 'LineWidth', 3);

    % Prescription / Health Card on Desk
    rxX = deskX + 25;
    rxY = deskY + 25;
    rxW = round(deskW * 0.62);
    rxH = round(deskH * 0.84);
    rectangle('Position', [rxX, rxY, rxW, rxH], 'FaceColor', 'w', 'EdgeColor', [0.35, 0.50, 0.75], 'LineWidth', 2);

    % Rx Header
    rectangle('Position', [rxX, rxY + rxH - 34, rxW, 34], 'FaceColor', [0.08, 0.25, 0.55], 'EdgeColor', 'none');
    text(rxX + 15, rxY + rxH - 18, 'TELE-RETINOPATHY CLINICAL PRESCRIPTION', 'Color', 'w', ...
        'FontSize', 10.5, 'FontWeight', 'bold');

    % Rx Content
    text(rxX + 15, rxY + rxH - 52, 'Patient: Ramesh Kumar  |  Age: 58 M  |  PHC Mulbagal #04', ...
        'FontSize', 8.5, 'FontWeight', 'bold', 'Color', [0.15, 0.20, 0.30]);
    text(rxX + 15, rxY + rxH - 74, 'Fasting Blood Sugar: 188 mg/dL   |   HbA1c: 9.4% (Uncontrolled)', ...
        'FontSize', 8.5, 'Color', [0.80, 0.15, 0.15], 'FontWeight', 'bold');

    text(rxX + 15, rxY + rxH - 104, 'PRESCRIPTION MEDICATIONS (Rx):', 'FontSize', 8.5, 'FontWeight', 'bold', ...
        'Color', [0.10, 0.35, 0.20]);
    text(rxX + 20, rxY + rxH - 124, '1. Tab. Metformin 500mg  --  1 tablet twice daily after meals', ...
        'FontSize', 8, 'Color', [0.15, 0.20, 0.30]);
    text(rxX + 20, rxY + rxH - 144, '2. Tab. Atorvastatin 20mg  --  1 tablet at bedtime', ...
        'FontSize', 8, 'Color', [0.15, 0.20, 0.30]);
    text(rxX + 20, rxY + rxH - 164, '3. Dilated Fundus Examination  --  Urgent Specialist Referral', ...
        'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.80, 0.20, 0.10]);

    text(rxX + 15, rxY + 18, '* Warning: Report any sudden blurring, wavy text, or floaters immediately.', ...
        'FontSize', 7, 'FontAngle', 'italic', 'Color', [0.45, 0.50, 0.55]);

    % Wall Clock
    clockX = round(W * 0.48);
    clockY = round(H * 0.72);
    clockR = 48;
    rectangle('Position', [clockX - clockR, clockY - clockR, clockR*2, clockR*2], ...
        'Curvature', [1 1], 'FaceColor', 'w', 'EdgeColor', [0.2, 0.25, 0.35], 'LineWidth', 3);
    % Clock Hands (10:10)
    plot([clockX, clockX - 20], [clockY, clockY + 22], 'Color', [0.1, 0.1, 0.1], 'LineWidth', 3.5);
    plot([clockX, clockX + 28], [clockY, clockY + 24], 'Color', [0.1, 0.1, 0.1], 'LineWidth', 2.5);
    plot(clockX, clockY, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);

    drawnow;
    frame = getframe(ax);
    scene = frame.cdata;
    close(fig);

    % Guarantee exact target dimensions
    if size(scene, 1) ~= H || size(scene, 2) ~= W
        scene = imresize(scene, [H, W]);
    end
end
