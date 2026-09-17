function stats = phc_monitoring_analytics(phcCenterName, timeWindow, severityFilter)
% PHC_MONITORING_ANALYTICS Epidemiological Screening Analytics & KPI Engine
% for Rural Health Centers in Karnataka (Kolar District #04).
%
% Syntax:
%   stats = phc_monitoring_analytics()
%   stats = phc_monitoring_analytics(phcCenterName, timeWindow, severityFilter)
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1 || isempty(phcCenterName)
        phcCenterName = 'PHC Mulbagal, Kolar District #04';
    end
    if nargin < 2 || isempty(timeWindow)
        timeWindow = 'Current Month (Sep 2026)';
    end
    if nargin < 3 || isempty(severityFilter)
        severityFilter = 'All Grades';
    end

    stats = struct();
    stats.phcName = phcCenterName;
    stats.timeWindow = timeWindow;
    stats.severityFilter = severityFilter;

    % Dynamic baseline scaling based on center and time window
    scaleFactor = 1.0;
    if contains(phcCenterName, 'All Centers')
        scaleFactor = 3.2;
    elseif contains(phcCenterName, 'Srinivaspur')
        scaleFactor = 0.85;
    elseif contains(phcCenterName, 'Bangarapet')
        scaleFactor = 1.15;
    end

    timeScale = 1.0;
    if contains(timeWindow, 'Last Quarter')
        timeScale = 2.8;
    elseif contains(timeWindow, 'Year-to-Date')
        timeScale = 9.5;
    end

    effectiveScale = scaleFactor * timeScale;
    stats.totalScreened = max(10, round(184 * effectiveScale));
    stats.diabeticCohortSize = max(stats.totalScreened + 50, round(312 * effectiveScale));
    stats.screeningCoveragePercent = min(98.5, round((stats.totalScreened / stats.diabeticCohortSize) * 100, 1));

    % Grade distribution counts
    g0 = round(92 * effectiveScale);
    g1 = round(44 * effectiveScale);
    g2 = round(31 * effectiveScale);
    g3 = round(12 * effectiveScale);
    g4 = max(1, round(5 * effectiveScale));
    tot = g0 + g1 + g2 + g3 + g4;

    stats.grades = struct('grade', {0, 1, 2, 3, 4}, ...
                          'name', {'No DR (G0)', 'Mild NPDR (G1)', 'Moderate NPDR (G2)', 'Severe NPDR (G3)', 'PDR (G4)'}, ...
                          'count', {g0, g1, g2, g3, g4}, ...
                          'percent', {round((g0/tot)*100, 1), round((g1/tot)*100, 1), round((g2/tot)*100, 1), round((g3/tot)*100, 1), round((g4/tot)*100, 1)}, ...
                          'color', {[0.55, 0.60, 0.68], [0.15, 0.70, 0.40], [0.95, 0.60, 0.10], [0.90, 0.30, 0.15], [0.75, 0.15, 0.40]});

    % Clinical KPIs
    stats.referableDRCount = g2 + g3 + g4;
    stats.referableDRPercent = round((stats.referableDRCount / tot) * 100, 1);
    stats.urgentInterventionCount = g3 + g4;
    stats.earlyDetectionSuccessRate = 89.6; % Detected before vision loss
    stats.hospitalReferralCompliance = 82.4; % Attended secondary OPD
    stats.ashaWorkerCount = max(8, round(14 * scaleFactor));
    stats.teleOphthalmologyUptime = 99.4;

    % Monthly trajectory (Last 5 months)
    months = {'May', 'Jun', 'Jul', 'Aug', 'Sep'};
    vol = round([95, 120, 148, 162, 184] * scaleFactor);
    comp = [74.2, 76.1, 78.9, 81.0, 82.4];
    stats.monthlyTrajectory = struct('months', {months}, 'volumes', vol, 'compliance', comp);

    % Generate Representative Patient Cohort Table Data
    allPatients = {
        'IND-PHC-2026-0814', 'Ramesh Kumar',    '58 / M', 'PHC Mulbagal',   '14-Sep-2026', 'Grade 0: Normal',     'Routine Rescreen (12 Mo)', 'Completed';
        'IND-PHC-2026-0815', 'Sunita Devi',     '52 / F', 'PHC Mulbagal',   '14-Sep-2026', 'Grade 1: Mild NPDR',  'Review in 6-12 Mo',        'Attended';
        'IND-PHC-2026-0816', 'Manjunath Gowda', '64 / M', 'PHC Srinivaspur','13-Sep-2026', 'Grade 2: Mod NPDR',   'Referral (30 Days)',       'Scheduled';
        'IND-PHC-2026-0817', 'Lakshmi Bai',     '49 / F', 'PHC Mulbagal',   '13-Sep-2026', 'Grade 0: Normal',     'Routine Rescreen (12 Mo)', 'Completed';
        'IND-PHC-2026-0818', 'Venkatesh Murthy','61 / M', 'PHC Bangarapet', '12-Sep-2026', 'Grade 3: Severe NPDR', 'Urgent Referral (<48h)',   'Referred OPD';
        'IND-PHC-2026-0819', 'Fatima Begum',    '55 / F', 'PHC Mulbagal',   '12-Sep-2026', 'Grade 1: Mild NPDR',  'Review in 6-12 Mo',        'Completed';
        'IND-PHC-2026-0820', 'Chinnappa Reddy', '67 / M', 'PHC Srinivaspur','11-Sep-2026', 'Grade 4: PDR',        'Emergency Laser / AntiVEGF','Admitted';
        'IND-PHC-2026-0821', 'Anusuya Amma',    '53 / F', 'PHC Mulbagal',   '10-Sep-2026', 'Grade 0: Normal',     'Routine Rescreen (12 Mo)', 'Completed';
        'IND-PHC-2026-0822', 'Govindaiah S.',   '59 / M', 'PHC Bangarapet', '09-Sep-2026', 'Grade 2: Mod NPDR',   'Referral (30 Days)',       'Attended';
        'IND-PHC-2026-0823', 'Padma Sharma',    '46 / F', 'PHC Mulbagal',   '08-Sep-2026', 'Grade 0: Normal',     'Routine Rescreen (12 Mo)', 'Completed';
        'IND-PHC-2026-0824', 'Basavaraj H.',    '63 / M', 'PHC Srinivaspur','07-Sep-2026', 'Grade 1: Mild NPDR',  'Review in 6-12 Mo',        'Completed';
        'IND-PHC-2026-0825', 'Radha Krishna',   '56 / M', 'PHC Mulbagal',   '06-Sep-2026', 'Grade 3: Severe NPDR', 'Urgent Referral (<48h)',   'Scheduled';
        'IND-PHC-2026-0826', 'Kamalamma N.',    '70 / F', 'PHC Bangarapet', '05-Sep-2026', 'Grade 0: Normal',     'Routine Rescreen (12 Mo)', 'Completed';
        'IND-PHC-2026-0827', 'Narayana Swamy',  '51 / M', 'PHC Mulbagal',   '04-Sep-2026', 'Grade 1: Mild NPDR',  'Review in 6-12 Mo',        'Completed';
        'IND-PHC-2026-0828', 'Shanthamma G.',   '65 / F', 'PHC Srinivaspur','03-Sep-2026', 'Grade 2: Mod NPDR',   'Referral (30 Days)',       'Pending Review'
    };

    % Filter by sub-centre if specified
    if ~contains(phcCenterName, 'All Centers')
        matchIdx = false(size(allPatients, 1), 1);
        shortName = 'Mulbagal';
        if contains(phcCenterName, 'Srinivaspur'), shortName = 'Srinivaspur'; end
        if contains(phcCenterName, 'Bangarapet'), shortName = 'Bangarapet'; end
        for p = 1:size(allPatients, 1)
            if contains(allPatients{p, 4}, shortName)
                matchIdx(p) = true;
            end
        end
        if any(matchIdx)
            allPatients = allPatients(matchIdx, :);
        end
    end

    % Filter by severity if specified
    if contains(severityFilter, 'Referable')
        matchIdx = false(size(allPatients, 1), 1);
        for p = 1:size(allPatients, 1)
            if contains(allPatients{p, 6}, 'Grade 2') || ...
               contains(allPatients{p, 6}, 'Grade 3') || ...
               contains(allPatients{p, 6}, 'Grade 4')
                matchIdx(p) = true;
            end
        end
        if any(matchIdx)
            allPatients = allPatients(matchIdx, :);
        end
    end

    stats.cohortTableData = allPatients;
    stats.cohortTableHeaders = {'Patient ID', 'Patient Name', 'Age / Sex', 'PHC Sub-Centre', 'Date Screened', 'AI DR Staging', 'Triage Recommendation', 'Follow-up Status'};
end
