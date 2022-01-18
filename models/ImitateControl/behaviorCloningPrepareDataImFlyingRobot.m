function behaviorCloningTrainInfo = behaviorCloningPrepareDataImFlyingRobot(dataStruct)
% Prepare training data for flying robot with behavior cloning
% 
% Copyright 2019 The MathWorks, Inc.

% Extract the dataStruct variables
numObservations = dataStruct.numObservations;
numActions = dataStruct.numActions;
actionIndex = dataStruct.actionIndex;
stateIndex = dataStruct.stateIndex;
data = dataStruct.data;

% calculate number of validation rows
totalRows = size(data,1);
validationSplitPercent = dataStruct.validationSplitPercent;
numValidationDataRows = floor(validationSplitPercent*totalRows);

% Test split
testSplitPercent = dataStruct.testSplitPercent;
numTestDataRows = floor(testSplitPercent*totalRows);

% create validation and training data
randomIdx = randperm(totalRows,numValidationDataRows + numTestDataRows);
randomData = data(randomIdx,:);    
trainDataIdx = setdiff(1:totalRows,randomIdx);

newValidationData = randomData(1:numValidationDataRows,:);
newTestData = randomData(numValidationDataRows + 1:end,:);
newTrainData = data(trainDataIdx,:);

numTrainDataRows = size(newTrainData,1);

% prepare new dataset for training
behaviorCloningTrainInfo.newTrainInput = reshape(newTrainData(:,stateIndex)',[numObservations 1 1 numTrainDataRows]);
behaviorCloningTrainInfo.newTrainOutput = reshape(newTrainData(:,actionIndex)',[1 1 numActions numTrainDataRows]);

newValidationInput = reshape(newValidationData(:,stateIndex)',[numObservations 1 1 numValidationDataRows]);
newValidationOutput = reshape(newValidationData(:,actionIndex)',[1 1 numActions numValidationDataRows]);
behaviorCloningTrainInfo.newValidationCellArray = {newValidationInput, newValidationOutput};

behaviorCloningTrainInfo.newTestDataInput = reshape(newTestData(:,1:numObservations)',[numObservations 1 1 numTestDataRows]);
behaviorCloningTrainInfo.newTestDataOutput = newTestData(:,actionIndex);

end