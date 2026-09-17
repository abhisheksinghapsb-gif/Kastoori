function patientRecord = patient_ehr_database(patientId, patientName)
% PATIENT_EHR_DATABASE Longitudinal Electronic Health Record (EHR) service
% storing comprehensive medical history (both DR-related and systemic/unrelated),
% prior visits, past treatments, and compliance tracking for tele-ophthalmology screening.
%
% Syntax:
%   record = patient_ehr_database(patientId)
%   record = patient_ehr_database(patientId, patientName)
%
% Outputs:
%   patientRecord - Struct with fields:
%                   .demographics     : Name, age, sex, phone, address, PHC
%                   .diabetesProfile  : T2D duration, HbA1c %, FBS, PPBS
%                   .systemicHistory  : Hypertension, nephropathy, cardiac, lipid
%                   .currentMeds      : List of active medications & dosages
%                   .ophthalmicHistory: Visual acuity, prior DR grade, prior laser, IOP
%                   .visitHistory     : Array of past visit records (dates, doctor, treatments)
%                   .complianceStatus : Overdue flags and risk alerts
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1 || isempty(patientId)
        patientId = 'IND-PHC-2026-0814';
    end
    if nargin < 2 || isempty(patientName)
        patientName = 'Ramesh Kumar';
    end

    % Standardize ID key
    cleanId = upper(regexprep(patientId, '[^a-zA-Z0-9]', ''));

    % Database of registered longitudinal patients
    switch cleanId
        case {'INDPHC20260814', '0814', 'RAMESH', 'RAMESHKUMAR'}
            r.id   = 'IND-PHC-2026-0814';
            r.name = 'Ramesh Kumar';
            r.age  = 58;
            r.sex  = 'Male';
            r.phone = '+91 98452-19283';
            r.phc   = 'PHC Mulbagal, Kolar District #04';
            r.village = 'Bylahalli Village, Mulbagal Taluk';

            % Systemic & Unrelated Medical History
            r.diabetesDurationYears = 11;
            r.diabetesType          = 'Type 2 Diabetes Mellitus';
            r.lastHbA1c             = 8.9; % Elevated
            r.hba1cDate             = '15-Jul-2026 (2 months ago)';
            r.fbs                   = 168; % mg/dL
            r.ppbs                  = 224; % mg/dL
            r.hypertension          = 'Stage 1 Essential Hypertension (6 years duration)';
            r.bloodPressure         = '138 / 88 mmHg (Moderately Controlled)';
            r.nephropathy           = 'Early Diabetic Nephropathy (Microalbuminuria positive, 48 mg/g)';
            r.eGFR                  = '74 mL/min/1.73m² (CKD Stage 2 - Mild impairment)';
            r.cardiovascular        = 'No history of Myocardial Infarction or Angina. Normal ECG (Jan 2026).';
            r.dyslipidemia          = 'Hypercholesterolemia (Total Cholesterol: 218 mg/dL, LDL: 134 mg/dL)';
            r.allergies             = 'No known drug allergies (NKDA).';

            % Active Medications
            r.medications = {
                'Metformin 1000 mg BD (After meals)', ...
                'Glimepiride 2 mg OD (Before breakfast)', ...
                'Telmisartan 40 mg OD (Morning, for BP & renal protection)', ...
                'Atorvastatin 20 mg HS (Night, for lipid control)', ...
                'Carboxymethylcellulose 0.5% eye drops (TDS as needed for dry eyes)'
            };

            % Prior Ophthalmic History
            r.visualAcuityOD       = '6/9 (Best-corrected with +1.50 DS)';
            r.visualAcuityOS       = '6/18 (Pin-hole improves to 6/12)';
            r.iop                  = '16 mmHg OD  |  17 mmHg OS (Normal Goldman Applanation)';
            r.priorLaser           = 'Focal Argon Laser Photocoagulation (Left Eye OS, June 2025 for macular edema)';
            r.priorInjections      = 'None. Anti-VEGF (Bevacizumab) was advised if edema recurred.';
            r.priorCataractSurgery = 'None. Early nuclear sclerosis (Grade 1+) both eyes.';

            % Visit Timeline (Chronological History)
            r.visits = [
                struct('date', '18-Jan-2026 (8 months ago)', ...
                       'facility', 'PHC Mulbagal Eye Camp', ...
                       'clinician', 'Dr. Arvind Swaminathan (Consultant Ophthalmologist)', ...
                       'drGrade', 'Grade 1 (Mild NPDR - Isolated microaneurysms)', ...
                       'treatmentGiven', 'Refraction updated, lubricant drops prescribed, glycemic counseling.', ...
                       'clinicalNotes', 'Fundus showed 4 microaneurysms temporal to macula OD. OS stable post-laser. Advised strict HbA1c <7.0% and 6-month repeat DR screen.'), ...
                struct('date', '12-Jun-2025 (15 months ago)', ...
                       'facility', 'District Hospital Kolar (Ophthalmology OPD)', ...
                       'clinician', 'Dr. Meenakshi Sundaram (Vitreoretinal Specialist)', ...
                       'drGrade', 'Grade 2 (Moderate NPDR with Focal Macular Edema OS)', ...
                       'treatmentGiven', 'Underwent Single-session Focal Argon Laser Photocoagulation OS.', ...
                       'clinicalNotes', 'Leakage from microaneurysms 650 um from fovea OS. Post-laser visual acuity preserved at 6/12.')
            ];

            r.lastVisitDate    = '18-Jan-2026 (8 months ago)';
            r.isOverdueReview  = true;
            r.overdueMonths    = 2;
            r.complianceAlert  = '⚠️ OVERDUE FOR SCREENING: 6-month follow-up was due in July 2026 (2 months late). HbA1c 8.9% indicates high risk of progression.';

        case {'INDPHC20260481', '0481', 'SUNITA', 'SUNITASHARMA'}
            r.id   = 'IND-PHC-2026-0481';
            r.name = 'Sunita Sharma';
            r.age  = 52;
            r.sex  = 'Female';
            r.phone = '+91 94481-88219';
            r.phc   = 'PHC Devanahalli, Bangalore Rural';
            r.village = 'Bettakote Village';

            r.diabetesDurationYears = 7;
            r.diabetesType          = 'Type 2 Diabetes Mellitus';
            r.lastHbA1c             = 7.4;
            r.hba1cDate             = '10-Aug-2026 (1 month ago)';
            r.fbs                   = 134;
            r.ppbs                  = 178;
            r.hypertension          = 'Mild Hypertension (3 years duration)';
            r.bloodPressure         = '126 / 82 mmHg (Well Controlled)';
            r.nephropathy           = 'Normal Renal Function (Urine ACR: 14 mg/g, eGFR: 88 mL/min)';
            r.cardiovascular        = 'No cardiovascular disease.';
            r.dyslipidemia          = 'Mild Dyslipidemia (Total Chol: 194 mg/dL)';
            r.allergies             = 'Sulfonamide allergy.';

            r.medications = {
                'Metformin 500 mg BD', ...
                'Vildagliptin 50 mg BD', ...
                'Amlodipine 5 mg OD'
            };

            r.visualAcuityOD       = '6/6 (Normal)';
            r.visualAcuityOS       = '6/6 (Normal)';
            r.iop                  = '14 mmHg OD  |  15 mmHg OS';
            r.priorLaser           = 'None';
            r.priorInjections      = 'None';
            r.priorCataractSurgery = 'None';

            r.visits = [
                struct('date', '14-Feb-2026 (7 months ago)', ...
                       'facility', 'PHC Devanahalli Annual Diabetic Screening', ...
                       'clinician', 'Dr. Radhika Rao (General Physician / Tele-Ophthalmology)', ...
                       'drGrade', 'Grade 0 (No Diabetic Retinopathy)', ...
                       'treatmentGiven', 'Lifestyle counseling, dietary advice.', ...
                       'clinicalNotes', 'Both retinas clear. Optic disc sharp, macula healthy. Advised annual screening.')
            ];

            r.lastVisitDate    = '14-Feb-2026 (7 months ago)';
            r.isOverdueReview  = false;
            r.overdueMonths    = 0;
            r.complianceAlert  = '🟢 COMPLIANT: Routine annual follow-up on schedule. Glycemic control stable.';

        otherwise
            % Dynamic synthetic baseline for unknown / browsed patient IDs
            r.id   = patientId;
            r.name = patientName;
            r.age  = 55;
            r.sex  = 'Undisclosed';
            r.phone = '+91 9XXXX-XXXXX';
            r.phc   = 'Primary Health Centre (PHC Screening Unit)';
            r.village = 'Registered Screening Catchment Area';

            r.diabetesDurationYears = 8;
            r.diabetesType          = 'Type 2 Diabetes Mellitus';
            r.lastHbA1c             = 8.2;
            r.hba1cDate             = 'Recent Clinical Record';
            r.fbs                   = 155;
            r.ppbs                  = 210;
            r.hypertension          = 'Essential Hypertension (Controlled on medication)';
            r.bloodPressure         = '134 / 84 mmHg';
            r.nephropathy           = 'Mild Microalbuminuria reported';
            r.eGFR                  = '80 mL/min/1.73m² (Normal-Mild)';
            r.cardiovascular        = 'No acute cardiac history';
            r.dyslipidemia          = 'Hyperlipidemia managed on statin therapy';
            r.allergies             = 'No documented adverse drug reactions';

            r.medications = {
                'Metformin 850 mg BD', ...
                'Glimepiride 1 mg OD', ...
                'Enalapril 5 mg OD'
            };

            r.visualAcuityOD       = '6/9';
            r.visualAcuityOS       = '6/9';
            r.iop                  = '15 mmHg OD / OS';
            r.priorLaser           = 'None documented';
            r.priorInjections      = 'None';
            r.priorCataractSurgery = 'Clear lenses bilaterally';

            r.visits = [
                struct('date', '10-Nov-2025 (10 months ago)', ...
                       'facility', 'PHC Community Eye Screening Camp', ...
                       'clinician', 'Duty Tele-Ophthalmology Officer', ...
                       'drGrade', 'Grade 1 (Mild NPDR)', ...
                       'treatmentGiven', 'Advised strict dietary glycemic regulation and 6-month ophthalmology rescreening.', ...
                       'clinicalNotes', 'Isolated microaneurysm documented. No exudates or center-involving edema.')
            ];

            r.lastVisitDate    = '10-Nov-2025 (10 months ago)';
            r.isOverdueReview  = true;
            r.overdueMonths    = 4;
            r.complianceAlert  = '⚠️ OVERDUE FOR ANNUAL RESCREENING: Patient was due for follow-up 4 months ago.';
    end

    patientRecord = r;
end
