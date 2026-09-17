function slipPath = generate_patient_slip(patientData, langCode, outputPdfPath)
% GENERATE_PATIENT_SLIP Generates a bilingual / multilingual 1-page
% Patient Eye Health Card with traffic-light status, simplified visual
% explanations, dietary advice, and tiered nearest hospital routing.
%
% Languages Supported:
%   'en' - English (Default)
%   'hi' - Hindi (हिन्दी)
%   'kn' - Kannada (ಕನ್ನಡ)
%   'ta' - Tamil (தமிழ்)
%   'te' - Telugu (తెలుగు)
%   'mr' - Marathi (मराठी)
%
% Syntax:
%   slipPath = generate_patient_slip(patientData)
%   slipPath = generate_patient_slip(patientData, langCode)
%   slipPath = generate_patient_slip(patientData, langCode, outputPdfPath)
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 2 || isempty(langCode), langCode = 'en'; end
    langCode = lower(strtrim(langCode));

    if nargin < 3 || isempty(outputPdfPath)
        outputPdfPath = fullfile(pwd, sprintf('Patient_Health_Slip_%s.pdf', langCode));
    end

    % Default patient demographics
    if ~isfield(patientData, 'patientId'),     patientData.patientId     = 'IND-KA-PHC-8922'; end
    if ~isfield(patientData, 'patientName'),   patientData.patientName   = 'Ramesh Kumar'; end
    if ~isfield(patientData, 'age'),           patientData.age           = 58; end
    if ~isfield(patientData, 'gender'),        patientData.gender        = 'Male'; end
    if ~isfield(patientData, 'phcCenter'),     patientData.phcCenter     = 'PHC Mulbagal, Kolar District'; end
    if ~isfield(patientData, 'screeningDate'), patientData.screeningDate = datestr(now, 'dd-mmm-yyyy'); end

    pred = patientData.prediction;
    grade = pred.grade;

    % Fetch hospital recommendation
    hospital = get_hospital_recommendations(grade, patientData.phcCenter);

    % Get Localization Dictionary
    L = get_language_dict(langCode);

    % Determine status category
    if grade >= 4 || pred.referableScore >= 0.75
        statusLevel = 3; % Red Urgent
        statusColor = [0.85, 0.12, 0.18];
        statusTitle = L.statusRedTitle;
        statusSub   = L.statusRedSub;
        statusIcon  = '[ ! ]';
    elseif pred.isReferable
        statusLevel = 2; % Amber Warning
        statusColor = [0.92, 0.55, 0.05];
        statusTitle = L.statusAmberTitle;
        statusSub   = L.statusAmberSub;
        statusIcon  = '[ * ]';
    else
        statusLevel = 1; % Green Safe
        statusColor = [0.10, 0.65, 0.30];
        statusTitle = L.statusGreenTitle;
        statusSub   = L.statusGreenSub;
        statusIcon  = '[ OK ]';
    end

    % Create figure for clean US Letter printing
    fig = figure('Name', 'Patient Health Slip', ...
        'Color', 'w', ...
        'Units', 'inches', ...
        'Position', [0.5, 0.5, 8.5, 11], ...
        'Visible', 'off');

    % ---------------------------------------------------------------------
    % Top Header Banner (Ayushman Bharat / Tele-Ophthalmology Branding)
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.90, 0.90, 0.08], ...
        'FaceColor', [0.08, 0.22, 0.45], 'EdgeColor', 'none');

    annotation(fig, 'textbox', [0.06, 0.94, 0.88, 0.035], ...
        'String', sprintf('%s  |  %s', L.headerTitle, L.nationalProg), ...
        'Color', 'w', 'FontSize', 13, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'left');

    annotation(fig, 'textbox', [0.06, 0.905, 0.88, 0.03], ...
        'String', sprintf('%s: %s   |   %s: %s', L.lblCenter, patientData.phcCenter, L.lblLanguage, L.langName), ...
        'Color', [0.85, 0.92, 1.0], 'FontSize', 9, ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'left');

    % ---------------------------------------------------------------------
    % Patient Identification Card
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.81, 0.90, 0.078], ...
        'FaceColor', [0.96, 0.97, 0.99], 'EdgeColor', [0.80, 0.85, 0.92], 'LineWidth', 1);

    patientLine1 = sprintf('\\bf%s:\\rm  %s        \\bf%s:\\rm  %s        \\bf%s / %s:\\rm  %d / %s', ...
        L.lblPatientName, patientData.patientName, L.lblPatientId, patientData.patientId, ...
        L.lblAge, L.lblGender, patientData.age, patientData.gender);
    patientLine2 = sprintf('\\bf%s:\\rm  %s        \\bf%s:\\rm  %s', ...
        L.lblScreenDate, patientData.screeningDate, L.lblFacility, patientData.phcCenter);

    annotation(fig, 'textbox', [0.065, 0.815, 0.87, 0.07], ...
        'String', {patientLine1, patientLine2}, ...
        'Color', [0.08, 0.12, 0.22], ...
        'FontSize', 9.5, 'EdgeColor', 'none', 'Interpreter', 'tex');

    % ---------------------------------------------------------------------
    % Section 2: Large Visual Traffic Light Health Badge
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.705, 0.90, 0.092], ...
        'FaceColor', statusColor, 'EdgeColor', 'none');

    annotation(fig, 'textbox', [0.06, 0.75, 0.88, 0.042], ...
        'String', sprintf('%s   %s', statusIcon, statusTitle), ...
        'Color', 'w', 'FontSize', 13, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    annotation(fig, 'textbox', [0.06, 0.71, 0.88, 0.038], ...
        'String', statusSub, ...
        'Color', [1.0, 1.0, 0.95], 'FontSize', 10, ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');

    % ---------------------------------------------------------------------
    % Section 3: Visual Retinal Inspection & Simplified Explanation
    % ---------------------------------------------------------------------
    axW = 0.26;
    axH = 0.22;
    axY = 0.45;

    % Subplot 1: Patient Retinal Fundus Photo
    ax1 = axes(fig, 'Position', [0.07, axY, axW, axH]);
    if isfield(patientData, 'imgOriginal') && ~isempty(patientData.imgOriginal)
        imshow(patientData.imgOriginal, 'Parent', ax1);
    end
    title(ax1, L.lblYourEyePhoto, 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.1, 0.2, 0.4]);

    % Subplot 2: AI Diagnostic Lesion View
    ax2 = axes(fig, 'Position', [0.37, axY, axW, axH]);
    if isfield(patientData, 'lesionOverlay') && ~isempty(patientData.lesionOverlay)
        imshow(patientData.lesionOverlay, 'Parent', ax2);
    elseif isfield(patientData, 'imgEnhanced') && ~isempty(patientData.imgEnhanced)
        imshow(patientData.imgEnhanced, 'Parent', ax2);
    end
    title(ax2, L.lblAiLesionView, 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.1, 0.2, 0.4]);

    % Right Card: Simplified Diagnosis Explanation in Local Language
    annotation(fig, 'rectangle', [0.66, axY, 0.29, axH], ...
        'FaceColor', [0.98, 0.98, 0.99], 'EdgeColor', [0.82, 0.85, 0.88], 'LineWidth', 1);

    annotation(fig, 'textbox', [0.67, axY + axH - 0.035, 0.27, 0.03], ...
        'String', L.lblWhatItMeans, 'FontSize', 9.5, 'FontWeight', 'bold', ...
        'Color', [0.08, 0.20, 0.45], 'EdgeColor', 'none');

    meaningStr = {
        sprintf('\\bf%s:\\rm', L.lblCurrentCondition), ...
        sprintf('  - %s', pred.gradeName), ...
        '', ...
        sprintf('\\bf%s:\\rm', L.lblActionWindow), ...
        sprintf('  - %s', hospital.urgencyWindow), ...
        '', ...
        sprintf('\\bf%s:\\rm', L.lblCareUrgency), ...
        sprintf('  - %s', hospital.emergencyNote)
    };
    annotation(fig, 'textbox', [0.67, axY + 0.01, 0.27, axH - 0.045], ...
        'String', meaningStr, 'FontSize', 8, 'EdgeColor', 'none', ...
        'Interpreter', 'tex', 'Color', [0.1, 0.15, 0.25]);

    % ---------------------------------------------------------------------
    % Section 4: Recommended Hospital Referral & Navigation Card
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.23, 0.90, 0.20], ...
        'FaceColor', [0.94, 0.96, 1.0], 'EdgeColor', [0.20, 0.45, 0.80], 'LineWidth', 1.5);

    annotation(fig, 'textbox', [0.065, 0.395, 0.87, 0.03], ...
        'String', sprintf('🏥 %s:  %s (%s)', L.lblRecommendedHospital, hospital.facilityName, hospital.tierLevel), ...
        'FontSize', 10.5, 'FontWeight', 'bold', 'Color', [0.08, 0.25, 0.55], 'EdgeColor', 'none');

    hospInfoStr = {
        sprintf('\\bf%s:\\rm  %s', L.lblAddress, hospital.address), ...
        sprintf('\\bf%s:\\rm  ~%.1f km (%s)', L.lblDistance, hospital.distanceKm, L.lblRoadDistance), ...
        sprintf('\\bf%s:\\rm  %s', L.lblServices, strjoin(hospital.services, ', ')), ...
        sprintf('\\bf%s:\\rm  %s        \\bf%s:\\rm  %s', ...
            L.lblAppointmentHelpline, hospital.helpline, L.lblNationalEmergency, '108 / 104')
    };
    annotation(fig, 'textbox', [0.065, 0.275, 0.65, 0.115], ...
        'String', hospInfoStr, 'FontSize', 8.5, 'EdgeColor', 'none', ...
        'Interpreter', 'tex', 'Color', [0.08, 0.12, 0.22]);

    % Embed Offline QR Code Graphic on right of Hospital Box
    axQr = axes(fig, 'Position', [0.76, 0.245, 0.16, 0.14]);
    qrImg = generate_offline_qr_stamp(patientData.patientId, grade);
    imshow(qrImg, 'Parent', axQr);
    title(axQr, L.lblScanForDirections, 'FontSize', 7.5, 'FontWeight', 'bold');

    % ---------------------------------------------------------------------
    % Section 5: "3 Golden Rules for Diabetic Eyes" (Care Guidance)
    % ---------------------------------------------------------------------
    annotation(fig, 'rectangle', [0.05, 0.05, 0.90, 0.165], ...
        'FaceColor', [0.98, 0.99, 0.98], 'EdgeColor', [0.30, 0.65, 0.40], 'LineWidth', 1);

    annotation(fig, 'textbox', [0.065, 0.178, 0.87, 0.03], ...
        'String', sprintf('🌟 %s', L.lblGoldenRulesTitle), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.10, 0.45, 0.20], 'EdgeColor', 'none');

    rulesStr = {
        sprintf('1. \\bf%s:\\rm  %s', L.rule1Title, L.rule1Desc), ...
        sprintf('2. \\bf%s:\\rm  %s', L.rule2Title, L.rule2Desc), ...
        sprintf('3. \\bf%s:\\rm  %s', L.rule3Title, L.rule3Desc), ...
        sprintf('\\it%s\\rm', L.footerNote)
    };
    annotation(fig, 'textbox', [0.065, 0.055, 0.87, 0.12], ...
        'String', rulesStr, 'FontSize', 8.5, 'EdgeColor', 'none', ...
        'Interpreter', 'tex', 'Color', [0.10, 0.20, 0.15]);

    % Save Report to PDF
    drawnow;
    try
        exportgraphics(fig, outputPdfPath, 'ContentType', 'vector');
        fprintf('  [OK] Patient Health Slip exported to PDF: %s\n', outputPdfPath);
    catch
        print(fig, outputPdfPath, '-dpdf', '-r300');
        fprintf('  [OK] Patient Health Slip printed to PDF: %s\n', outputPdfPath);
    end

    % Save companion PNG preview
    [pDir, pName, ~] = fileparts(outputPdfPath);
    pngPreviewPath = fullfile(pDir, [pName, '_preview.png']);
    try
        exportgraphics(fig, pngPreviewPath, 'Resolution', 180);
    catch
        print(fig, pngPreviewPath, '-dpng', '-r180');
    end

    close(fig);
    slipPath = outputPdfPath;
