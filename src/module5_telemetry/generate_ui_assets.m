function generate_ui_assets()
% GENERATE_UI_ASSETS Generates photorealistic / sleek vector graphic banners
% for RETINACARE AI GUI:
%   1. assets/hero_banner.png (Morning mist mountain landscape with Retinacare AI branding)
%   2. assets/village_sidebar.png (Subtle rural Indian village illustration)
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    baseDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    assetsDir = fullfile(baseDir, 'assets');
    if ~exist(assetsDir, 'dir'), mkdir(assetsDir); end

    % ---------------------------------------------------------------------
    % 1. Hero Banner (1235 x 74 px @ 2x = 2470 x 148 px)
    % ---------------------------------------------------------------------
    W = 2470; H = 148;
    fig = figure('Visible', 'off', 'Color', [0.88, 0.92, 0.97], 'Position', [100, 100, W, H]);
    ax = axes(fig, 'Position', [0, 0, 1, 1]);
    hold(ax, 'on');
    axis(ax, [0 W 0 H]);
    axis(ax, 'off');

    % Sky gradient (Soft morning sky from pale cyan-blue to white)
    [X, Y] = meshgrid(linspace(0, 1, W), linspace(0, 1, H));
    skyR = 0.82 + 0.14 * (1 - Y) + 0.03 * X;
    skyG = 0.88 + 0.09 * (1 - Y) + 0.02 * X;
    skyB = 0.95 + 0.04 * (1 - Y);
    skyImg = cat(3, skyR, skyG, skyB);
    image(ax, [0 W], [0 H], flipud(skyImg));

    % Distant mountain silhouette 1 (faint blue-gray)
    xPts = linspace(0, W, 400);
    yMtn1 = 30 + 45 * sin(xPts * 0.003) + 20 * sin(xPts * 0.007 + 1.2) + 15 * cos(xPts * 0.012);
    fill(ax, [xPts, W, 0], [yMtn1, 0, 0], [0.72, 0.79, 0.88], 'EdgeColor', 'none', 'FaceAlpha', 0.65);

    % Distant mountain silhouette 2 (richer blue-slate)
    yMtn2 = 18 + 32 * sin(xPts * 0.004 + 2.1) + 18 * cos(xPts * 0.009) + 10 * sin(xPts * 0.015);
    fill(ax, [xPts, W, 0], [yMtn2, 0, 0], [0.60, 0.68, 0.78], 'EdgeColor', 'none', 'FaceAlpha', 0.55);

    % Subtle pine / tree ridge at horizon
    yRidge = 8 + 10 * sin(xPts * 0.008 + 0.5) + 6 * cos(xPts * 0.02);
    fill(ax, [xPts, W, 0], [yRidge, 0, 0], [0.45, 0.54, 0.65], 'EdgeColor', 'none', 'FaceAlpha', 0.45);

    % Left Brand Text: "Retinacare AI"
    text(ax, 70, 92, 'Retinacare AI', 'FontSize', 25, 'FontWeight', 'bold', ...
        'Color', [0.06, 0.14, 0.30], 'FontName', 'Segoe UI');
    text(ax, 70, 44, 'Early Detection   |   Better Treatment   |   Brighter Futures', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.20, 0.32, 0.48], 'FontName', 'Segoe UI');

    % Right Script Tagline: "Healthy Eyes, Stronger Communities"
    text(ax, W - 90, 75, 'Healthy Eyes,', 'FontSize', 22, 'FontAngle', 'italic', ...
        'FontWeight', 'bold', 'Color', [0.22, 0.35, 0.52], 'FontName', 'Georgia', 'HorizontalAlignment', 'right');
    text(ax, W - 90, 32, 'Stronger Communities', 'FontSize', 22, 'FontAngle', 'italic', ...
        'FontWeight', 'bold', 'Color', [0.22, 0.35, 0.52], 'FontName', 'Georgia', 'HorizontalAlignment', 'right');

    drawnow;
    heroPath = fullfile(assetsDir, 'hero_banner.png');
    exportgraphics(fig, heroPath, 'Resolution', 150);
    close(fig);
    fprintf('  [OK] Generated hero banner: %s\n', heroPath);

    % ---------------------------------------------------------------------
    % 2. Village Sidebar Footer Illustration (175 x 110 px @ 2x = 350 x 220 px)
    % ---------------------------------------------------------------------
    W2 = 350; H2 = 220;
    fig2 = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, W2, H2]);
    ax2 = axes(fig2, 'Position', [0, 0, 1, 1]);
    hold(ax2, 'on');
    axis(ax2, [0 W2 0 H2]);
    axis(ax2, 'off');

    % Soft gradient sky at bottom
    rectangle(ax2, 'Position', [0, 0, W2, H2], 'FaceColor', [0.94, 0.96, 0.99], 'EdgeColor', 'none');

    % Distant hills
    xHills = linspace(0, W2, 100);
    yHills = 80 + 25 * sin(xHills * 0.02 + 0.4);
    fill(ax2, [xHills, W2, 0], [yHills, 0, 0], [0.82, 0.88, 0.95], 'EdgeColor', 'none');

    % Stylized houses
    % House 1
    rectangle(ax2, 'Position', [40, 60, 50, 38], 'FaceColor', [0.72, 0.78, 0.88], 'EdgeColor', 'none');
    fill(ax2, [35, 65, 95], [98, 120, 98], [0.60, 0.68, 0.80], 'EdgeColor', 'none'); % roof
    % House 2
    rectangle(ax2, 'Position', [110, 52, 60, 44], 'FaceColor', [0.75, 0.80, 0.90], 'EdgeColor', 'none');
    fill(ax2, [105, 140, 175], [96, 125, 96], [0.58, 0.65, 0.78], 'EdgeColor', 'none'); % roof

    % Stylized trees
    % Tree 1
    plot(ax2, [220, 220], [45, 95], 'Color', [0.65, 0.70, 0.78], 'LineWidth', 4);
    viscircles(ax2, [220, 105], 22, 'Color', [0.68, 0.76, 0.85], 'EnhanceVisibility', false);
    % Tree 2
    plot(ax2, [270, 270], [42, 85], 'Color', [0.65, 0.70, 0.78], 'LineWidth', 3);
    viscircles(ax2, [270, 95], 18, 'Color', [0.70, 0.78, 0.88], 'EnhanceVisibility', false);

    % Tagline text
    text(ax2, W2/2, 28, 'Bridging the gap', 'FontSize', 10, 'FontWeight', 'bold', ...
        'Color', [0.35, 0.45, 0.60], 'FontName', 'Segoe UI', 'HorizontalAlignment', 'center');
    text(ax2, W2/2, 12, 'for clearer tomorrows', 'FontSize', 9.5, 'FontAngle', 'italic', ...
        'Color', [0.45, 0.55, 0.68], 'FontName', 'Segoe UI', 'HorizontalAlignment', 'center');

    drawnow;
    villagePath = fullfile(assetsDir, 'village_sidebar.png');
    exportgraphics(fig2, villagePath, 'Resolution', 150);
    close(fig2);
    fprintf('  [OK] Generated village sidebar graphic: %s\n', villagePath);

    % ---------------------------------------------------------------------
    % 3. Retinacare Eye Icon Logo (80 x 80 px @ 2x = 160 x 160 px)
    % ---------------------------------------------------------------------
    W3 = 160; H3 = 160;
    fig3 = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, W3, H3]);
    ax3 = axes(fig3, 'Position', [0, 0, 1, 1]);
    hold(ax3, 'on');
    axis(ax3, [0 W3 0 H3]);
    axis(ax3, 'off');

    % Outer eye almond shape
    tPts = linspace(0, pi, 100);
    xEye = W3/2 + 65 * cos(tPts);
    yEyeTop = H3/2 + 38 * sin(tPts);
    yEyeBot = H3/2 - 38 * sin(tPts);
    fill(ax3, [xEye, fliplr(xEye)], [yEyeTop, fliplr(yEyeBot)], [0.92, 0.95, 1.0], ...
        'EdgeColor', [0.14, 0.38, 0.92], 'LineWidth', 4);

    % Iris
    viscircles(ax3, [W3/2, H3/2], 26, 'Color', [0.10, 0.30, 0.75], 'LineWidth', 3);
    % Pupil
    th = linspace(0, 2*pi, 60);
    fill(ax3, W3/2 + 15*cos(th), H3/2 + 15*sin(th), [0.08, 0.18, 0.45], 'EdgeColor', 'none');
    % Light reflection spark
    fill(ax3, W3/2 - 5 + 4*cos(th), H3/2 + 5 + 4*sin(th), [1.0, 1.0, 1.0], 'EdgeColor', 'none');

    drawnow;
    logoPath = fullfile(assetsDir, 'retinacare_logo.png');
    exportgraphics(fig3, logoPath, 'Resolution', 150);
    close(fig3);
    fprintf('  [OK] Generated logo graphic: %s\n', logoPath);
end
