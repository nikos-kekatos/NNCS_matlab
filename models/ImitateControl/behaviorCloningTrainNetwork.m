function behaviorCloningNNObj = behaviorCloningTrainNetwork(neuralNetwork, Options)
% Creates a neural network object for the given network structure and options
% using the behavior cloning approach, which used as initial policy in
% DAgger.
%
% Copyright 2019 The MathWorks, Inc.

% Load training data for behavior cloning
fileName = 'behaviorCloningInputDataFileImFlyingRobot.mat';
behaviorCloningData = load(fileName);
rawData = behaviorCloningData.Data;

% Create DataStruct to prepare data for training
% Training Data: 
data = rawData;
% number of columns
numCol = size(data,2);

% Create newDataStruct which stores the following information
% 1. runs, number of runs to create input data. If runs = 20 then
% collectDataImFlyingRobot creates runs*Tf/Ts records
% 2. data, input data
% 3. validationSplitPercent, this has validation split percent information
% which later is used to create validation cell array during DAgger
% training
% 4. numObservations, number of input observations to the neural network
% 5. numActions, number of output actions of  the neural network
% 6. actionIndex, indices of output actions in the input data
% 7. stateIndex, indices of input states in the input data
% 8. testSplitPercent, the test split percent which later is used to create
% test data during finalizing the best policy of DAgger.

newDataStruct.runs = 10;
newDataStruct.data = data;
newDataStruct.validationSplitPercent = 0.1;
newDataStruct.numObservations = numCol-2;
newDataStruct.numActions = 2;
newDataStruct.actionIndex = numCol-1:numCol;
newDataStruct.stateIndex = 1:numCol-2;
newDataStruct.testSplitPercent = 0.05;

% data preparation and assign train, test and validation data
behaviorCloningTrainInfo = behaviorCloningPrepareDataImFlyingRobot(newDataStruct);

% Assign train, test and validation data
trainInput = behaviorCloningTrainInfo.newTrainInput;
trainOutput = behaviorCloningTrainInfo.newTrainOutput;

validationCellArray = behaviorCloningTrainInfo.newValidationCellArray;

testDataInput = behaviorCloningTrainInfo.newTestDataInput;
testDataOutput = behaviorCloningTrainInfo.newTestDataOutput;

% Neural Network
imitateMPCNetwork = neuralNetwork;

% Parameters for training options
% Options for training neural net
options = Options;
options.ValidationData = validationCellArray;

% Train Network
imitateMPCNetObj = trainNetwork(trainInput,trainOutput,imitateMPCNetwork,options);

% Test Network
predictedTestDataOutput = predict(imitateMPCNetObj,testDataInput);

% RMSE calculation
testRMSE = sqrt(mean((testDataOutput - predictedTestDataOutput).^2));
fprintf('Test Data RMSE Behavior Cloning = %d\n', testRMSE);

% Save neural network object
behaviorCloningNNObj.imitateMPCNetObj = imitateMPCNetObj;
% save('behaviorCloningMPCImDNNObject','behaviorCloningNNObj')