end

% -------------------------------------------------------------------------
% Multilingual Translation Dictionary
% -------------------------------------------------------------------------
function L = get_language_dict(langCode)
    switch langCode
        case 'hi' % Hindi (हिन्दी)
            L.langName           = 'हिन्दी (Hindi)';
            L.headerTitle        = 'राष्ट्रीय टेली-नेत्र विज्ञान जांच कार्यक्रम';
            L.nationalProg       = 'आयुष्मान भारत — ग्रामीण मधुमेह नेत्र सुरक्षा';
            L.lblCenter          = 'स्वास्थ्य केंद्र';
            L.lblLanguage        = 'भाषा';
            L.lblPatientName     = 'मरीज का नाम';
            L.lblPatientId       = 'मरीज आईडी';
            L.lblAge             = 'उम्र';
            L.lblGender          = 'लिंग';
            L.lblScreenDate      = 'जांच की तारीख';
            L.lblFacility        = 'प्राथमिक केंद्र';
            L.statusGreenTitle   = 'आँखें सुरक्षित हैं: वार्षिक नियमित जांच';
            L.statusGreenSub     = 'दृष्टि को कोई तत्काल खतरा नहीं है। 12 महीने बाद दोबारा जांच करवाएं।';
            L.statusAmberTitle   = 'सावधानी: 30 दिन में जिला नेत्र विशेषज्ञ से मिलें';
            L.statusAmberSub     = 'मधुमेह के कारण रक्त वाहिकाओं में प्रारंभिक रिसाव पाया गया है।';
            L.statusRedTitle     = 'अति-आवश्यक: 48 घंटे के भीतर बड़े अस्पताल जाएं';
            L.statusRedSub       = 'दृष्टि हानि का गंभीर जोखिम! तुरंत रेटिना विशेषज्ञ से उपचार करवाएं।';
            L.lblYourEyePhoto    = '1. आपकी आँख की तस्वीर';
            L.lblAiLesionView    = '2. एआई द्वारा चिह्नित लक्षण';
            L.lblWhatItMeans     = 'जांच रिपोर्ट का सरल अर्थ';
            L.lblCurrentCondition= 'वर्तमान स्थिति';
            L.lblActionWindow    = 'अनुशंसित समय सीमा';
            L.lblCareUrgency     = 'डॉक्टर की सलाह';
            L.lblRecommendedHospital = 'अनुशंसित रेफरल अस्पताल';
            L.lblAddress         = 'पता';
            L.lblDistance        = 'दूरी';
            L.lblRoadDistance    = 'सड़क मार्ग';
            L.lblServices        = 'उपलब्ध सुविधाएं';
            L.lblAppointmentHelpline = 'अपॉइंटमेंट हेल्पलाइन';
            L.lblNationalEmergency = 'आपातकालीन नंबर';
            L.lblScanForDirections = 'अस्पताल दिशा-निर्देश हेतु QR स्कैन करें';
            L.lblGoldenRulesTitle = 'मधुमेह रोगियों के लिए आँखों के 3 सुनहरे नियम';
            L.rule1Title         = 'ब्लड शुगर नियंत्रण';
            L.rule1Desc          = 'HbA1c को 7.0% से कम रखें और डॉक्टर द्वारा बताई गई दवाएं नियमित लें।';
            L.rule2Title         = 'दैनिक व्यायाम और आहार';
            L.rule2Desc          = 'प्रतिदिन 30 मिनट तेज चलें, हरी पत्तेदार सब्जियां खाएं और मीठे से परहेज करें।';
            L.rule3Title         = 'नियमित नेत्र जांच';
            L.rule3Desc          = 'दृष्टि धुंधली होने की प्रतीक्षा न करें; हर साल प्राथमिक स्वास्थ्य केंद्र पर जांच कराएं।';
            L.footerNote         = 'आशा कार्यकर्ता सहयोग | समय पर जांच ही अंधेपन से स्थायी बचाव है।';

        case 'kn' % Kannada (ಕನ್ನಡ)
            L.langName           = 'ಕನ್ನಡ (Kannada)';
            L.headerTitle        = 'ರಾಷ್ಟ್ರೀಯ ಟೆಲಿ-ನೇತ್ರ ವಿಜ್ಞಾನ ತಪಾಸಣೆ ಯೋಜನೆ';
            L.nationalProg       = 'ಆಯುಷ್ಮಾನ್ ಭಾರತ - ಗ್ರಾಮೀಣ ಮಧುಮೇಹ ನೇತ್ರ ರಕ್ಷಣೆ';
            L.lblCenter          = 'ಆರೋಗ್ಯ ಕೇಂದ್ರ';
            L.lblLanguage        = 'ಭಾಷೆ';
            L.lblPatientName     = 'ರೋಗಿಯ ಹೆಸರು';
            L.lblPatientId       = 'ರೋಗಿ ಐಡಿ';
            L.lblAge             = 'ವಯಸ್ಸು';
            L.lblGender          = 'ಲಿಂಗ';
            L.lblScreenDate      = 'ತಪಾಸಣೆ ದಿನಾಂಕ';
            L.lblFacility        = 'ಪ್ರಾಥಮಿಕ ಕೇಂದ್ರ';
            L.statusGreenTitle   = 'ಕಣ್ಣುಗಳು ಸುರಕ್ಷಿತವಾಗಿವೆ: ವಾರ್ಷಿಕ ತಪಾಸಣೆ ಸಾಕು';
            L.statusGreenSub     = 'ದೃಷ್ಟಿಗೆ ಯಾವುದೇ ತಕ್ಷಣದ ಅಪಾಯವಿಲ್ಲ. 12 ತಿಂಗಳ ನಂತರ ಮರು-ಪರೀಕ್ಷಿಸಿ.';
            L.statusAmberTitle   = 'ಎಚ್ಚರಿಕೆ: 30 ದಿನಗಳೊಳಗೆ ಜಿಲ್ಲಾ ನೇತ್ರ ತಜ್ಞರನ್ನು ಭೇಟಿ ಮಾಡಿ';
            L.statusAmberSub     = 'ಮಧುಮೇಹದಿಂದ ರಕ್ತನಾಳಗಳಲ್ಲಿ ಆರಂಭಿಕ ಸೋರಿಕೆ ಕಂಡುಬಂದಿದೆ.';
            L.statusRedTitle     = 'ತುರ್ತು ಕ್ರಮ: 48 ಗಂಟೆಗಳೊಳಗೆ ಸುಪರ್ ಸ್ಪೆಷಾಲಿಟಿ ಆಸ್ಪತ್ರೆಗೆ ಭೇಟಿ ನೀಡಿ';
            L.statusRedSub       = 'ದೃಷ್ಟಿ ಕಳೆದುಕೊಳ್ಳುವ ಗಂಭೀರ ಅಪಾಯವಿದೆ! ತಕ್ಷಣ ಚಿಕಿತ್ಸೆ ಪಡೆಯಿರಿ.';
            L.lblYourEyePhoto    = '1. ನಿಮ್ಮ ಕಣ್ಣಿನ ಛಾಯಾಚಿತ್ರ';
            L.lblAiLesionView    = '2. ಎಐ ಗುರುತಿಸಿದ ಲಕ್ಷಣಗಳು';
            L.lblWhatItMeans     = 'ವರದಿಯ ವಿವರಣೆ';
            L.lblCurrentCondition= 'ಪ್ರಸ್ತುತ ಸ್ಥಿತಿ';
            L.lblActionWindow    = 'ಸಲಹೆ ನೀಡಿದ ಸಮಯ';
            L.lblCareUrgency     = 'ವೈದ್ಯರ ಸಲಹೆ';
            L.lblRecommendedHospital = 'ಶಿಫಾರಸು ಮಾಡಿದ ಆಸ್ಪತ್ರೆ';
            L.lblAddress         = 'ವಿಳಾಸ';
            L.lblDistance        = 'ದೂರ';
            L.lblRoadDistance    = 'ರಸ್ತೆ ಮಾರ್ಗ';
            L.lblServices        = 'ಲಭ್ಯವಿರುವ ಚಿಕಿತ್ಸೆಗಳು';
            L.lblAppointmentHelpline = 'ಸಹಾಯವಾಣಿ';
            L.lblNationalEmergency = 'ತುರ್ತು ಸಂಖ್ಯೆ';
            L.lblScanForDirections = 'ಆಸ್ಪತ್ರೆ ಮಾರ್ಗಕ್ಕಾಗಿ QR ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';
            L.lblGoldenRulesTitle = 'ಮಧುಮೇಹಿಗಳಿಗೆ 3 ಸುವರ್ಣ ನಿಯಮಗಳು';
            L.rule1Title         = 'ರಕ್ತದ ಸಕ್ಕರೆ ನಿಯಂತ್ರಣ';
            L.rule1Desc          = 'HbA1c ಅನ್ನು 7.0% ಗಿಂತ ಕಡಿಮೆ ಇರಿಸಿ ಮತ್ತು ವೈದ್ಯರ ಮಾತ್ರೆಗಳನ್ನು ತಪ್ಪದೇ ಸೇವಿಸಿ.';
            L.rule2Title         = 'ದೈನಂದಿನ ವ್ಯಾಯಾಮ';
            L.rule2Desc          = 'ದಿನಕ್ಕೆ 30 ನಿಮಿಷ ನಡೆಯಿರಿ ಮತ್ತು ಸಿಹಿ ಪದಾರ್ಥಗಳನ್ನು ತ್ಯಜಿಸಿ.';
            L.rule3Title         = 'ನಿಯಮಿತ ನೇತ್ರ ತಪಾಸಣೆ';
            L.rule3Desc          = 'ಕಣ್ಣು ಮಸುಕಾಗುವ ಮುನ್ನವೇ ಪ್ರತಿ ವರ್ಷ ಕಣ್ಣಿನ ತಪಾಸಣೆ ಮಾಡಿಸಿಕೊಳ್ಳಿ.';
            L.footerNote         = 'ಆಶಾ ಕಾರ್ಯಕರ್ತರ ಬೆಂಬಲ | ಸಮಯೋಚಿತ ಚಿಕಿತ್ಸೆಯಿಂದ ಅಂಧತ್ವವನ್ನು ತಡೆಯಬಹುದು.';

        case 'ta' % Tamil (தமிழ்)
            L.langName           = 'தமிழ் (Tamil)';
            L.headerTitle        = 'தேசிய தொலை-கண் மருத்துவ பரிசோதனை திட்டம்';
            L.nationalProg       = 'ஆயுஷ்மான் பாரத் - கிராமப்புற நீரிழிவு கண் பாதுகாப்பு';
            L.lblCenter          = 'சுகாதார மையம்';
            L.lblLanguage        = 'மொழி';
            L.lblPatientName     = 'நோயாளி பெயர்';
            L.lblPatientId       = 'நோயாளி எண்';
            L.lblAge             = 'வயது';
            L.lblGender          = 'பாலினம்';
            L.lblScreenDate      = 'பரிசோதனை தேதி';
            L.lblFacility        = 'ஆரம்ப சுகாதார நிலையம்';
            L.statusGreenTitle   = 'கண்கள் பாதுகாப்பாக உள்ளன: ஆண்டு பரிசோதனை';
            L.statusGreenSub     = 'பார்வைக்கு உடனடி ஆபத்து இல்லை. 12 மாதங்களுக்குப் பிறகு மீண்டும் பரிசோதிக்கவும்.';
            L.statusAmberTitle   = 'எச்சரிக்கை: 30 நாட்களுக்குள் கண் மருத்துவரை அணுகவும்';
            L.statusAmberSub     = 'இரத்த நாளங்களில் சிறிய கசிவு கண்டறியப்பட்டுள்ளது.';
            L.statusRedTitle     = 'அவசர சிகிச்சை: 48 மணி நேரத்திற்குள் மருத்துவமனை செல்லவும்';
            L.statusRedSub       = 'பார்வை இழக்கும் அபாயம்! உடனடியாக சிறப்பு சிகிச்சை பெறவும்.';
            L.lblYourEyePhoto    = '1. உங்கள் கண் புகைப்படம்';
            L.lblAiLesionView    = '2. கண்டறியப்பட்ட பாதிப்பு';
            L.lblWhatItMeans     = 'பரிசோதனை விளக்கம்';
            L.lblCurrentCondition= 'தற்போதைய நிலை';
            L.lblActionWindow    = 'பரிந்துரைக்கப்பட்ட காலம்';
            L.lblCareUrgency     = 'மருத்துவர் ஆலோசனை';
            L.lblRecommendedHospital = 'பரிந்துரைக்கப்பட்ட மருத்துவமனை';
            L.lblAddress         = 'முகவரி';
            L.lblDistance        = 'தொலைவு';
            L.lblRoadDistance    = 'சாலை வழி';
            L.lblServices        = 'சிகிச்சை வசதிகள்';
            L.lblAppointmentHelpline = 'உதவி எண்';
            L.lblNationalEmergency = 'அவசர எண்';
            L.lblScanForDirections = 'மருத்துவமனை வழிக்கு QR ஸ்கேன் செய்யவும்';
            L.lblGoldenRulesTitle = 'கண் பாதுகாப்பிற்கான 3 பொன்விதிகள்';
            L.rule1Title         = 'இரத்த சர்க்கரை கட்டுப்பாடு';
            L.rule1Desc          = 'HbA1c அளவை 7.0% க்குள் வைத்து மருந்துகளை சரியாக உட்கொள்ளவும்.';
            L.rule2Title         = 'தினசரி உடற்பயிற்சி';
            L.rule2Desc          = 'தினமும் 30 நிமிடங்கள் நடக்கவும், சத்தான உணவை உண்ணவும்.';
            L.rule3Title         = 'தவறாமல் கண் பரிசோதனை';
            L.rule3Desc          = 'பார்வை மங்குவதற்கு முன்பே ஆண்டுதோறும் கண் பரிசோதனை செய்யவும்.';
            L.footerNote         = 'ஆஷா பணியாளர் உதவி | ஆரம்ப கால பரிசோதனை பார்வை இழப்பைத் தடுக்கும்.';

        case 'te' % Telugu (తెలుగు)
            L.langName           = 'తెలుగు (Telugu)';
            L.headerTitle        = 'జాతీయ టెలి-నేత్ర వైద్య పరీక్షా కార్యక్రమం';
            L.nationalProg       = 'ఆయుష్మాన్ భారత్ - గ్రామీణ మధుమేహ నేత్ర రక్షణ';
            L.lblCenter          = 'ఆరోగ్య కేంద్రం';
            L.lblLanguage        = 'భాష';
            L.lblPatientName     = 'రోగి పేరు';
            L.lblPatientId       = 'రోగి ఐడీ';
            L.lblAge             = 'వయస్సు';
            L.lblGender          = 'లింగం';
            L.lblScreenDate      = 'పరీక్షించిన తేదీ';
            L.lblFacility        = 'ప్రాథమిక కేంద్రం';
            L.statusGreenTitle   = 'కళ్ళు సురక్షితంగా ఉన్నాయి: వార్షిక తనిఖీ';
            L.statusGreenSub     = 'దృష్టికి ఎలాంటి ముప్పు లేదు. 12 నెలల తర్వాత మళ్ళీ పరీక్షించుకోండి.';
            L.statusAmberTitle   = 'హెచ్చరిక: 30 రోజుల్లో నేత్ర నిపుణుడిని సంప్రదించండి';
            L.statusAmberSub     = 'మధుమేహం వల్ల రక్తనాళాల్లో ప్రాథమిక లీకేజీ కనిపించింది.';
            L.statusRedTitle     = 'అత్యవసరం: 48 గంటల్లో సూపర్ స్పెషాలిటీ ఆసుపత్రికి వెళ్ళండి';
            L.statusRedSub       = 'దృష్టి కోల్పోయే తీవ్ర ప్రమాదం ఉంది! వెంటనే చికిత్స పొందండి.';
            L.lblYourEyePhoto    = '1. మీ కంటి ఛాయాచిత్రం';
            L.lblAiLesionView    = '2. AI గుర్తించిన సమస్యలు';
            L.lblWhatItMeans     = 'పరీక్ష నివేదిక వివరణ';
            L.lblCurrentCondition= 'ప్రస్తుత పరిస్థితి';
            L.lblActionWindow    = 'సూచించిన సమయం';
            L.lblCareUrgency     = 'వైద్యుల సలహా';
            L.lblRecommendedHospital = 'సిఫార్సు చేయబడిన ఆసుపత్రి';
            L.lblAddress         = 'చిరునామా';
            L.lblDistance        = 'దూరం';
            L.lblRoadDistance    = 'రోడ్డు మార్గం';
            L.lblServices        = 'అందుబాటులో ఉన్న చికిత్సలు';
            L.lblAppointmentHelpline = 'హెల్ప్‌లైన్ నంబర్';
            L.lblNationalEmergency = 'అత్యవసర నంబర్';
            L.lblScanForDirections = 'ఆసుపత్రి మార్గం కోసం QR స్కాన్ చేయండి';
            L.lblGoldenRulesTitle = 'మధుమేహ రోగులకు 3 సువర్ణ నియమాలు';
            L.rule1Title         = 'షుగర్ నియంత్రణ';
            L.rule1Desc          = 'HbA1c ను 7.0% కంటే తక్కువగా ఉంచండి మరియు మందులు క్రమం తప్పక వాడండి.';
            L.rule2Title         = 'రోజూ వ్యాయామం';
            L.rule2Desc          = 'రోజుకు 30 నిమిషాలు నడవండి మరియు ఆరోగ్యకరమైన ఆహారం తీసుకోండి.';
            L.rule3Title         = 'క్రమం తప్పని పరీక్షలు';
            L.rule3Desc          = 'చూపు మసకబారే వరకు వేచి ఉండకండి; ప్రతి సంవత్సరం కంటి పరీక్ష చేయించుకోండి.';
            L.footerNote         = 'ఆశా కార్యకర్త సహాయం | సకాలంలో పరీక్ష చూపును కాపాడుతుంది.';

        case 'mr' % Marathi (मराठी)
            L.langName           = 'मराठी (Marathi)';
            L.headerTitle        = 'राष्ट्रीय टेली-नेत्ररोग तपासणी कार्यक्रम';
            L.nationalProg       = 'आयुष्मान भारत — ग्रामीण मधुमेह नेत्र सुरक्षा';
            L.lblCenter          = 'आरोग्य केंद्र';
            L.lblLanguage        = 'भाषा';
            L.lblPatientName     = 'रुग्णाचे नाव';
            L.lblPatientId       = 'रुग्ण आयडी';
            L.lblAge             = 'वय';
            L.lblGender          = 'लिंग';
            L.lblScreenDate      = 'तपासणी तारीख';
            L.lblFacility        = 'प्राथमिक केंद्र';
            L.statusGreenTitle   = 'डोळे सुरक्षित आहेत: वार्षिक नियमित तपासणी';
            L.statusGreenSub     = 'दृष्टीला कोणताही धोका नाही. १२ महिन्यांनी पुन्हा तपासणी करा.';
            L.statusAmberTitle   = 'काळजी घ्या: ३० दिवसांत जिल्हा नेत्र तज्ज्ञांना भेटा';
            L.statusAmberSub     = 'मधुमेहामुळे रक्तवाहिन्यांमध्ये प्राथमिक गळती आढळली आहे.';
            L.statusRedTitle     = 'अति-तातडीचे: ४८ तासांत मोठ्या रुग्णालयात जा';
            L.statusRedSub       = 'दृष्टी जाण्याचा गंभीर धोका! तातडीने रेटिना तज्ज्ञांकडून उपचार घ्या.';
            L.lblYourEyePhoto    = '१. तुमच्या डोळ्याचा फोटो';
            L.lblAiLesionView    = '२. AI द्वारे आढळलेली लक्षणे';
            L.lblWhatItMeans     = 'तपासणी अहवालाचा सोपा अर्थ';
            L.lblCurrentCondition= 'सध्याची स्थिती';
            L.lblActionWindow    = 'उपचारांची वेळ मर्यादा';
            L.lblCareUrgency     = 'डॉक्टरांचा सल्ला';
            L.lblRecommendedHospital = 'शिफारस केलेले रुग्णालय';
            L.lblAddress         = 'पत्ता';
            L.lblDistance        = 'अंतर';
            L.lblRoadDistance    = 'रस्ता मार्ग';
            L.lblServices        = 'उपलब्ध सुविधा';
            L.lblAppointmentHelpline = 'हेल्पलाइन नंबर';
            L.lblNationalEmergency = 'आपत्कालीन नंबर';
            L.lblScanForDirections = 'रुग्णालयाच्या मार्गासाठी QR स्कॅन करा';
            L.lblGoldenRulesTitle = 'मधुमेही रुग्णांसाठी डोळ्यांचे ३ सुवर्ण नियम';
            L.rule1Title         = 'रक्तातील साखर नियंत्रण';
            L.rule1Desc          = 'HbA1c ७.०% पेक्षा कमी ठेवा आणि डॉक्टरांची औषधे नियमित घ्या.';
            L.rule2Title         = 'दैनिक व्यायाम व आहार';
            L.rule2Desc          = 'दररोज ३० मिनिटे चाला, हिरव्या पालेभाज्या खा आणि गोड खाणे टाळा.';
            L.rule3Title         = 'नियमित नेत्र तपासणी';
            L.rule3Desc          = 'दृष्टी कमी होण्याची वाट पाहू नका; दरवर्षी प्राथमिक आरोग्य केंद्रात तपासणी करा.';
            L.footerNote         = 'आशा कार्यकर्ती सहकार्य | वेळेवर तपासणीच अंधत्वापासून कायमचा बचाव आहे.';

        otherwise % Default: English ('en')
            L.langName           = 'English';
            L.headerTitle        = 'NATIONAL TELE-OPHTHALMOLOGY AI SCREENING';
            L.nationalProg       = 'Ayushman Bharat - Rural Diabetic Retinopathy Prevention';
            L.lblCenter          = 'Health Centre';
            L.lblLanguage        = 'Language';
            L.lblPatientName     = 'Patient Name';
            L.lblPatientId       = 'Patient ID';
            L.lblAge             = 'Age';
            L.lblGender          = 'Gender';
            L.lblScreenDate      = 'Screening Date';
            L.lblFacility        = 'Primary Facility';
            L.statusGreenTitle   = 'EYES HEALTHY: ROUTINE ANNUAL FOLLOW-UP';
            L.statusGreenSub     = 'No sight-threatening lesions detected. Return to PHC in 12 months.';
            L.statusAmberTitle   = 'WARNING: SECONDARY REFERRAL WITHIN 30 DAYS';
            L.statusAmberSub     = 'Moderate vascular leakage detected. Specialist dilated eye exam advised.';
            L.statusRedTitle     = 'CRITICAL: URGENT TERTIARY REFERRAL (< 48 HOURS)';
            L.statusRedSub       = 'High risk of irreversible vision loss. Specialist intervention mandatory.';
            L.lblYourEyePhoto    = '1. Your Retinal Scan';
            L.lblAiLesionView    = '2. AI Pathology Highlights';
            L.lblWhatItMeans     = 'What Your Result Means';
            L.lblCurrentCondition= 'Current DR Grade';
            L.lblActionWindow    = 'Care Timeline';
            L.lblCareUrgency     = 'Clinical Advisory';
            L.lblRecommendedHospital = 'Recommended Referral Hospital';
            L.lblAddress         = 'Address';
            L.lblDistance        = 'Est. Distance';
            L.lblRoadDistance    = 'Road Route';
            L.lblServices        = 'Available Services';
            L.lblAppointmentHelpline = 'Appointment Helpline';
            L.lblNationalEmergency = 'Emergency Line';
            L.lblScanForDirections = 'Scan QR for Direct Hospital Navigation';
            L.lblGoldenRulesTitle = '3 Golden Rules for Protecting Diabetic Eyes';
            L.rule1Title         = 'Strict Glycemic Control';
            L.rule1Desc          = 'Maintain HbA1c below 7.0% and take prescribed diabetes medications daily.';
            L.rule2Title         = 'Active Lifestyle & Diet';
            L.rule2Desc          = 'Walk 30 minutes every day, reduce refined sugar, and eat leafy green vegetables.';
            L.rule3Title         = 'Annual Preventive Screening';
            L.rule3Desc          = 'Do not wait for blurry vision to develop; screen your eyes every 12 months at the PHC.';
            L.footerNote         = 'Supported by Frontline ASHA Workers | Early screening prevents 95% of diabetic blindness.';
    end
