% TRAIN_DR_MODEL_COMPLETE Full Multi-Dataset Deep Learning Training & Evaluation
% Datasets: Unified APTOS 2019 (3,662) + IDRiD Train (413) = 4,075 Images
% Unseen Benchmark Evaluation: IDRiD Test Set (103 Patients)
%
% MathWorks Smart India Hackathon (SIH Problem Statement 26038)
% Benchmark Mandate: Sensitivity > 90%, Specificity > 85% for Referable DR

clear; clc; close all;
fprintf('====================================================================\n');
fprintf('  SIH 26038: Full Multi-Dataset Training & Unseen Clinical Benchmark\n');
fprintf('  Training Cohort: 4,075 Images (APTOS 2019 + IDRiD Train)\n');
fprintf('  Unseen Test Set: 103 Patients (IDRiD Testing Benchmark)\n');
fprintf('====================================================================\n\n');

trainDir = fullfile(pwd, 'data', 'training_dataset');
testDir  = fullfile(pwd, 'data', 'testing_dataset');

% 1. Load Training Set
fprintf('[1/6] Indexing Unified Training Dataset...\n');
imdsTrain = imageDatastore(trainDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
tblTrain = countEachLabel(imdsTrain);
disp(tblTrain);

% Compute Clinical Inverse-Frequency Class Weights
totalTrain = sum(tblTrain.Count);
numClasses = height(tblTrain);
classWeights = totalTrain ./ (numClasses * double(tblTrain.Count));
classWeights = classWeights / mean(classWeights);

fprintf('  > Clinical Class Balancing Weights (Penalizing Minority Misclassification):\n');
for i = 1:numClasses
    fprintf('      Grade %s: Count = %4d | Weight = %.2fx\n', ...
        string(tblTrain.Label(i)), tblTrain.Count(i), classWeights(i));
end

% 2. Load Testing Set (103 Unseen Real Patients)
fprintf('\n[2/6] Indexing Unseen Testing Dataset (103 Patients)...\n');
imdsTest = imageDatastore(testDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
tblTest = countEachLabel(imdsTest);
disp(tblTest);

% 3. Build Deep Retinal CNN Architecture (with activation_49_relu for Grad-CAM)
fprintf('\n[3/6] Building 5-Stage Deep Retinal Neural Network Architecture...\n');
inputSize = [224, 224, 3];

layers = [
    imageInputLayer(inputSize, 'Name', 'input', 'Normalization', 'zscore')
    
    % Stage 1: Basic Edge & Retinal Texture
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
    
    % Stage 2: Retinal Vasculature Features
    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
    
    % Stage 3: Microaneurysm & Hard Exudate Features
    convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bn3')
    reluLayer('Name', 'relu3')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')
    
    % Stage 4: Blot Hemorrhages & Macular Exudate Clustering
    convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv4')
    batchNormalizationLayer('Name', 'bn4')
    reluLayer('Name', 'relu4')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool4')
    
    % Stage 5: Neovascularization & Advanced Proliferative Structures
    convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv5')
    batchNormalizationLayer('Name', 'bn5')
    reluLayer('Name', 'activation_49_relu')  % Exact layer hooked by Grad-CAM explainability
    
    % Spatial Feature Pooling & Regularized Classification Head
    globalAveragePooling2dLayer('Name', 'gap')
    fullyConnectedLayer(128, 'Name', 'fc1')
    batchNormalizationLayer('Name', 'bn_fc')
    reluLayer('Name', 'relu_fc')
    dropoutLayer(0.35, 'Name', 'drop1')
    
    fullyConnectedLayer(numClasses, 'Name', 'new_fc_dr')
    softmaxLayer('Name', 'new_softmax')
    classificationLayer('Name', 'new_classoutput', 'Classes', tblTrain.Label, 'ClassWeights', classWeights)
];
lgraph = layerGraph(layers);

% 4. Data Augmentation
augmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandYReflection', true, ...
    'RandRotation', [-180, 180], ...
    'RandScale', [0.85, 1.15]);

augTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'DataAugmentation', augmenter, 'ColorPreprocessing', 'gray2rgb');

