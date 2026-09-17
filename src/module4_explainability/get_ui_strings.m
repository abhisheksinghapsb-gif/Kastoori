function S = get_ui_strings(langCode)
% GET_UI_STRINGS Centralized Multilingual UI Dictionary for RetinaCare AI
% Supports 6 Indian languages for rural tele-ophthalmology:
%   - 'en': English (Default)
%   - 'hi': हिन्दी (Hindi)
%   - 'mr': मराठी (Marathi)
%   - 'kn': ಕನ್ನಡ (Kannada)
%   - 'ta': தமிழ் (Tamil)
%   - 'te': తెలుగు (Telugu)
%
% SIH PS 26038 | MathWorks Track

    if nargin < 1 || isempty(langCode)
        langCode = 'en';
    end

    switch lower(strtrim(langCode))
        % =================================================================
        % 1. HINDI (हिन्दी)
        % =================================================================
        case 'hi'
            S.langCode = 'hi';
            S.langName = 'हिन्दी (Hindi)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'ग्रामीण टेली-नेत्र विज्ञान जांच प्रणाली';
            S.sloganTitle = 'स्पष्ट दृष्टि. स्वस्थ समुदाय।';
            S.sloganSub = 'एआई-संचालित जांच  |  आशा कार्यकर्ता सहयोग  |  सुलभ ग्रामीण स्वास्थ्य सेवा';
            S.btnFullscreen = '⛶  फुल स्क्रीन';
            S.netConnected = '🟢 कनेक्टेड';
            S.netSpeed = '512 kbps (ग्रामीण स्वास्थ्य केंद्र)';
            S.userRole = 'स्वास्थ्य केंद्र ऑपरेटर';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  डैशबोर्ड';
            S.navPatient = '👤  मरीज विवरण';
            S.navAnalysis = '🔠  एआई विश्लेषण';
            S.navBatch = '📁  बैच स्क्रीनिंग';
            S.navEmpathy = '👁️  दृष्टि हानि सिमुलेटर';
            S.navReports = '📄  क्लिनिकल रिपोर्ट';
            S.navMonitoring = '📊  केंद्र मॉनिटरिंग';
            S.navSimulink = '➿  सिमुलिंक नेटवर्क';
            S.navChatbot = '🤖  एआई को-पायलट';
            S.navSettings = '⚙️  सेटिंग्स';
            S.navHelp = '❓  सहायता एवं सपोर्ट';

            % Stepper Bar (5 Stages)
            S.step1 = '१. मरीज एवं तस्वीर';
            S.step2 = '२. इमेज एन्हांसमेंट';
            S.step3 = '३. रक्त वाहिका व लक्षण';
            S.step4 = '४. एआई हीटमैप (Grad-CAM)';
            S.step5 = '५. निदान और रिपोर्ट';

            % Card 1: Patient & Image Capture
            S.card1Title = 'मरीज एवं रेटिना छवि पंजीकरण';
            S.card1Sub = 'मरीज का विवरण दर्ज करें और रेटिना की तस्वीर अपलोड करें';
            S.lblPatientId = 'मरीज आईडी *';
            S.lblPatientName = 'मरीज का नाम *';
            S.lblAgeSex = 'उम्र / लिंग *';
            S.lblPhcCenter = 'स्वास्थ्य केंद्र';
            S.lblSelectScan = 'क्लिनिकल टेस्ट स्कैन चुनें';
            S.dropZoneTitle = 'रेटिना की तस्वीर यहाँ खींचकर लाएँ';
            S.btnBrowse = 'या फ़ाइल ब्राउज़ करें';
            S.dropSupport = 'JPG, PNG समर्थित (अधिकतम 10MB)';
            S.btnRun = '▶  एआई स्क्रीनिंग शुरू करें';
            S.frontlineReady = 'स्कैन लोड करें या स्क्रीनिंग शुरू करें';
            S.frontlineScreening = 'एआई स्क्रीनिंग चल रही है, कृपया प्रतीक्षा करें...';

            % Card 2: Diagnostic Analysis (2x2 Grid)
            S.card2Title = 'नैदानिक विश्लेषण (Diagnostic Grid)';
            S.card2Sub = 'एआई-संचालित रेटिना इमेज विश्लेषण पाइपलाइन';
            S.tile1Hdr = ' १   मूल रेटिना फंडस स्कैन';
            S.badge1 = 'मूल तस्वीर';
            S.tile2Hdr = ' २   संवर्धित ग्रीन चैनल (CLAHE)';
            S.badge2 = 'संवर्धित तस्वीर';
            S.tile3Hdr = ' ३   रक्त वाहिकाएं एवं लक्षण';
            S.badge3 = '● नसें   ● माइक्रोएन्यूरिज्म   ● एक्जुडेट';
            S.tile4Hdr = ' ४  व्याख्यात्मक एआई (Grad-CAM)';
            S.badge4GradCam = 'Grad-CAM ओवरले';
            S.badge4Points = 'डॉक्टर निरीक्षण बिंदु';
            S.btnPointsMode = '①②③ बिंदु';

            % Card 3: AI Diagnosis & Clinical Triage
            S.card3Title = 'एआई निदान एवं क्लिनिकल ट्राइएज';
            S.statusComplete = '🟢 विश्लेषण पूर्ण';
            S.statusReady = '⚪ जांच के लिए तैयार';
            S.severityPrefix = 'गंभीरता';
            S.triageReferable = 'रेफरल अनिवार्य';
            S.triageNonReferable = 'सुरक्षित / वार्षिक जांच';
            S.referableRisk = 'रेफरल जोखिम (P ≥ 2)';
            S.classProbHdr = 'रोग की संभावना (ICDR)';
            S.gradeNames = {'G0 - कोई रेटिनोपैथी नहीं', 'G1 - प्रारंभिक NPDR', 'G2 - मध्यम NPDR', 'G3 - गंभीर NPDR', 'G4 - प्रोलिफेरेटिव PDR'};
            S.keyFindingsTitle = '🔍  प्रमुख निष्कर्ष';
            S.btnViewDetails = 'विस्तार देखें';
            S.lblEyeOrient = '👁️  आँख की दिशा';
            S.lblIqa = '🟢  छवि गुणवत्ता';
            S.lblEtdrs = '🔴  ETDRS स्टेजिंग';
            S.lblLesions = '🟠  लक्षणों की संख्या';
            S.lblCsme = '🟡  CSME जोखिम';
            S.lblRoadDist = '🚗 सड़क मार्ग दूरी';
            S.lblServices = '🩺 उपलब्ध सेवाएं';
            S.lblHelpline = '📞 हेल्पलाइन';
            S.lblAdvice = 'सलाह';

            % Bottom Action Footer
            S.btnDoctorReport = '📄  डॉक्टर PDF रिपोर्ट';
            S.btnPatientSlip = '🖨️  मरीज स्वास्थ्य पर्ची';
            S.btnEmpathySim = '👁️  दृष्टि हानि सिमुलेटर';
            S.quoteText = '"आज समय पर पहचान, ग्रामीण भारत का सुरक्षित और उज्ज्वल भविष्य।"';

            % Chatbot Panel
            S.chatbotTitle = '🤖 क्लिनिकल एआई को-पायलट';
            S.btnBackDash = '← डैशबोर्ड पर वापस जाएं';
            S.chatPlaceholder = 'मरीज की पिछली जांच, शुगर (HbA1c), दवाइयां, या बीमारी के बारे में सीधे पूछें...';
            S.btnSendChat = 'पूछें 🚀';
            S.chip1 = '📜 पिछला दौरा व इलाज';
            S.chip1Query = 'मरीज का पिछला इलाज और दौरा कब था?';
            S.chip2 = '🩸 शुगर और HbA1c';
            S.chip2Query = 'मरीज का शुगर और HbA1c स्तर क्या है?';
            S.chip3 = '💊 वर्तमान दवाइयां';
            S.chip3Query = 'मरीज कौन सी दवाइयां ले रहा है?';
            S.chip4 = '🩺 बीपी और किडनी स्थिति';
            S.chip4Query = 'मरीज का ब्लड प्रेशर और किडनी की स्थिति क्या है?';
            S.chip5 = '👁️ आज का निदान व ग्रेड';
            S.chip5Query = 'आज की जांच का क्या ग्रेड और परिणाम है?';
            S.chip6 = '💡 क्या मरीज अंधा हो सकता है?';
            S.chip6Query = 'क्या इस बीमारी से मरीज अंधा हो सकता है और क्या इलाज है?';

        % =================================================================
        % 2. MARATHI (मराठी)
        % =================================================================
        case 'mr'
            S.langCode = 'mr';
            S.langName = 'मराठी (Marathi)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'ग्रामीण टेली-नेत्ररोग तपासणी प्रणाली';
            S.sloganTitle = 'स्पष्ट दृष्टी. सशक्त समुदाय.';
            S.sloganSub = 'AI-संचलित तपासणी  |  आशा कार्यकर्त्यांना सहकार्य  |  सुलभ ग्रामीण आरोग्यसेवा';
            S.btnFullscreen = '⛶  पूर्ण स्क्रीन';
            S.netConnected = '🟢 जोडलेले';
            S.netSpeed = '512 kbps (ग्रामीण आरोग्य केंद्र)';
            S.userRole = 'आरोग्य केंद्र ऑपरेटर';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  डॅशबोर्ड';
            S.navPatient = '👤  रुग्ण नोंदणी';
            S.navAnalysis = '🔠  AI विश्लेषण';
            S.navBatch = '📁  बॅच तपासणी';
            S.navEmpathy = '👁️  दृष्टी हानी सिम्युलेटर';
            S.navReports = '📄  वैद्यकीय अहवाल';
            S.navMonitoring = '📊  केंद्र नियंत्रण';
            S.navSimulink = '➿  सिम्युलिंक नेटवर्क';
            S.navChatbot = '🤖  AI को-पायलट';
            S.navSettings = '⚙️  सेटिंग्ज';
            S.navHelp = '❓  मदत व मार्गदर्शन';

            % Stepper Bar
            S.step1 = '१. रुग्ण आणि डोळ्याचा फोटो';
            S.step2 = '२. प्रतिमा संवर्धन (CLAHE)';
            S.step3 = '३. रक्तवाहिन्या आणि लक्षणे';
            S.step4 = '४. AI हीटमॅप (Grad-CAM)';
            S.step5 = '५. निदान आणि अहवाल';

            % Card 1: Patient & Image Capture
            S.card1Title = 'रुग्ण आणि नेत्र प्रतिमा नोंदणी';
            S.card1Sub = 'रुग्णाचा तपशील भरा आणि डोळ्याचा फोटो अपलोड करा';
            S.lblPatientId = 'रुग्ण आयडी *';
            S.lblPatientName = 'रुग्णाचे नाव *';
            S.lblAgeSex = 'वय / लिंग *';
            S.lblPhcCenter = 'आरोग्य केंद्र';
            S.lblSelectScan = 'तपासणीसाठी स्कॅन निवडा';
            S.dropZoneTitle = 'रेटिना प्रतिमा येथे ड्रॅग करा';
            S.btnBrowse = 'किंवा फाइल निवडा';
            S.dropSupport = 'JPG, PNG समर्थित (कमाल 10MB)';
            S.btnRun = '▶  AI तपासणी सुरू करा';
            S.frontlineReady = 'स्कॅन लोड करा किंवा तपासणी सुरू करा';
            S.frontlineScreening = 'AI तपासणी सुरू आहे, कृपया प्रतीक्षा करा...';

            % Card 2: Diagnostic Analysis
            S.card2Title = 'वैद्यकीय विश्लेषण (Diagnostic Grid)';
            S.card2Sub = 'AI-संचलित रेटिना प्रतिमा विश्लेषण';
            S.tile1Hdr = ' १   मूळ रेटिना फंडस स्कॅन';
            S.badge1 = 'मूळ प्रतिमा';
            S.tile2Hdr = ' २   संवर्धित ग्रीन चॅनेल (CLAHE)';
            S.badge2 = 'संवर्धित प्रतिमा';
            S.tile3Hdr = ' ३   रक्तवाहिन्या आणि लक्षणे';
            S.badge3 = '● वाहिन्या   ● मायक्रोअन्युरीझम   ● एक्झुडेट';
            S.tile4Hdr = ' ४  स्पष्टीकरणात्मक AI (Grad-CAM)';
            S.badge4GradCam = 'Grad-CAM ओव्हरले';
            S.badge4Points = 'डॉक्टर तपासणी बिंदू';
            S.btnPointsMode = '①②③ बिंदू';

            % Card 3: AI Diagnosis & Clinical Triage
            S.card3Title = 'AI निदान आणि ट्रायज';
            S.statusComplete = '🟢 विश्लेषण पूर्ण';
            S.statusReady = '⚪ तपासणीसाठी सज्ज';
            S.severityPrefix = 'तीव्रता';
            S.triageReferable = 'रेफरल आवश्यक';
            S.triageNonReferable = 'सुरक्षित / वार्षिक तपासणी';
            S.referableRisk = 'रेफरल धोका (P ≥ 2)';
            S.classProbHdr = 'रोगाची शक्यता (ICDR)';
            S.gradeNames = {'G0 - रेटिनोपॅथी नाही', 'G1 - सौम्य NPDR', 'G2 - मध्यम NPDR', 'G3 - गंभीर NPDR', 'G4 - प्रोलिफेरेटिव्ह PDR'};
            S.keyFindingsTitle = '🔍  महत्त्वाचे निष्कर्ष';
            S.btnViewDetails = 'तपशील पहा';
            S.lblEyeOrient = '👁️  डोळ्याची दिशा';
            S.lblIqa = '🟢  प्रतिमा गुणवत्ता';
            S.lblEtdrs = '🔴  ETDRS वर्गवारी';
            S.lblLesions = '🟠  लक्षणांची संख्या';
            S.lblCsme = '🟡  CSME धोका';
            S.lblRoadDist = '🚗 रस्ता अंतर';
            S.lblServices = '🩺 उपलब्ध सुविधा';
            S.lblHelpline = '📞 हेल्पलाइन';
            S.lblAdvice = 'सल्ला';

            % Bottom Action Footer
            S.btnDoctorReport = '📄  डॉक्टर PDF अहवाल';
            S.btnPatientSlip = '🖨️  रुग्ण आरोग्य पावती';
            S.btnEmpathySim = '👁️  दृष्टी हानी सिम्युलेटर';
            S.quoteText = '"आज वेळेवर निदान, ग्रामीण भारताचे निरोगी आणि उज्वल भविष्य."';

            % Chatbot Panel
            S.chatbotTitle = '🤖 AI क्लिनिकल को-पायलट';
            S.btnBackDash = '← डॅशबोर्डवर परत जा';
            S.chatPlaceholder = 'रुग्णाची मागील तपासणी, साखर (HbA1c), औषधे किंवा उपचारांविषयी थेट विचारा...';
            S.btnSendChat = 'विचारा 🚀';
            S.chip1 = '📜 मागील भेट व उपचार';
            S.chip1Query = 'रुग्णाचा मागील उपचार आणि तपासणी कधी झाली होती?';
            S.chip2 = '🩸 साखर आणि HbA1c';
            S.chip2Query = 'रुग्णाचे रक्तातील साखर आणि HbA1c प्रमाण काय आहे?';
            S.chip3 = '💊 चालू औषधे';
            S.chip3Query = 'रुग्ण सध्या कोणती औषधे घेत आहे?';
            S.chip4 = '🩺 बीपी आणि किडनी स्थिती';
            S.chip4Query = 'रुग्णाचा रक्तदाब आणि किडनीची स्थिती कशी आहे?';
            S.chip5 = '👁️ आजचे निदान व ग्रेड';
            S.chip5Query = 'आजच्या तपासणीचा ग्रेड आणि निष्कर्ष काय आहे?';
            S.chip6 = '💡 दृष्टी जाण्याचा धोका आहे का?';
            S.chip6Query = 'या आजाराने दृष्टी जाऊ शकते का आणि त्यावर उपाय काय?';

        % =================================================================
        % 3. KANNADA (ಕನ್ನಡ)
        % =================================================================
        case 'kn'
            S.langCode = 'kn';
            S.langName = 'ಕನ್ನಡ (Kannada)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'ಗ್ರಾಮೀಣ ಟೆಲಿ-ನೇತ್ರ ತಪಾಸಣಾ ಸೂಟ್';
            S.sloganTitle = 'ಸ್ಪಷ್ಟ ದೃಷ್ಟಿ. ಆರೋಗ್ಯಕರ ಸಮುದಾಯ.';
            S.sloganSub = 'ಎಐ ತಪಾಸಣೆ  |  ಆಶಾ ಕಾರ್ಯಕರ್ತೆಯರಿಗೆ ಬೆಂಬಲ  |  ಗ್ರಾಮೀಣ ಆರೋಗ್ಯ ಸೇವೆ';
            S.btnFullscreen = '⛶  ಪೂರ್ಣ ಪರದೆ';
            S.netConnected = '🟢 ಸಂಪರ್ಕಗೊಂಡಿದೆ';
            S.netSpeed = '512 kbps (ಗ್ರಾಮೀಣ ಪ್ರಾಥಮಿಕ ಕೇಂದ್ರ)';
            S.userRole = 'ಆರೋಗ್ಯ ಕೇಂದ್ರ ಆಪರೇಟರ್';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';
            S.navPatient = '👤  ರೋಗಿಯ ವಿವರ';
            S.navAnalysis = '🔠  ಎಐ ವಿಶ್ಲೇಷಣೆ';
            S.navBatch = '📁  ಬ್ಯಾಚ್ ತಪಾಸಣೆ';
            S.navEmpathy = '👁️  ದೃಷ್ಟಿ ನಷ್ಟ ಸಿಮ್ಯುಲೇಟರ್';
            S.navReports = '📄  ವರದಿಗಳು';
            S.navMonitoring = '📊  ಕೇಂದ್ರ ಮೇಲ್ವಿಚಾರಣೆ';
            S.navSimulink = '➿  ಸಿಮ್ಯುಲಿಂಕ್ ನೆಟ್‌ವರ್ಕ್';
            S.navChatbot = '🤖  ಎಐ ಕೋ-ಪೈಲಟ್';
            S.navSettings = '⚙️  ಸೆಟ್ಟಿಂಗ್‌ಗಳು';
            S.navHelp = '❓  ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';

            % Stepper Bar
            S.step1 = '೧. ರೋಗಿ ಮತ್ತು ಕಣ್ಣಿನ ಚಿತ್ರ';
            S.step2 = '೨. ಚಿತ್ರ ವರ್ಧನೆ (CLAHE)';
            S.step3 = '೩. ರಕ್ತನಾಳಗಳು ಮತ್ತು ಲಕ್ಷಣಗಳು';
            S.step4 = '೪. ಎಐ ಹೀಟ್‌ಮ್ಯಾಪ್ (Grad-CAM)';
            S.step5 = '೫. ರೋಗನಿರ್ಣಯ ಮತ್ತು ವರದಿ';

            % Card 1
            S.card1Title = 'ರೋಗಿ ಮತ್ತು ರೆಟಿನಾ ಚಿತ್ರ ನೋಂದಣಿ';
            S.card1Sub = 'ರೋಗಿಯ ವಿವರ ನಮೂದಿಸಿ ಮತ್ತು ಚಿತ್ರ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';
            S.lblPatientId = 'ರೋಗಿ ಐಡಿ *';
            S.lblPatientName = 'ರೋಗಿಯ ಹೆಸರು *';
            S.lblAgeSex = 'ವಯಸ್ಸು / ಲಿಂಗ *';
            S.lblPhcCenter = 'ಆರೋಗ್ಯ ಕೇಂದ್ರ';
            S.lblSelectScan = 'ಪರೀಕ್ಷಾ ಸ್ಕ್ಯಾನ್ ಆಯ್ಕೆಮಾಡಿ';
            S.dropZoneTitle = 'ರೆಟಿನಾ ಚಿತ್ರವನ್ನು ಇಲ್ಲಿ ಡ್ರ್ಯಾಗ್ ಮಾಡಿ';
            S.btnBrowse = 'ಅಥವಾ ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';
            S.dropSupport = 'JPG, PNG ಬೆಂಬಲಿತ (ಗರಿಷ್ಠ 10MB)';
            S.btnRun = '▶  ಎಐ ತಪಾಸಣೆ ಆರಂಭಿಸಿ';
            S.frontlineReady = 'ಸ್ಕ್ಯಾನ್ ಲೋಡ್ ಮಾಡಿ ಅಥವಾ ತಪಾಸಣೆ ಆರಂಭಿಸಿ';
            S.frontlineScreening = 'ಎಐ ತಪಾಸಣೆ ಪ್ರಗತಿಯಲ್ಲಿದೆ...';

            % Card 2
            S.card2Title = 'ರೋಗನಿರ್ಣಯ ವಿಶ್ಲೇಷಣೆ';
            S.card2Sub = 'ಎಐ-ಚಾಲಿತ ರೆಟಿನಾ ಚಿತ್ರ ವಿಶ್ಲೇಷಣೆ';
            S.tile1Hdr = ' ೧   ಮೂಲ ರೆಟಿನಾ ಫಂಡಸ್ ಸ್ಕ್ಯಾನ್';
            S.badge1 = 'ಮೂಲ ಚಿತ್ರ';
            S.tile2Hdr = ' ೨   ವರ್ಧಿತ ಗ್ರೀನ್ ಚಾನಲ್ (CLAHE)';
            S.badge2 = 'ವರ್ಧಿತ ಚಿತ್ರ';
            S.tile3Hdr = ' ೩   ರಕ್ತನಾಳಗಳು ಮತ್ತು ಲಕ್ಷಣಗಳು';
            S.badge3 = '● ನಾಳಗಳು   ● ಮೈಕ್ರೋಅನ್ಯೂರಿಸಮ್   ● ಎಕ್ಸುಡೇಟ್';
            S.tile4Hdr = ' ೪  ಎಐ ವಿವರಣೆ (Grad-CAM)';
            S.badge4GradCam = 'Grad-CAM ಓವರ್‌ಲೇ';
            S.badge4Points = 'ವೈದ್ಯರ ಪರಿಶೀಲನಾ ಬಿಂದುಗಳು';
            S.btnPointsMode = '①②③ ಬಿಂದು';

            % Card 3
            S.card3Title = 'ಎಐ ರೋಗನಿರ್ಣಯ ಮತ್ತು ಟ್ರಯಾಜ್';
            S.statusComplete = '🟢 ವಿಶ್ಲೇಷಣೆ ಪೂರ್ಣಗೊಂಡಿದೆ';
            S.statusReady = '⚪ ತಪಾಸಣೆಗೆ ಸಿದ್ಧ';
            S.severityPrefix = 'ತೀವ್ರತೆ';
            S.triageReferable = 'ಶಿಫಾರಸು ಅಗತ್ಯ';
            S.triageNonReferable = 'ಸುರಕ್ಷಿತ / ವಾರ್ಷಿಕ ತಪಾಸಣೆ';
            S.referableRisk = 'ರೆಫರಲ್ ಅಪಾಯ (P ≥ 2)';
            S.classProbHdr = 'ವರ್ಗ ಸಂಭವನೀಯತೆ (ICDR)';
            S.gradeNames = {'G0 - ಯಾವುದೇ DR ಇಲ್ಲ', 'G1 - ಸೌಮ್ಯ NPDR', 'G2 - ಮಧ್ಯಮ NPDR', 'G3 - ತೀವ್ರ NPDR', 'G4 - PDR'};
            S.keyFindingsTitle = '🔍  ಮುಖ್ಯ ಅಂಶಗಳು';
            S.btnViewDetails = 'ವಿವರಗಳನ್ನು ವೀಕ್ಷಿಸಿ';
            S.lblEyeOrient = '👁️  ಕಣ್ಣಿನ ದಿಕ್ಕು';
            S.lblIqa = '🟢  ಚಿತ್ರದ ಗುಣಮಟ್ಟ';
            S.lblEtdrs = '🔴  ETDRS ಹಂತ';
            S.lblLesions = '🟠  ಲಕ್ಷಣಗಳ ಎಣಿಕೆ';
            S.lblCsme = '🟡  CSME ಅಪಾಯ';
            S.lblRoadDist = '🚗 ರಸ್ತೆ ದೂರ';
            S.lblServices = '🩺 ಲಭ್ಯವಿರುವ ಚಿಕಿತ್ಸೆಗಳು';
            S.lblHelpline = '📞 ಸಹಾಯವಾಣಿ';
            S.lblAdvice = 'ಸಲಹೆ';

            % Bottom Footer
            S.btnDoctorReport = '📄  ವೈದ್ಯಕೀಯ PDF ವರದಿ';
            S.btnPatientSlip = '🖨️  ರೋಗಿಯ ಆರೋಗ್ಯ ಚೀಟಿ';
            S.btnEmpathySim = '👁️  ದೃಷ್ಟಿ ನಷ್ಟ ಸಿಮ್ಯುಲೇಟರ್';
            S.quoteText = '"ಸಮಯೋಚಿತ ಪರೀಕ್ಷೆ, ಗ್ರಾಮೀಣ ಭಾರತದ ಆರೋಗ್ಯಕರ ಭವಿಷ್ಯ."';

            % Chatbot
            S.chatbotTitle = '🤖 ಎಐ ಕ್ಲಿನಿಕಲ್ ಕೋ-ಪೈಲಟ್';
            S.btnBackDash = '← ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹಿಂತಿರುಗಿ';
            S.chatPlaceholder = 'ರೋಗಿಯ ಇತಿಹಾಸ, HbA1c, ಔಷಧಿಗಳು ಅಥವಾ ಚಿಕಿತ್ಸೆಯ ಬಗ್ಗೆ ಪ್ರಶ್ನಿಸಿ...';
            S.btnSendChat = 'ಕೇಳಿ 🚀';
            S.chip1 = '📜 ಹಿಂದಿನ ಭೇಟಿ ಮತ್ತು ಚಿಕಿತ್ಸೆ';
            S.chip1Query = 'When did he visit the last time and what treatments were given?';
            S.chip2 = '🩸 HbA1c ಮತ್ತು ಸಕ್ಕರೆ';
            S.chip2Query = 'What is his HbA1c and diabetes status?';
            S.chip3 = '💊 ಪ್ರಸ್ತುತ ಔಷಧಿಗಳು';
            S.chip3Query = 'What medications is the patient taking?';
            S.chip4 = '🩺 ರಕ್ತದೊತ್ತಡ ಮತ್ತು ಮೂತ್ರಪಿಂಡ';
            S.chip4Query = 'What is his blood pressure and kidney status?';
            S.chip5 = '👁️ ಇಂದಿನ ರೋಗನಿರ್ಣಯ';
            S.chip5Query = 'What is today DR grade and diagnosis?';
            S.chip6 = '💡 ಅಂಧತ್ವದ ಅಪಾಯವಿದೆಯೇ?';
            S.chip6Query = 'Can this condition cause blindness and what is the treatment?';

        % =================================================================
        % 4. TAMIL (தமிழ்)
        % =================================================================
        case 'ta'
            S.langCode = 'ta';
            S.langName = 'தமிழ் (Tamil)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'கிராமப்புற தொலை-கண் மருத்துவ பரிசோதனை சூட்';
            S.sloganTitle = 'தெளிவான பார்வை. ஆரோக்கியமான சமுதாயம்.';
            S.sloganSub = 'AI பரிசோதனை  |  ஆஷா பணியாளர் ஆதரவு  |  கிராமப்புற சுகாதாரம்';
            S.btnFullscreen = '⛶  முழுத்திரை';
            S.netConnected = '🟢 இணைக்கப்பட்டது';
            S.netSpeed = '512 kbps (கிராமப்புற மையம்)';
            S.userRole = 'சுகாதார மைய பயனர்';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  டாஷ்போர்டு';
            S.navPatient = '👤  நோயாளி பதிவு';
            S.navAnalysis = '🔠  AI ஆய்வு';
            S.navBatch = '📁  தொகுதி பரிசோதனை';
            S.navEmpathy = '👁️  பார்வை இழப்பு மாதிரி';
            S.navReports = '📄  அறிக்கைகள்';
            S.navMonitoring = '📊  மைய கண்காணிப்பு';
            S.navSimulink = '➿  சிமுலிங்க் நெட்வொர்க்';
            S.navChatbot = '🤖  AI உதவியாளர்';
            S.navSettings = '⚙️  அமைப்புகள்';
            S.navHelp = '❓  உதவி மற்றும் ஆதரவு';

            % Stepper Bar
            S.step1 = '1. நோயாளி & கண் புகைப்படம்';
            S.step2 = '2. பட மேம்பாடு (CLAHE)';
            S.step3 = '3. இரத்த நாளங்கள் & பாதிப்புகள்';
            S.step4 = '4. AI வெப்ப வரைபடம் (Grad-CAM)';
            S.step5 = '5. பரிசோதனை முடிவு & அறிக்கை';

            % Card 1
            S.card1Title = 'நோயாளி & கண் புகைப்படம் பதிவு';
            S.card1Sub = 'நோயாளி விவரங்களை உள்ளிட்டு கண் படத்தை பதிவேற்றவும்';
            S.lblPatientId = 'நோயாளி எண் *';
            S.lblPatientName = 'நோயாளி பெயர் *';
            S.lblAgeSex = 'வயது / பாலினம் *';
            S.lblPhcCenter = 'சுகாதார மையம்';
            S.lblSelectScan = 'பரிசோதனை படத்தை தேர்வு செய்க';
            S.dropZoneTitle = 'கண் புகைப்படத்தை இங்கே இழுத்து விடவும்';
            S.btnBrowse = 'அல்லது கோப்பை தேர்ந்தெடுக்கவும்';
            S.dropSupport = 'JPG, PNG ஆதரிக்கப்படுகிறது (அதிகபட்சம் 10MB)';
            S.btnRun = '▶  AI பரிசோதனையைத் தொடங்கு';
            S.frontlineReady = 'படத்தை ஏற்றி பரிசோதனையைத் தொடங்குங்கள்';
            S.frontlineScreening = 'AI ஆய்வு நடைபெறுகிறது...';

            % Card 2
            S.card2Title = 'கண் மருத்துவ ஆய்வு (Diagnostic Grid)';
            S.card2Sub = 'AI வழிநடத்தும் கண் விழித்திரை ஆய்வு';
            S.tile1Hdr = ' 1   அசல் கண் விழித்திரை ஸ்கேன்';
            S.badge1 = 'அசல் புகைப்படம்';
            S.tile2Hdr = ' 2   மேம்படுத்தப்பட்ட படம் (CLAHE)';
            S.badge2 = 'மேம்படுத்தப்பட்ட படம்';
            S.tile3Hdr = ' 3   இரத்த நாளங்கள் & பாதிப்புகள்';
            S.badge3 = '● நாளங்கள்   ● மைக்ரோஅனூரிசம்   ● எக்ஸுடேட்';
            S.tile4Hdr = ' 4  AI விளக்க வரைபடம் (Grad-CAM)';
            S.badge4GradCam = 'Grad-CAM காட்சி';
            S.badge4Points = 'மருத்துவர் ஆய்வு புள்ளிகள்';
            S.btnPointsMode = '①②③ புள்ளிகள்';

            % Card 3
            S.card3Title = 'AI நோய் கண்டறிதல் & முன்னுரிமை';
            S.statusComplete = '🟢 ஆய்வு முடிந்தது';
            S.statusReady = '⚪ பரிசோதனைக்கு தயார்';
            S.severityPrefix = 'தீவிரம்';
            S.triageReferable = 'பரிந்துரை தேவை';
            S.triageNonReferable = 'பாதுகாப்பானது / ஆண்டு பரிசோதனை';
            S.referableRisk = 'பரிந்துரை ஆபத்து (P ≥ 2)';
            S.classProbHdr = 'நோய் நிலை நிகழ்தகவு (ICDR)';
            S.gradeNames = {'G0 - DR பாதிப்பு இல்லை', 'G1 - லேசான NPDR', 'G2 - நடுத்தர NPDR', 'G3 - தீவிர NPDR', 'G4 - PDR'};
            S.keyFindingsTitle = '🔍  முக்கிய முடிவுகள்';
            S.btnViewDetails = 'விவரங்களை காண்க';
            S.lblEyeOrient = '👁️  கண் நோக்குநிலை';
            S.lblIqa = '🟢  படத்தின் தரம்';
            S.lblEtdrs = '🔴  ETDRS நிலை';
            S.lblLesions = '🟠  பாதிப்புகளின் எண்ணிக்கை';
            S.lblCsme = '🟡  CSME ஆபத்து';
            S.lblRoadDist = '🚗 சாலை தூரம்';
            S.lblServices = '🩺 சிகிச்சை வசதிகள்';
            S.lblHelpline = '📞 உதவி எண்';
            S.lblAdvice = 'ஆலோசனை';

            % Bottom Footer
            S.btnDoctorReport = '📄  மருத்துவர் PDF அறிக்கை';
            S.btnPatientSlip = '🖨️  நோயாளி சுகாதார சீட்டு';
            S.btnEmpathySim = '👁️  பார்வை இழப்பு மாதிரி';
            S.quoteText = '"ஆரம்ப கால பரிசோதனை, ஆரோக்கியமான கண் பார்வை."';

            % Chatbot
            S.chatbotTitle = '🤖 AI மருத்துவ உதவியாளர்';
            S.btnBackDash = '← டாஷ்போர்டுக்கு திரும்பவும்';
            S.chatPlaceholder = 'சர்க்கரை அளவு, மாத்திரைகள் அல்லது சிகிச்சை பற்றி கேளுங்கள்...';
            S.btnSendChat = 'கேளுங்கள் 🚀';
            S.chip1 = '📜 முந்தைய சிகிச்சை விவரம்';
            S.chip1Query = 'What is the patient previous visit and treatment history?';
            S.chip2 = '🩸 HbA1c மற்றும் சர்க்கரை';
            S.chip2Query = 'What is his HbA1c and diabetes status?';
            S.chip3 = '💊 உண்ணும் மருந்துகள்';
            S.chip3Query = 'What medications is the patient taking?';
            S.chip4 = '🩺 இரத்த அழுத்தம் & சிறுநீரகம்';
            S.chip4Query = 'What is his blood pressure and kidney status?';
            S.chip5 = '👁️ இன்றைய பரிசோதனை முடிவு';
            S.chip5Query = 'What is today DR grade and diagnosis?';
            S.chip6 = '💡 பார்வை இழப்பு ஏற்படுமா?';
            S.chip6Query = 'Can this condition cause blindness and what is the treatment?';

        % =================================================================
        % 5. TELUGU (తెలుగు)
        % =================================================================
        case 'te'
            S.langCode = 'te';
            S.langName = 'తెలుగు (Telugu)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'గ్రామీణ టెలి-నేత్ర పరీక్షా వేదిక';
            S.sloganTitle = 'స్పష్టమైన దృష్టి. ఆరోగ్యకరమైన సమాజం.';
            S.sloganSub = 'AI నిర్ధారణ  |  ఆశా కార్యకర్తల సహాయం  |  గ్రామీణ ఆరోగ్య సేవ';
            S.btnFullscreen = '⛶  పూర్తి స్క్రీన్';
            S.netConnected = '🟢 కనెక్ట్ అయింది';
            S.netSpeed = '512 kbps (గ్రామీణ కేంద్రం)';
            S.userRole = 'ఆరోగ్య కేంద్ర వినియోగదారు';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  డాష్‌బోర్డ్';
            S.navPatient = '👤  రోగి వివరాలు';
            S.navAnalysis = '🔠  AI విశ్లేషణ';
            S.navBatch = '📁  బ్యాచ్ స్క్రీనింగ్';
            S.navEmpathy = '👁️  దృష్టి లోపం సిమ్యులేటర్';
            S.navReports = '📄  నివేదికలు';
            S.navMonitoring = '📊  కేంద్ర పర్యవేక్షణ';
            S.navSimulink = '➿  సిమ్యులింక్ నెట్‌వర్క్';
            S.navChatbot = '🤖  AI కో-పైలట్';
            S.navSettings = '⚙️  సెట్టింగులు';
            S.navHelp = '❓  సహాయం మరియు మద్దతు';

            % Stepper Bar
            S.step1 = '1. రోగి మరియు కంటి ఫోటో';
            S.step2 = '2. చిత్రం మెరుగుదల (CLAHE)';
            S.step3 = '3. రక్తనాళాలు & సమస్యలు';
            S.step4 = '4. AI హీట్‌మ్యాప్ (Grad-CAM)';
            S.step5 = '5. నిర్ధారణ మరియు నివేదిక';

            % Card 1
            S.card1Title = 'రోగి & రెటీనా చిత్రం నమోదు';
            S.card1Sub = 'రోగి వివరాలు నమోదు చేసి కంటి చిత్రాన్ని అప్‌లోడ్ చేయండి';
            S.lblPatientId = 'రోగి ఐడీ *';
            S.lblPatientName = 'రోగి పేరు *';
            S.lblAgeSex = 'వయస్సు / లింగం *';
            S.lblPhcCenter = 'ఆరోగ్య కేంద్రం';
            S.lblSelectScan = 'పరీక్ష స్కాన్ ఎంచుకోండి';
            S.dropZoneTitle = 'రెటీనా చిత్రాన్ని ఇక్కడ లాగండి';
            S.btnBrowse = 'లేదా ఫైల్ ఎంచుకోండి';
            S.dropSupport = 'JPG, PNG అందుబాటులో ఉంది (గరిష్టంగా 10MB)';
            S.btnRun = '▶  AI స్క్రీనింగ్ ప్రారంభించండి';
            S.frontlineReady = 'స్కాన్ లోడ్ చేసి పరీక్ష ప్రారంభించండి';
            S.frontlineScreening = 'AI విశ్లేషణ కొనసాగుతోంది...';

            % Card 2
            S.card2Title = 'వైద్య విశ్లేషణ (Diagnostic Grid)';
            S.card2Sub = 'AI ఆధారిత రెటీనా చిత్ర విశ్లేషణ';
            S.tile1Hdr = ' 1   అసలు రెటీనా ఫండస్ స్కాన్';
            S.badge1 = 'అసలు చిత్రం';
            S.tile2Hdr = ' 2   మెరుగైన గ్రీన్ ఛానెల్ (CLAHE)';
            S.badge2 = 'మెరుగైన చిత్రం';
            S.tile3Hdr = ' 3   రక్తనాళాలు & సమస్యలు';
            S.badge3 = '● నాళాలు   ● మైక్రోఅన్యూరిజమ్   ● ఎక్సుడేట్';
            S.tile4Hdr = ' 4  AI వివరణ (Grad-CAM)';
            S.badge4GradCam = 'Grad-CAM ఓవర్‌లే';
            S.badge4Points = 'వైద్యుల తనిఖీ పాయింట్లు';
            S.btnPointsMode = '①②③ పాయింట్లు';

            % Card 3
            S.card3Title = 'AI నిర్ధారణ & క్లినికల్ ట్రియాజ్';
            S.statusComplete = '🟢 విశ్లేషణ పూర్తయింది';
            S.statusReady = '⚪ పరీక్షకు సిద్ధం';
            S.severityPrefix = 'తీవ్రత';
            S.triageReferable = 'రిఫరల్ అవసరం';
            S.triageNonReferable = 'సురక్షితం / వార్షిక పరీక్ష';
            S.referableRisk = 'రిఫరల్ ప్రమాదం (P ≥ 2)';
            S.classProbHdr = 'వ్యాధి సంభావ్యత (ICDR)';
            S.gradeNames = {'G0 - DR సమస్య లేదు', 'G1 - తేలికపాటి NPDR', 'G2 - మధ్యస్థ NPDR', 'G3 - తీవ్రమైన NPDR', 'G4 - PDR'};
            S.keyFindingsTitle = '🔍  ముఖ్య ఫలితాలు';
            S.btnViewDetails = 'వివరాలు చూడండి';
            S.lblEyeOrient = '👁️  కంటి దిశ';
            S.lblIqa = '🟢  చిత్ర నాణ్యత';
            S.lblEtdrs = '🔴  ETDRS దశ';
            S.lblLesions = '🟠  లక్షణాల సంఖ్య';
            S.lblCsme = '🟡  CSME ప్రమాదం';
            S.lblRoadDist = '🚗 రోడ్డు దూరం';
            S.lblServices = '🩺 అందుబాటులో ఉన్న చికిత్సలు';
            S.lblHelpline = '📞 హెల్ప్‌లైన్ నంబర్';
            S.lblAdvice = 'సలహా';

            % Bottom Footer
            S.btnDoctorReport = '📄  డాక్టర్ PDF నివేదిక';
            S.btnPatientSlip = '🖨️  రోగి ఆరోగ్య రశీదు';
            S.btnEmpathySim = '👁️  దృష్టి లోపం సిమ్యులేటర్';
            S.quoteText = '"సకాలంలో పరీక్ష, గ్రామీణ భారతదేశానికి సురక్షితమైన రేపటి భవిష్యత్తు."';

            % Chatbot
            S.chatbotTitle = '🤖 AI క్లినికల్ కో-పైలట్';
            S.btnBackDash = '← డాష్‌బోర్డ్‌కు తిరిగి వెళ్లండి';
            S.chatPlaceholder = 'గత పరీక్షలు, HbA1c, మందులు లేదా చికిత్స గురించి అడగండి...';
            S.btnSendChat = 'అడగండి 🚀';
            S.chip1 = '📜 గత సందర్శన & చికిత్స';
            S.chip1Query = 'What is the patient previous visit and treatment history?';
            S.chip2 = '🩸 HbA1c & షుగర్ స్థాయి';
            S.chip2Query = 'What is his HbA1c and diabetes status?';
            S.chip3 = '💊 వాడుతున్న మందులు';
            S.chip3Query = 'What medications is the patient taking?';
            S.chip4 = '🩺 బీపీ & కిడ్నీ పరిస్థితి';
            S.chip4Query = 'What is his blood pressure and kidney status?';
            S.chip5 = '👁️ నేటి పరీక్ష ఫలితం';
            S.chip5Query = 'What is today DR grade and diagnosis?';
            S.chip6 = '💡 చూపు పోయే ప్రమాదం ఉందా?';
            S.chip6Query = 'Can this condition cause blindness and what is the treatment?';

        % =================================================================
        % 6. ENGLISH (Default)
        % =================================================================
        otherwise
            S.langCode = 'en';
            S.langName = 'English (Default)';

            % Top Navigation
            S.appTitle = 'RETINACARE AI';
            S.appSubtitle = 'Rural Tele-Ophthalmology Screening Suite';
            S.sloganTitle = 'Clearer Vision. Healthier Communities.';
            S.sloganSub = 'AI-Powered DR Triage  |  Frontline ASHA Support  |  Scalable Rural Healthcare';
            S.btnFullscreen = '⛶  Full Screen';
            S.netConnected = '🟢 Connected';
            S.netSpeed = '512 kbps (Rural PHC)';
            S.userRole = 'PHC User';

            % Sidebar Navigation Items
            S.navDashboard = '🏠  Dashboard';
            S.navPatient = '👤  Patient Capture';
            S.navAnalysis = '🔠  AI Analysis';
            S.navBatch = '📁  Batch Processing';
            S.navEmpathy = '👁️  Vision Loss Empathy';
            S.navReports = '📄  Reports';
            S.navMonitoring = '📊  PHC Monitoring';
            S.navSimulink = '➿  Simulink Simulation';
            S.navChatbot = '🤖  AI Clinical Co-Pilot';
            S.navSettings = '⚙️  Settings';
            S.navHelp = '❓  Help & Support';

            % Stepper Bar
            S.step1 = '1. Patient & Image';
            S.step2 = '2. Image Enhancement';
            S.step3 = '3. Vasculature & Lesions';
            S.step4 = '4. AI Analysis (Grad-CAM)';
            S.step5 = '5. AI Screening & Report';

            % Card 1: Patient & Image Capture
            S.card1Title = 'Patient & Image Capture';
            S.card1Sub = 'Enter patient details and upload retinal image';
            S.lblPatientId = 'Patient ID *';
            S.lblPatientName = 'Patient Name *';
            S.lblAgeSex = 'Age / Sex *';
            S.lblPhcCenter = 'PHC Center';
            S.lblSelectScan = 'Select Clinical Test Scan';
            S.dropZoneTitle = 'Drag & drop retinal image here';
            S.btnBrowse = 'or click to browse';
            S.dropSupport = 'Supports JPG, PNG (Max 10MB)';
            S.btnRun = '▶  Run AI Screening Pipeline';
            S.frontlineReady = 'Ready to acquire scan or run screening';
            S.frontlineScreening = 'Running AI screening pipeline, please wait...';

            % Card 2: Diagnostic Analysis
            S.card2Title = 'Diagnostic Analysis';
            S.card2Sub = 'AI-powered retinal image analysis pipeline';
            S.tile1Hdr = ' 1   Raw Retinal Fundus Scan';
            S.badge1 = 'Original Image';
            S.tile2Hdr = ' 2   Enhanced Green Channel (CLAHE)';
            S.badge2 = 'Enhanced Image';
            S.tile3Hdr = ' 3   Vasculature & Lesion Detections';
            S.badge3 = '● Vessels (Cyan)  ● OD (Green)  ● MAs (Magenta)  ● Exudates (Yellow)';
            S.tile4Hdr = ' 4  Grad-CAM (XAI)';
            S.badge4GradCam = 'Grad-CAM Overlay';
            S.badge4Points = 'Inspection Points';
            S.btnPointsMode = 'Points';

            % Card 3: AI Screening & Decision Support
            S.card3Title = 'AI Screening & Decision Support';
            S.statusComplete = '🟢 Complete';
            S.statusReady = '⚪ Ready';
            S.severityPrefix = 'Severity';
            S.triageReferable = 'REFERABLE';
            S.triageNonReferable = 'NON-REFERABLE';
            S.referableRisk = 'Referable Risk (P ≥ 2)';
            S.classProbHdr = 'Class Probabilities (ICDR)';
            S.gradeNames = {'No DR (Normal)', 'Mild NPDR', 'Moderate NPDR', 'Severe NPDR', 'Proliferative DR'};
            S.keyFindingsTitle = '🔍  Key Findings';
            S.btnViewDetails = 'View Details';
            S.lblEyeOrient = '👁️  Eye Orientation';
            S.lblIqa = '🟢  Image Quality';
            S.lblEtdrs = '🔴  ETDRS Staging';
            S.lblLesions = '🟠  Lesion Counts';
            S.lblCsme = '🟡  CSME Risk';
            S.lblRoadDist = '🚗 Road Distance';
            S.lblServices = '🩺 Services';
            S.lblHelpline = '📞 Helpline';
            S.lblAdvice = 'Advice';

            % Bottom Action Footer
            S.btnDoctorReport = '📄  Export Doctor PDF Report';
            S.btnPatientSlip = '🖨️  Export Patient Health Slip';
            S.btnEmpathySim = '👁️  Vision Loss Empathy Simulator';
            S.quoteText = '⚖️ AI-assisted screening support. Final clinical assessment remains with a qualified healthcare professional.';

            % Chatbot Panel
            S.chatbotTitle = '🤖 AI Clinical EHR Co-Pilot';
            S.btnBackDash = '← Back to Dashboard';
            S.chatPlaceholder = 'Ask a question about past visits, HbA1c, treatments, or clinical advice...';
            S.btnSendChat = 'Ask AI 🚀';
            S.chip1 = '📜 Last Visit & Rx';
            S.chip1Query = 'When did he visit the last time and what treatments were given?';
            S.chip2 = '🩸 HbA1c & Diabetes';
            S.chip2Query = 'What is his HbA1c history and diabetes control status?';
            S.chip3 = '💊 Active Meds';
            S.chip3Query = 'What medications is the patient taking?';
            S.chip4 = '🩺 Systemic & BP/Kidney';
            S.chip4Query = 'What is his blood pressure and kidney status?';
            S.chip5 = '👁️ Today''s Diagnosis';
            S.chip5Query = 'What is today''s DR grade and diagnosis?';
            S.chip6 = '💡 Blindness Risk & Laser';
            S.chip6Query = 'Can this condition cause blindness and what treatment is needed?';
    end
end