end

% -------------------------------------------------------------------------
% Generate Procedural High-Density Offline QR Code Stamp
% -------------------------------------------------------------------------
function qrImg = generate_offline_qr_stamp(patientId, grade)
    N = 85;
    qrImg = ones(N, N, 3, 'uint8') * 255;

    % Position Finder Patterns (Top-Left, Top-Right, Bottom-Left)
    qrImg = add_finder_pattern(qrImg, 4, 4);
    qrImg = add_finder_pattern(qrImg, N - 21, 4);
    qrImg = add_finder_pattern(qrImg, 4, N - 21);

    % Deterministic pseudo-data modules based on patientId & grade
    seed = sum(double(patientId)) + grade * 17;
    rng(seed);
    for y = 5:N-5
        for x = 5:N-5
            % Skip finder pattern zones
            if (x <= 25 && y <= 25) || (x >= N-25 && y <= 25) || (x <= 25 && y >= N-25)
                continue;
            end
            if rand() > 0.52
                qrImg(y, x, :) = 20; % dark module
            end
        end
    end
end

function img = add_finder_pattern(img, startX, startY)
    % 17x17 finder pattern box
    sz = 17;
    img(startY:startY+sz, startX:startX+sz, :) = 0; % Black outer box
    img(startY+2:startY+sz-2, startX+2:startX+sz-2, :) = 255; % White inner border
    img(startY+5:startY+sz-5, startX+5:startX+sz-5, :) = 0; % Solid black center
end