augTest = augmentedImageDatastore(inputSize(1:2), imdsTest, ...
    'ColorPreprocessing', 'gray2rgb');

% 5. Training Options
fprintf('\n[4/6] Training Network across 4,075 Images...\n');
try
    gpuInfo = gpuDevice();
    execEnv = 'gpu';
catch
    execEnv = 'cpu';
end

miniBatchSize = 64;
maxEpochs = 8;
valFreq = floor(totalTrain / miniBatchSize);

options = trainingOptions('adam', ...
    'ExecutionEnvironment', execEnv, ...
    'InitialLearnRate', 1e-3, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 3, ...
    'LearnRateDropFactor', 0.3, ...
    'MiniBatchSize', miniBatchSize, ...
    'MaxEpochs', maxEpochs, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augTest, ...
    'ValidationFrequency', valFreq, ...
    'Verbose', true, ...
    'L2Regularization', 1e-4);

tStart = tic;
[trainedNet, trainInfo] = trainNetwork(augTrain, lgraph, options);
tTrain = toc(tStart);
fprintf('  > Training completed in %.1f minutes!\n', tTrain / 60);

% 6. Evaluate on Unseen 103 Test Cases
fprintf('\n[5/6] Evaluating on 103 Real Unseen Test Patients...\n');
[YPred, scores] = classify(trainedNet, augTest);
YTrue = imdsTest.Labels;

% Calculate Multi-Class Accuracy
accMulti = mean(YPred == YTrue);

% Calculate Referable DR (Grade >= 2) metrics
trueReferable  = (double(YTrue) - 1) >= 2;
predReferable  = (double(YPred) - 1) >= 2;

TP = sum(trueReferable & predReferable);
FP = sum(~trueReferable & predReferable);
TN = sum(~trueReferable & ~predReferable);
FN = sum(trueReferable & ~predReferable);

sensitivity = TP / max(1, (TP + FN));
specificity = TN / max(1, (TN + FP));
precision   = TP / max(1, (TP + FP));
f1Score     = 2 * (precision * sensitivity) / max(1e-6, (precision + sensitivity));

fprintf('\n====================================================================\n');
fprintf('              FINAL CLINICAL BENCHMARK RESULTS (TEST SET)\n');
fprintf('====================================================================\n');
fprintf('  Total Test Cases Evaluated : %d patients\n', numel(YTrue));
fprintf('  Multi-Class Top-1 Accuracy : %.2f%%\n', accMulti * 100);
fprintf('  Referable DR Sensitivity   : %.1f%%  (SIH Mandate: >90%%)\n', sensitivity * 100);
fprintf('  Referable DR Specificity   : %.1f%%  (SIH Mandate: >85%%)\n', specificity * 100);
fprintf('  Referable DR F1-Score      : %.1f%%\n', f1Score * 100);
fprintf('  True Positives (TP)        : %d patients caught\n', TP);
fprintf('  False Negatives (FN)       : %d missed\n', FN);
fprintf('====================================================================\n\n');

% 7. Save Model and Artifacts
outputModelPath = fullfile('src', 'module3_classification', 'trained_dr_resnet50.mat');
save(outputModelPath, 'trainedNet', 'trainInfo', 'inputSize', 'sensitivity', 'specificity');
fprintf('  > Model weights saved to: %s\n', outputModelPath);

% Generate Confusion Matrix Figure and save as PNG
try
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 650 550]);
    confusionchart(YTrue, YPred, ...
        'Title', sprintf('IDRiD 5-Class Retinopathy Matrix (Acc: %.1f%%, Sens: %.1f%%, Spec: %.1f%%)', ...
        accMulti*100, sensitivity*100, specificity*100));
    saveas(fig, 'test_confusion_matrix.png');
    close(fig);
    fprintf('  > Saved test_confusion_matrix.png for presentation slides!\n');
catch
end

fprintf('\n=== TRAINING AND BENCHMARKING FINISHED SUCCESSFULLY ===\n');
