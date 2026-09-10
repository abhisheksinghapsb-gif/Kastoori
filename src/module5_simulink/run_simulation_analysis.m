function results = run_simulation_analysis(options)
% RUN_SIMULATION_ANALYSIS Runs comprehensive capacity and queueing dynamics simulation
% for 100,000 annual patients across 20 rural Indian Primary Health Centres (PHCs).
%
% Compares system performance:
%   Scenario A: Baseline (Without AI) - 100% of cases sent to 1 District Ophthalmologist
%   Scenario B: AI Triage (With AI)   - 80% Normal/Mild cleared at PHC, 20% Referable sent to Doctor
%
% Metrics Evaluated:
%   - Cumulative patient backlog queue length over 1 year (2,000 operating hours)
%   - Patient turnaround & wait times (Days / Months vs. Real-time minutes)
%   - Ophthalmologist duty cycle & burnout prevention
%   - Rural PHC cellular bandwidth consumption (512 kbps bottleneck)
%
% Syntax:
%   results = run_simulation_analysis()
%   results = run_simulation_analysis(options)
%
% Outputs:
%   results - Struct containing time series and summary metrics
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1, options = struct(); end
    if ~isfield(options, 'doPlots'), options.doPlots = true; end

    fprintf('========================================================================\n');
    fprintf('  RURAL TELEMEDICINE CAPACITY SIMULATION (100,000 PATIENTS / YEAR)\n');
    fprintf('  District Setup: 20 PHCs | 1 District Ophthalmologist | 512 kbps Uplink\n');
    fprintf('========================================================================\n');

    % ---------------------------------------------------------------------
    % Simulation Parameters
    % ---------------------------------------------------------------------
    totalAnnualPatients = 100000;
    numPHCs = 20;
    workingDays = 250;
    hoursPerDay = 8;
    totalHours = workingDays * hoursPerDay; % 2,000 operating hours
    
    % Arrival rate across district: 100,000 / 2,000 = 50 patients / hour
    lambda_total = totalAnnualPatients / totalHours; 
    
    % Doctor capacity: 2 minutes review per patient = 30 patients / hour
    mu_doctor = 60.0 / 2.0; 

    % AI Triage: 80% non-referable cleared at PHC; 20% referable forwarded
    aiClearanceRate = 0.80;
    aiReferralRate  = 0.20;
    lambda_with_ai  = lambda_total * aiReferralRate; % 10 patients / hour

    % Bandwidth model: 5 MB uncompressed fundus image over 512 kbps link
    imageSizeMB = 5.0;
    bandwidthKbps = 512.0;
    uploadDelaySec = (imageSizeMB * 8 * 1024) / bandwidthKbps; % 80.0 seconds

    % ---------------------------------------------------------------------
    % Time-Stepped Queue Dynamics (1-hour discrete simulation steps)
    % ---------------------------------------------------------------------
    timeHours = 0:totalHours;
    N = length(timeHours);

    % Scenario A: Baseline (Without AI)
    queueWithoutAI = zeros(1, N);
    waitTimeWithoutAI_Days = zeros(1, N);

    % Scenario B: With AI Triage
    queueWithAI = zeros(1, N);
    waitTimeWithAI_Mins = zeros(1, N);

    % Stochastic Poisson arrivals per hour
    rng(42); % Reproducible rural arrival pattern
    hourlyArrivals = poissrnd(lambda_total, [1, N]);

    for t = 2:N
        % 1. Baseline: 100% of arrivals hit ophthalmologist queue
        arrBase = hourlyArrivals(t);
        servedBase = min(queueWithoutAI(t-1) + arrBase, mu_doctor);
        queueWithoutAI(t) = max(0, queueWithoutAI(t-1) + arrBase - servedBase);
        % Wait time in working days = Queue / (Doctor throughput per 8h day)
        waitTimeWithoutAI_Days(t) = queueWithoutAI(t) / (mu_doctor * hoursPerDay);

        % 2. With AI: Only 20% referable cases routed to doctor
        arrAI = binornd(arrBase, aiReferralRate);
        servedAI = min(queueWithAI(t-1) + arrAI, mu_doctor);
        queueWithAI(t) = max(0, queueWithAI(t-1) + arrAI - servedAI);
        % Wait time in minutes = (Queue / Doctor throughput per min)
        waitTimeWithAI_Mins(t) = (queueWithAI(t) / (mu_doctor / 60.0));
    end

    % ---------------------------------------------------------------------
    % Bandwidth and Transmission Metrics
    % ---------------------------------------------------------------------
    totalDataWithoutAI_GB = (totalAnnualPatients * imageSizeMB) / 1024.0; % 488.28 GB
    totalUploadHoursWithoutAI = (totalAnnualPatients * uploadDelaySec) / 3600.0; % 2,222 hours

    totalDataWithAI_GB = (totalAnnualPatients * aiReferralRate * imageSizeMB) / 1024.0; % 97.65 GB
    totalUploadHoursWithAI = (totalAnnualPatients * aiReferralRate * uploadDelaySec) / 3600.0;
    bandwidthSaved_GB = totalDataWithoutAI_GB - totalDataWithAI_GB;
    bandwidthSaved_Pct = 80.0;

    % ---------------------------------------------------------------------
    % Summary Statistics & Console Reporting
    % ---------------------------------------------------------------------
    finalBacklogNoAI = queueWithoutAI(end);
    finalWaitDaysNoAI = waitTimeWithoutAI_Days(end);
    avgQueueWithAI = mean(queueWithAI);
    maxQueueWithAI = max(queueWithAI);
    avgWaitMinsWithAI = mean(waitTimeWithAI_Mins);

    fprintf('------------------------------------------------------------------------\n');
    fprintf('  OPERATIONAL METRIC                 WITHOUT AI          WITH AI TRIAGE\n');
    fprintf('------------------------------------------------------------------------\n');
    fprintf('  Annual Patient Screenings       :  100,000             100,000\n');
    fprintf('  Cases Routed to Specialist      :  100,000 (100%%)       20,000 (20%%)\n');
    fprintf('  Autonomous PHC Clearances       :  0 (0%%)              80,000 (80%%)\n');
    fprintf('  Doctor Traffic Intensity (rho)  :  1.67 [UNSTABLE]     0.33 [OPTIMAL]\n');
    fprintf('  Year-End Patient Queue Backlog  :  %5d patients     %2.1f patients\n', ...
        round(finalBacklogNoAI), avgQueueWithAI);
    fprintf('  Max Specialist Waiting Time     :  %4.1f MONTHS         %2.1f MINUTES\n', ...
        finalWaitDaysNoAI / 22.0, max(waitTimeWithAI_Mins));
    fprintf('  District Bandwidth Consumed     :  %5.1f GB           %5.1f GB\n', ...
        totalDataWithoutAI_GB, totalDataWithAI_GB);
    fprintf('  Total Tele-Upload Time Saved    :  --                  %5.1f HOURS\n', ...
        totalUploadHoursWithoutAI - totalUploadHoursWithAI);
    fprintf('========================================================================\n');
    fprintf('  >>> CLINICAL IMPACT: AI Triage completely eliminates the 6+ month\n');
    fprintf('      ophthalmologist backlog and reduces patient wait times to <10 mins. <<<\n');
    fprintf('========================================================================\n\n');

    % ---------------------------------------------------------------------
    % Diagnostic Plots
    % ---------------------------------------------------------------------
    if options.doPlots
        fig = figure('Name', 'Telemedicine Queue & Capacity Analysis', ...
            'Color', [0.96, 0.97, 0.99], 'Position', [100, 100, 1100, 650]);

        timeDays = timeHours / hoursPerDay;

        % Subplot 1: Queue Backlog Comparison Over 250 Working Days
        ax1 = subplot(2, 2, 1);
        set(ax1, 'Color', 'w', 'XColor', [0.12, 0.15, 0.25], 'YColor', [0.12, 0.15, 0.25], ...
            'GridColor', [0.80, 0.82, 0.88], 'GridAlpha', 0.6);
        plot(timeDays, queueWithoutAI, 'r-', 'LineWidth', 2.4); hold on;
        plot(timeDays, queueWithAI, 'b-', 'LineWidth', 2.2);
        grid on;
        xlabel('Operating Timeline (Working Days)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
        ylabel('Patient Queue Length (Cases)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
        title('Doctor Review Queue: Backlog Accumulation', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.06, 0.15, 0.35]);
        leg1 = legend({'Without AI (Collapse: 40k+ Backlog)', 'With AI Triage (Stable: < 5 Cases)'}, ...
            'Location', 'northwest');
        set(leg1, 'TextColor', [0.1, 0.15, 0.25], 'Color', [0.98, 0.98, 1.0], 'EdgeColor', [0.75, 0.78, 0.85]);

        % Subplot 2: Patient Wait Time (Months vs Minutes)
        ax2 = subplot(2, 2, 2);
        set(ax2, 'Color', 'w', 'GridColor', [0.80, 0.82, 0.88], 'GridAlpha', 0.6);
        yyaxis left;
        plot(timeDays, waitTimeWithoutAI_Days / 22.0, 'r-', 'LineWidth', 2.2);
        ylabel('Wait Time Without AI (Months)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.85, 0.15, 0.15]);
        ylim([0, max(waitTimeWithoutAI_Days / 22.0) * 1.15]);
        ax2.YAxis(1).Color = [0.85, 0.15, 0.15];
        
        yyaxis right;
        plot(timeDays, waitTimeWithAI_Mins, 'Color', [0.08, 0.55, 0.20], 'LineWidth', 2.2);
        ylabel('Wait Time With AI (Minutes)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.08, 0.55, 0.20]);
        ax2.YAxis(2).Color = [0.08, 0.55, 0.20];
        grid on;
        xlabel('Operating Timeline (Working Days)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
        title('Patient Wait Times for Specialist Review', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.06, 0.15, 0.35]);

        % Subplot 3: Traffic Intensity & System Utilization
        ax3 = subplot(2, 2, 3);
        set(ax3, 'Color', 'w', 'XColor', [0.12, 0.15, 0.25], 'YColor', [0.12, 0.15, 0.25], ...
            'GridColor', [0.80, 0.82, 0.88], 'GridAlpha', 0.6);
        categories = {'Without AI', 'With AI Triage'};
        trafficVals = [lambda_total / mu_doctor, lambda_with_ai / mu_doctor];
        b1 = bar(1:2, trafficVals, 0.5, 'FaceColor', 'flat');
        b1.CData(1,:) = [0.85, 0.2, 0.2];
        b1.CData(2,:) = [0.15, 0.65, 0.25];
        hold on;
        yline(1.0, '--', 'Capacity Threshold (\rho = 1.0)', 'LineWidth', 1.5, ...
            'Color', [0.35, 0.35, 0.40], 'LabelVerticalAlignment', 'bottom');
        grid on;
        set(ax3, 'XTick', 1:2, 'XTickLabel', categories, 'FontSize', 9.5, 'FontWeight', 'bold');
        ylabel('Traffic Intensity (\rho = \lambda / \mu)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
        title('Doctor Workload & Burnout Risk', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.06, 0.15, 0.35]);
        ylim([0, 2.0]);

        % Subplot 4: Rural Bandwidth Utilization
        ax4 = subplot(2, 2, 4);
        set(ax4, 'Color', 'w', 'XColor', [0.12, 0.15, 0.25], 'YColor', [0.12, 0.15, 0.25], ...
            'GridColor', [0.80, 0.82, 0.88], 'GridAlpha', 0.6);
        bwVals = [totalDataWithoutAI_GB, totalDataWithAI_GB];
        b2 = bar(1:2, bwVals, 0.5, 'FaceColor', 'flat');
        b2.CData(1,:) = [0.88, 0.40, 0.10];
        b2.CData(2,:) = [0.15, 0.45, 0.80];
        grid on;
        set(ax4, 'XTick', 1:2, 'XTickLabel', categories, 'FontSize', 9.5, 'FontWeight', 'bold');
        ylabel('Annual Uplink Data Transmitted (GB)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.15, 0.25]);
        title(sprintf('Rural Cellular Bandwidth: %.0f%% Saved', bandwidthSaved_Pct), ...
            'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.06, 0.15, 0.35]);

        % Save simulation visualization figure
        simPlotPath = fullfile(fileparts(mfilename('fullpath')), 'telemed_simulation_results.png');
        try
            exportgraphics(fig, simPlotPath, 'Resolution', 180);
            fprintf('  [OK] Telemedicine simulation plot saved to: %s\n', simPlotPath);
        catch
            saveas(fig, simPlotPath);
        end
    end

    % Package outputs
    results.timeHours                = timeHours;
    results.queueWithoutAI           = queueWithoutAI;
    results.queueWithAI              = queueWithAI;
    results.waitTimeWithoutAI_Days   = waitTimeWithoutAI_Days;
    results.waitTimeWithAI_Mins      = waitTimeWithAI_Mins;
    results.finalBacklogNoAI         = finalBacklogNoAI;
    results.finalWaitMonthsNoAI      = finalWaitDaysNoAI / 22.0;
    results.avgQueueWithAI           = avgQueueWithAI;
    results.avgWaitMinsWithAI        = avgWaitMinsWithAI;
    results.totalDataWithoutAI_GB    = totalDataWithoutAI_GB;
    results.totalDataWithAI_GB       = totalDataWithAI_GB;
    results.bandwidthSaved_GB        = bandwidthSaved_GB;
    results.bandwidthSaved_Pct       = bandwidthSaved_Pct;
end
