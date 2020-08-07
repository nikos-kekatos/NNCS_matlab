
XTrain = cell(1,1);
XTrain{1}=[data.REF';data.Y']
YTrain = cell(1);
YTrain{1}=data.U';
%%
data1=chickenpox_dataset;
data1=[data1{:}]
XTrain=data1(1:end-1);YTrain=data1(2:end);
%%
[XTrain,YTrain] = japaneseVowelsTrainData;
%%
numFeatures = 2;
numResponses = 1;
numHiddenUnits = 200;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);

net = predictAndUpdateState(net,XTrain);
% [net,YPred] = predictAndUpdateState(net,YTrain(end));

%%
data1=chickenpox_dataset;
data1=[data1{:}]
XTrain=data1(1:end-1);YTrain=data1(2:end);
miniBatchSize  = 128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);