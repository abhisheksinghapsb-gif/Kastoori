function hospital = get_hospital_recommendations(grade, phcCenter)
% GET_HOSPITAL_RECOMMENDATIONS Maps Diabetic Retinopathy severity grade
% to the appropriate tiered care facility (Primary, Secondary, Tertiary, Super-Specialty)
% within the rural Indian healthcare network.
%
% Syntax:
%   hospital = get_hospital_recommendations(grade)
%   hospital = get_hospital_recommendations(grade, phcCenter)
%
% Inputs:
%   grade     - Integer [0, 4] representing ICDR DR severity
%   phcCenter - (Optional) String with PHC cluster name
%
% Outputs:
%   hospital  - Struct containing:
%               .tierLevel      : String ('Primary Care', 'Secondary', 'Tertiary', 'Super-Specialty')
%               .facilityName   : String (Recommended hospital name)
%               .address        : String (District / City address)
%               .distanceKm     : Estimated road distance from PHC
%               .urgencyWindow  : Suggested clinical referral window
%               .services       : Cell array of relevant ophthalmic services
%               .helpline       : Tele-consultation / appointment phone
%               .emergencyNote  : Actionable guidance for ASHA / patient
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1 || isempty(grade)
        grade = 0;
    end
    if nargin < 2 || isempty(phcCenter)
        phcCenter = 'PHC Rural Cluster';
    end

    switch grade
        case 0 % Healthy / No DR
            hospital.tierLevel      = 'Level 1: Primary Health Centre (PHC)';
            hospital.facilityName   = sprintf('%s - Vision Sub-Centre', phcCenter);
            hospital.address        = 'Local Panchayat Health & Wellness Centre';
            hospital.distanceKm     = 2.5;
            hospital.urgencyWindow  = 'ROUTINE ANNUAL RESCREEN (12 Months)';
            hospital.services       = {'Visual Acuity Check', 'Blood Glucose / HbA1c Monitoring', 'Dietary & Lifestyle Counseling'};
            hospital.helpline       = '104 (National Health Helpline)';
            hospital.emergencyNote  = 'No sight-threatening lesions. Continue glycemic control and retest in 1 year.';

        case 1 % Mild NPDR (Microaneurysms only)
            hospital.tierLevel      = 'Level 1+: Community Health Centre (CHC)';
            hospital.facilityName   = 'Taluk Community Health Centre & Vision Clinic';
            hospital.address        = 'Taluk HQ Hospital, Sub-District Road';
            hospital.distanceKm     = 14.0;
            hospital.urgencyWindow  = 'MONITORING REVIEW (6 - 12 Months)';
            hospital.services       = {'Optometric Refraction', 'Blood Pressure & Lipid Profile', 'Fundus Image Tracking'};
            hospital.helpline       = '+91 80 2846 1002 (CHC Helpdesk)';
            hospital.emergencyNote  = 'Early microaneurysms detected. Strict blood sugar control prevents progression to vision loss.';

        case 2 % Moderate NPDR (Exudates + Hemorrhages)
            hospital.tierLevel      = 'Level 2: Secondary District Eye Hospital';
            hospital.facilityName   = 'Kolar District Hospital - Ophthalmic Division';
            hospital.address        = 'Hospital Road, Kolar Town, Karnataka - 563101';
            hospital.distanceKm     = 28.5;
            hospital.urgencyWindow  = 'SECONDARY REFERRAL WITHIN 30 DAYS';
            hospital.services       = {'Dilated Slit-Lamp Biomicroscopy', 'Indirect Ophthalmoscopy', 'Macular Edema Evaluation', 'Medical Glycemic Stabilization'};
            hospital.helpline       = '+91 8152 222 344 (District Eye OPD)';
            hospital.emergencyNote  = 'Significant vascular leakage detected. Specialist dilated fundus examination required to preserve vision.';

        case 3 % Severe NPDR (Extensive 4-quadrant hemorrhages)
            hospital.tierLevel      = 'Level 3: Tertiary Medical College & Eye Institute';
            hospital.facilityName   = 'Minto Regional Institute of Ophthalmology (Govt. Medical College)';
            hospital.address        = 'AV Road, Chamarajpet, Bengaluru, Karnataka - 560002';
            hospital.distanceKm     = 54.0;
            hospital.urgencyWindow  = 'HIGH PRIORITY REFERRAL WITHIN 14 DAYS';
            hospital.services       = {'Optical Coherence Tomography (OCT)', 'Fundus Fluorescein Angiography (FFA)', 'Pan-Retinal Photocoagulation (PRP Laser)', 'Anti-VEGF Assessment'};
            hospital.helpline       = '+91 80 2670 1555 (Minto Triage Desk)';
            hospital.emergencyNote  = 'Severe ischemia detected. High risk of converting to Proliferative DR. Timely laser therapy prevents blindness.';

        case 4 % Proliferative DR (Neovascularization, PDR)
            hospital.tierLevel      = 'Level 4: Vitreoretinal Super-Specialty Tertiary Hospital';
            hospital.facilityName   = 'Narayana Nethralaya - Vitreoretinal Emergency Services';
            hospital.address        = '121/C, West of Chord Road, Rajajinagar, Bengaluru - 560010';
            hospital.distanceKm     = 62.0;
            hospital.urgencyWindow  = 'URGENT MEDICAL INTERVENTION (< 48 HOURS)';
            hospital.services       = {'Intravitreal Anti-VEGF Injections', 'Emergency Vitrectomy Surgery', 'Endolaser Photocoagulation', 'Tractional Detachment Repair'};
            hospital.helpline       = '+91 80 6612 1618 (Emergency Retina Line)';
            hospital.emergencyNote  = 'CRITICAL: Neovascularization and hemorrhage threat. Immediate tertiary vitreoretinal care required to prevent permanent blindness.';

        otherwise
            hospital = get_hospital_recommendations(0, phcCenter);
    end
end
