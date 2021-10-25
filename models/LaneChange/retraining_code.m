%% Note that Data is 9-dimensional while xHistory is 4-dim and the NN input
%% is 6-dim.

data_cex=[data_cex_y,data_cex_u];
Data_all{i_f,2}=data_cex;
data_retrain=[Data_all{i_f,1};data_cex];
Data_all{i_f+1,1}=data_retrain;
% Divide the input data into training, validation, and testing data. First, determine number of validation data rows based on a given percentage.
totalRows = size(data_retrain,1);
validationSplitPercent = 0.1;
numValidationDataRows = floor(validationSplitPercent*totalRows);
% Determine the number of test data rows based on a given percentage.
testSplitPercent = 0.05;
numTestDataRows = floor(testSplitPercent*totalRows);
% Randomly extract validation and testing data from the input data set. To do so, first randomly extract enough rows for both data sets.
randomIdx = randperm(totalRows,numValidationDataRows + numTestDataRows);
randomData = data_retrain(randomIdx,:);
% Divide the random data into validation and testing data.
validationData = randomData(1:numValidationDataRows,:);
testData = randomData(numValidationDataRows + 1:end,:);
% Extract ther remaining rows as training data.
trainDataIdx = setdiff(1:totalRows,randomIdx);
trainData = data_retrain(trainDataIdx,:);
% Randomize the training data.
numTrainDataRows = size(trainData,1);
shuffleIdx = randperm(numTrainDataRows);
shuffledTrainData = trainData(shuffleIdx,:);
% Reshape the training and validation data into 4-D matrices to be used with trainNetwork.
numObservations = 6;
numActions = 1;

trainInput = reshape(shuffledTrainData(:,1:size(data_retrain,2)-1)',[numObservations 1 1 numTrainDataRows]);
trainOutput = reshape(shuffledTrainData(:,size(data_retrain,2))',[numActions 1 1 numTrainDataRows]);

validationInput = reshape(validationData(:,1:1:size(data_retrain,2)-1)',[numObservations 1 1 numValidationDataRows]);
validationOutput = reshape(validationData(:,size(data_retrain,2))',[numActions 1 1 numValidationDataRows]);
validationCellArray = {validationInput,validationOutput};
% Reshape the testing data to be used with predict.
testDataInput = reshape(testData(:,1:1:size(data_retrain,2)-1)',[numObservations 1 1 numTestDataRows]);
testDataOutput = testData(:,size(data_retrain,2));

imitateMPCNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','InputLayer')
    fullyConnectedLayer(45,'Name','Fc1')
    reluLayer('Name','Relu1')
    fullyConnectedLayer(45,'Name','Fc2')
    reluLayer('Name','Relu2')
    fullyConnectedLayer(45,'Name','Fc3')
    reluLayer('Name','Relu3')
    fullyConnectedLayer(numActions,'Name','OutputLayer')
    tanhLayer('Name','Tanh1')
    scalingLayer('Name','Scale1','Scale',1.04)
    regressionLayer('Name','RegressionOutput')
    ];

plot(layerGraph(imitateMPCNetwork))

options_new = trainingOptions('adam', ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'Shuffle','every-epoch', ...
    'MaxEpochs', 30, ...
    'MiniBatchSize',512, ...
    'ValidationData',validationCellArray, ...
    'InitialLearnRate',1e-3, ...
    'GradientThresholdMethod','absolute-value', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',10, ...
    'Epsilon',1e-8);

% Training
imitateMPCNetObj = trainNetwork(trainInput,trainOutput,imitateMPCNetwork,options_new);

%Testing
predictedTestDataOutput = predict(imitateMPCNetObj,testDataInput);

% Calculate the root mean-squared error between the network output and the testing data.
testRMSE = sqrt(mean((testDataOutput - predictedTestDataOutput).^2));
fprintf('Test Data RMSE = %d\n', testRMSE);
