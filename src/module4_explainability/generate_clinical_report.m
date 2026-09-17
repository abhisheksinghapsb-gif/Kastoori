function reportPath = generate_clinical_report(patientData, outputPdfPath)
% GENERATE_CLINICAL_REPORT Assembles an automated, standardized single-page
% clinical decision-support report for rapid (<30 second) ophthalmologist validation.
%
% Features:
%   - Multi-panel visual diagnostic grid (Original, Enhanced, Vessels, Lesions, Grad-CAM)
%   - Prominent color-coded Referral Urgency Badge
%   - Quantitative lesion & vascular biomarkers
%   - High-fidelity single-page PDF generation via exportgraphics
%
% Syntax:
%   reportPath = generate_clinical_report(patientData)
%   reportPath = generate_clinical_report(patientData, outputPdfPath)
%
% Inputs:
%   patientData   - Struct containing clinical data:
%                   .patientId    : String (e.g. 'IND-PHC-2026-0481')
%                   .age          : Integer (e.g. 54)
%                   .gender       : String (e.g. 'Female')
%                   .phcCenter    : String (e.g. 'PHC Mulbagal, Kolar District')
%                   .operatorId   : String (e.g. 'ASHA-ANM-104')
%                   .screeningDate: String (e.g. '04-Sep-2026')
%                   .imgOriginal  : Original RGB fundus
%                   .imgEnhanced  : CLAHE-enhanced fundus
%                   .vesselMask   : Binary vessel tree
%                   .lesionOverlay: Lesion highlight image
%                   .gradCamOverlay: Grad-CAM blended heatmap image
%                   .iqaResult    : Struct from evaluate_image_quality
%                   .vesselDensity: Scalar percentage
%                   .lesionStats  : Struct from detect_lesions
%                   .prediction   : Struct from classify_dr
%   outputPdfPath - (Optional) Destination PDF path (default: 'Doctor_Screening_Report.pdf')
%
% Outputs:
%   reportPath    - Absolute filepath to generated PDF
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 2 || isempty(outputPdfPath)
        outputPdfPath = fullfile(pwd, 'Doctor_Screening_Report.pdf');
    end

    % Set default patient metadata if omitted
    if ~isfield(patientData, 'patientId'),     patientData.patientId     = 'IND-KA-PHC-8921'; end
    if ~isfield(patientData, 'age'),           patientData.age           = 58; end
    if ~isfield(patientData, 'gender'),        patientData.gender        = 'Female'; end
    if ~isfield(patientData, 'phcCenter'),     patientData.phcCenter     = 'PHC Devanahalli, Rural Cluster 4'; end
    if ~isfield(patientData, 'operatorId'),    patientData.operatorId    = 'ASHA Worker #108'; end
    if ~isfield(patientData, 'screeningDate'), patientData.screeningDate = datestr(now, 'dd-mmm-yyyy HH:MM'); end

    % Create invisible figure for clean PDF rendering
    fig = figure('Name', 'Doctor Screening Report', ...
        'Color', 'w', ...
        'Units', 'inches', ...
        'Position', [0.5, 0.5, 8.5, 11], ... % Standard US Letter 8.5 x 11 in
        'Visible', 'off');

    % ---------------------------------------------------------------------
    % Section 1: Header & Facility Branding Banner
    % ---------------------------------------------------------------------
    % Top title banner
    annotation(fig, 'rectangle', [0.05, 0.90, 0.90, 0.08], ...
        'FaceColor', [0.08, 0.22, 0.45], 'EdgeColor', 'none');
    
    annotation(fig, 'textbox', [0.06, 0.935, 0.88, 0.04], ...
        'String', 'NATIONAL TELE-OPHTHALMOLOGY AI SCREENING PROGRAM', ...
        'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'left');

    annotation(fig, 'textbox', [0.06, 0.905, 0.88, 0.03], ...
        'String', 'Explainable AI Clinical Decision Support System | Rural PHC Triage (SIH PS 26038)', ...
        'Color', [0.85, 0.92, 1.0], 'FontSize', 9.5, ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'left');

    % Patient Details Panel (Box)
    annotation(fig, 'rectangle', [0.05, 0.805, 0.90, 0.085], ...
        'FaceColor', [0.96, 0.97, 0.99], 'EdgeColor', [0.80, 0.85, 0.92], 'LineWidth', 1);

    % Fetch or compute eye orientation, ETDRS audit, and longitudinal EHR if not provided
    if ~isfield(patientData, 'eyeInfo') || isempty(patientData.eyeInfo)
        patientData.eyeInfo = detect_eye_orientation(patientData.imgOriginal, patientData.imgEnhanced, patientData.vesselMask);
    end
    if ~isfield(patientData, 'etdrsReport') || isempty(patientData.etdrsReport)
        patientData.etdrsReport = audit_etdrs_quadrants(patientData.imgOriginal, patientData.imgEnhanced, ...
            patientData.vesselMask, patientData.lesionStats, patientData.eyeInfo);
    end
    if ~isfield(patientData, 'ehrRecord') || isempty(patientData.ehrRecord)
        patientData.ehrRecord = patient_ehr_database(patientData.patientId, patientData.patientName);
    end

    eye = patientData.eyeInfo;
    etdrs = patientData.etdrsReport;
    ehr = patientData.ehrRecord;

    patientMetaStr = {
        sprintf('\\bfPatient ID:\\rm  %s        \\bfAge/Sex:\\rm  %d / %s        \\bfScreening Date:\\rm  %s', ...
            patientData.patientId, patientData.age, patientData.gender, patientData.screeningDate), ...
        sprintf('\\bfPHC Health Centre:\\rm  %s        \\bfFrontline Operator:\\rm  %s', ...
            patientData.phcCenter, patientData.operatorId), ...
        sprintf('\\bfEye Evaluated:\\rm  \\bf%s\\rm (Nasal: %s)        \\bfQA Usability Score:\\rm  %d/100 [%s]', ...
            eye.eyeName, eye.nasalSide, patientData.iqaResult.qualityScore, patientData.iqaResult.status)
    };
    annotation(fig, 'textbox', [0.065, 0.805, 0.87, 0.082], ...
        'String', patientMetaStr, ...
        'Color', [0.08, 0.12, 0.22], ...
        'FontSize', 9, 'EdgeColor', 'none', 'Interpreter', 'tex');

    % ---------------------------------------------------------------------
    % Section 2: AI Triage Recommendation & Urgency Badge
    % ---------------------------------------------------------------------
    pred = patientData.prediction;
    if pred.grade >= 4 || pred.referableScore >= 0.75
        badgeColor = [0.85, 0.12, 0.15]; % Urgent Red
        badgeTitle = 'URGENT SPECIALIST REFERRAL REQUIRED (<48 HOURS)';
        badgeDesc  = 'High risk of irreversible vision loss. Tertiary Vitreoretinal evaluation mandatory.';
    elseif pred.isReferable
        badgeColor = [0.92, 0.55, 0.05]; % Amber Warning
        badgeTitle = 'SECONDARY OPHTHALMOLOGY REFERRAL (WITHIN 30 DAYS)';
        badgeDesc  = 'Clinically significant Diabetic Retinopathy detected. Comprehensive dilated fundus exam advised.';
    else
        badgeColor = [0.12, 0.65, 0.28]; % Green Pass
        badgeTitle = 'NON-REFERABLE: ROUTINE ANNUAL SCREENING';
        badgeDesc  = 'No sight-threatening diabetic retinopathy detected. Schedule follow-up in 12 months at PHC.';
    end

    % Triage Badge Box
    annotation(fig, 'rectangle', [0.05, 0.705, 0.90, 0.085], ...
        'FaceColor', badgeColor, 'EdgeColor', 'none');
    annotation(fig, 'textbox', [0.06, 0.745, 0.88, 0.04], ...
        'String', sprintf('TRIAGE ACTION:  %s', badgeTitle), ...
        'Color', 'w', 'FontSize', 11.5, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');
    annotation(fig, 'textbox', [0.06, 0.71, 0.88, 0.035], ...
        'String', badgeDesc, ...
        'Color', [1.0, 1.0, 0.95], 'FontSize', 9.5, ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % ---------------------------------------------------------------------
    % Section 3: Multi-Panel Visual Diagnostic Grid
    % ---------------------------------------------------------------------
    % 5 image views: [Original, Enhanced Green, Vessels, Lesion Overlay, Grad-CAM]
    axW = 0.165;
    axH = 0.165;
    axY = 0.505;
    spacing = 0.016;
    startX = 0.05;

    % Subplot 1: Original Fundus
    ax1 = axes(fig, 'Position', [startX, axY, axW, axH]);
    imshow(patientData.imgOriginal, 'Parent', ax1);
    title(ax1, sprintf('1. Raw Fundus (%s)', eye.eyeCode), 'FontSize', 8.5, 'FontWeight', 'bold');

    % Subplot 2: Enhanced Green (Rayleigh CLAHE)
    ax2 = axes(fig, 'Position', [startX + (axW + spacing)*1, axY, axW, axH]);
    imshow(patientData.imgEnhanced, 'Parent', ax2);
    title(ax2, '2. Enhanced Green', 'FontSize', 8.5, 'FontWeight', 'bold');

    % Subplot 3: Segmented Vasculature
    ax3 = axes(fig, 'Position', [startX + (axW + spacing)*2, axY, axW, axH]);
    imshow(patientData.vesselMask, 'Parent', ax3);
    title(ax3, '3. Retinal Vessels', 'FontSize', 8.5, 'FontWeight', 'bold');

    % Subplot 4: Clean Clinical Lesion Detections
    ax4 = axes(fig, 'Position', [startX + (axW + spacing)*3, axY, axW, axH]);
    imshow(etdrs.annotatedOverlay, 'Parent', ax4);
    title(ax4, '4. Lesion Detections', 'FontSize', 9, 'FontWeight', 'bold', 'FontName', 'Segoe UI', 'Color', [0.04, 0.10, 0.25]);

    % Subplot 5: Grad-CAM Heatmap
    ax5 = axes(fig, 'Position', [startX + (axW + spacing)*4, axY, axW, axH]);
    imshow(patientData.gradCamOverlay, 'Parent', ax5);
    title(ax5, '5. Grad-CAM XAI', 'FontSize', 9, 'FontWeight', 'bold', 'FontName', 'Segoe UI', 'Color', [0.04, 0.10, 0.25]);

    % Visual legend under images (High Contrast, Clean)
    annotation(fig, 'textbox', [0.05, 0.465, 0.90, 0.03], ...
        'String', 'Legend: [Yellow]: Hard Exudates  |  [Ruby Red]: Microaneurysms & Hemorrhages  |  [Heatmap]: Deep Feature Attention (Grad-CAM)', ...
        'FontSize', 8.5, 'FontWeight', 'bold', 'FontName', 'Segoe UI', 'Color', [0.05, 0.08, 0.16], ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % ---------------------------------------------------------------------
    % Section 4: Quantitative Biomarkers & Diagnostic Probability Distribution
    % ---------------------------------------------------------------------
    % Left Panel: Quantitative Biomarkers & ETDRS Audit Table
    annotation(fig, 'rectangle', [0.05, 0.198, 0.45, 0.255], ...
        'FaceColor', [0.98, 0.98, 0.99], 'EdgeColor', [0.82, 0.85, 0.88], 'LineWidth', 1);

    annotation(fig, 'textbox', [0.06, 0.422, 0.43, 0.026], ...
        'String', 'QUANTITATIVE BIOMARKERS & ETDRS 4-2-1 CLINICAL AUDIT', ...
        'FontSize', 8.8, 'FontWeight', 'bold', 'Color', [0.08, 0.22, 0.45], 'EdgeColor', 'none');

    distStr = 'None (Clear Macula)';
    if ~isnan(etdrs.minDistFoveaUm)
        distStr = sprintf('%.0f \\mum (%.2f DD)', etdrs.minDistFoveaUm, etdrs.minDistFoveaDD);
    end

    biomarkerStr = {
        sprintf('\\bfETDRS Staging:\\rm  %s', etdrs.etdrsStage), ...
        sprintf('\\bfETDRS 4-2-1 Rule:\\rm  4Q Hemo: [%d/4]  |  VB Quads: [%d]  |  IRMA: [%d]', ...
            etdrs.quadsWithSevereHemo, etdrs.beadingQuads, etdrs.irmaQuads), ...
        sprintf('\\bfDistance to Fovea (CSME):\\rm  %s — %s', distStr, etdrs.csmeTier), ...
        sprintf('\\bfHard Exudates (Bright):\\rm  %d clusters (%d px area)', ...
            patientData.lesionStats.exudateCount, patientData.lesionStats.exudateArea), ...
        sprintf('\\bfMicroaneurysms / Blot Hemo:\\rm  %d MAs  |  %d Hemorrhages', ...
            patientData.lesionStats.microaneurysmCount, patientData.lesionStats.hemorrhageCount), ...
        sprintf('\\bfVascular Density:\\rm  %.2f%% FOV    \\bfOptic Disc:\\rm  [%d, %d] (%s)', ...
            patientData.vesselDensity, eye.odCenter(1), eye.odCenter(2), eye.nasalSide), ...
        sprintf('\\bfSystemic EHR Profile:\\rm  T2D: %d yrs | Last HbA1c: %.1f%% | BP: %s', ...
            ehr.diabetesDurationYears, ehr.lastHbA1c, ehr.bloodPressure), ...
        sprintf('\\bfLast Encounter Record:\\rm  %s (Grade: %s)', ...
            ehr.lastVisitDate, ehr.visits(1).drGrade)
    };
    annotation(fig, 'textbox', [0.06, 0.202, 0.43, 0.218], ...
        'String', biomarkerStr, ...
        'Color', [0.08, 0.12, 0.22], ...
        'FontSize', 8.0, 'EdgeColor', 'none', 'Interpreter', 'tex');

    % Right Panel: AI Class Probabilities Bar Chart
    % Right Panel: AI Class Probabilities Bar Chart
    axBar = axes(fig, 'Position', [0.55, 0.24, 0.39, 0.16]);
    barLabels = {'Grade 0', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4'};
    b = bar(axBar, 0:4, pred.probabilities * 100, 0.55, 'FaceColor', 'flat');
    b.CData(1, :) = [0.10, 0.65, 0.32]; % Grade 0: Green
    b.CData(2, :) = [0.12, 0.60, 0.45]; % Grade 1: Teal
    b.CData(3, :) = [0.92, 0.55, 0.05]; % Grade 2: Amber
    b.CData(4, :) = [0.88, 0.32, 0.08]; % Grade 3: Orange
    b.CData(5, :) = [0.85, 0.12, 0.18]; % Grade 4: Red
    set(axBar, 'Color', 'w', 'XColor', [0.15, 0.20, 0.30], 'YColor', [0.15, 0.20, 0.30]);
    grid(axBar, 'on');
    axBar.GridColor = [0.85, 0.88, 0.92];
    axBar.GridAlpha = 0.8;
    set(axBar, 'XTick', 0:4, 'XTickLabel', barLabels, 'FontSize', 8, 'FontWeight', 'bold');
    ylabel(axBar, 'Probability (%)', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
    title(axBar, sprintf('AI DR Severity: %s (Conf: %.1f%%)', pred.gradeName, pred.confidence * 100), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.08, 0.18, 0.38]);
    ylim(axBar, [0, 105]);

    annotation(fig, 'textbox', [0.55, 0.20, 0.39, 0.03], ...
        'String', sprintf('Referable DR Risk Score P(Grade >= 2) = %.1f%%  (Cutoff: 50.0%%)', pred.referableScore * 100), ...
        'FontSize', 8.5, 'FontWeight', 'bold', 'Color', [0.80, 0.12, 0.15], ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % ---------------------------------------------------------------------
    % Section 5: Tiered Hospital Referral Routing (Clean & Uncrowded)
    % ---------------------------------------------------------------------
    hospital = get_hospital_recommendations(pred.grade, patientData.phcCenter);

    annotation(fig, 'rectangle', [0.05, 0.122, 0.90, 0.068], ...
        'FaceColor', [0.94, 0.96, 1.0], 'EdgeColor', [0.20, 0.45, 0.80], 'LineWidth', 1.2);

    annotation(fig, 'textbox', [0.065, 0.156, 0.87, 0.028], ...
        'String', sprintf('\\bfRECOMMENDED REFERRAL CARE:\\rm  %s  [\\bf%s\\rm]', hospital.facilityName, hospital.tierLevel), ...
        'FontSize', 8.5, 'Color', [0.08, 0.22, 0.50], 'EdgeColor', 'none', 'Interpreter', 'tex');

    hospDetailStr = sprintf('\\bfEst. Distance:\\rm ~%.1f km   |   \\bfTimeline:\\rm %s   |   \\bfHelpline:\\rm %s', ...
        hospital.distanceKm, hospital.urgencyWindow, hospital.helpline);
    annotation(fig, 'textbox', [0.065, 0.130, 0.87, 0.024], ...
        'String', hospDetailStr, 'FontSize', 8.2, 'Color', [0.10, 0.15, 0.25], 'EdgeColor', 'none', 'Interpreter', 'tex');

    % ---------------------------------------------------------------------
    % Section 6: Ophthalmologist Telemedicine Validation Footer
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.032, 0.90, 0.076], ...
        'FaceColor', [0.96, 0.97, 0.98], 'EdgeColor', [0.78, 0.82, 0.88], 'LineWidth', 1);

    annotation(fig, 'textbox', [0.065, 0.082, 0.87, 0.022], ...
        'String', 'OPHTHALMOLOGIST TELEMEDICINE REVIEW & VALIDATION (Target Review Time: under 30 Seconds)', ...
        'Color', [0.08, 0.18, 0.38], ...
        'FontSize', 8.5, 'FontWeight', 'bold', 'EdgeColor', 'none', 'Interpreter', 'none');

    doctorSignStr = {
        'Clinical Impression:  [  ] Concordant with AI diagnosis      [  ] Upgrade Severity      [  ] Downgrade / Artefact', ...
        'Prescribed Action:     [  ] Tele-Consultation Booked       [  ] Anti-VEGF / Laser Referral       [  ] PHC Annual Rescreen', ...
        'Reviewing Ophthalmologist Signature: ...........................................         Date/Time: ...........................................'
    };
    annotation(fig, 'textbox', [0.065, 0.036, 0.87, 0.046], ...
        'String', doctorSignStr, ...
        'Color', [0.08, 0.12, 0.22], ...
        'FontSize', 8, 'EdgeColor', 'none', 'Interpreter', 'none');

    % Save Report to PDF using exportgraphics
    drawnow;
    try
        exportgraphics(fig, outputPdfPath, 'ContentType', 'vector');
        fprintf('  [OK] Clinical Doctor Report successfully exported to PDF: %s\n', outputPdfPath);
    catch
        % Fallback print command
        print(fig, outputPdfPath, '-dpdf', '-r300');
        fprintf('  [OK] Clinical Doctor Report printed to PDF: %s\n', outputPdfPath);
    end

    % Also save a companion PNG image preview of the report
    [pDir, pName, ~] = fileparts(outputPdfPath);
    pngPreviewPath = fullfile(pDir, [pName, '_preview.png']);
    try
        exportgraphics(fig, pngPreviewPath, 'Resolution', 150);
    catch
        try
            saveas(fig, pngPreviewPath);
        catch
            % Companion preview is optional for GUI preview
        end
    end

    close(fig);
    reportPath = outputPdfPath;
end
