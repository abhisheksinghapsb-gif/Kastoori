function simResults = simulate_rural_network(imageBytes, modelInferTimeSec)
% SIMULATE_RURAL_NETWORK MathWorks SIH Special Feature:
% Tele-Ophthalmology Edge vs. Cloud Rural Network Simulation
%
% Models image transmission latency, packet loss, and power consumption across:
%   1. Rural 512 kbps PHC Link (VSAT / DSL)
%   2. 2G Edge Network (128 kbps)
%   3. 4G Rural Cell Tower (10 Mbps)
%   4. On-Device Edge AI (MATLAB SqueezeNet / ResNet) - Zero Network Latency
%
% SIH Problem Statement 26038 | MathWorks Sponsored Prototype

    if nargin < 1 || isempty(imageBytes)
        imageBytes = 2.4 * 1024 * 1024; % Default 2.4 MB raw fundus scan
    end
    if nargin < 2 || isempty(modelInferTimeSec)
        modelInferTimeSec = 0.38; % On-device MATLAB inference time (0.38s)
    end

    profiles = {
        struct('name', 'Rural PHC Link (512 kbps)', 'speedKbps', 512, 'packetLoss', 0.04, 'color', [0.95, 0.55, 0.10]), ...
        struct('name', '2G Rural Cellular (128 kbps)', 'speedKbps', 128, 'packetLoss', 0.12, 'color', [0.85, 0.20, 0.20]), ...
        struct('name', '4G District Hub (10 Mbps)', 'speedKbps', 10240, 'packetLoss', 0.005, 'color', [0.15, 0.65, 0.30]), ...
        struct('name', 'On-Device Edge AI (Local MATLAB)', 'speedKbps', Inf, 'packetLoss', 0.0, 'color', [0.10, 0.40, 0.85])
    };

    simResults = struct();
    simResults.imageSizeMB = imageBytes / (1024 * 1024);
    simResults.edgeInferenceSec = modelInferTimeSec;
    simResults.profiles = repmat(struct('name', '', 'transferSec', 0, 'totalTurnaroundSec', 0, ...
                                       'effectiveKbps', 0, 'color', [0 0 0], 'savingsPercent', 0), 1, 4);

    for i = 1:4
        p = profiles{i};
        simResults.profiles(i).name = p.name;
        simResults.profiles(i).color = p.color;

        if isinf(p.speedKbps)
            % Edge AI: No network transmission
            tTx = 0.0;
            tTotal = modelInferTimeSec;
            effSpeed = Inf;
        else
            % Raw transmit time (in seconds)
            baseTx = (imageBytes * 8) / (p.speedKbps * 1000);
            % Overhead: TCP slow-start + retransmissions from packet loss
            tTx = baseTx * (1.0 + p.packetLoss * 1.5) + 0.35; % 350ms handshake latency
            % Cloud inference + return slip (50 KB)
            tCloudInfer = 0.85; % Cloud server execution
            tReturn = (50 * 1024 * 8) / (p.speedKbps * 1000) + 0.10;
            tTotal = tTx + tCloudInfer + tReturn;
            effSpeed = (imageBytes * 8) / (tTx * 1000);
        end

        simResults.profiles(i).transferSec = tTx;
        simResults.profiles(i).totalTurnaroundSec = tTotal;
        simResults.profiles(i).effectiveKbps = effSpeed;
    end

    % Savings of Edge-AI compared to rural 512 kbps link
    ruralTotal = simResults.profiles(1).totalTurnaroundSec;
    edgeTotal = simResults.profiles(4).totalTurnaroundSec;
    simResults.timeSavedSec = ruralTotal - edgeTotal;
    simResults.speedupRatio = ruralTotal / edgeTotal;
end
