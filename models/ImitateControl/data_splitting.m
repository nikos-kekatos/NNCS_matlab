
% data = dataStruct.Data;
% Divide the input data into training, validation, and testing data. First, determine number of validation data rows based on a given percentage.
totalRows = size(data,1);
validationSplitPercent = 0.1;
numValidationDataRows = floor(validationSplitPercent*totalRows);
% Determine the number of test data rows based on a given percentage.
testSplitPercent = 0.05;
numTestDataRows = floor(testSplitPercent*totalRows);
% Randomly extract validation and testing data from the input data set. To do so, first randomly extract enough rows for both data sets.
randomIdx = randperm(totalRows,numValidationDataRows + numTestDataRows);
randomData = data(randomIdx,:);
% Divide the random data into validation and testing data.
validationData = randomData(1:numValidationDataRows,:);
testData = randomData(numValidationDataRows + 1:end,:);
% Extract the remaining rows as training data.
trainDataIdx = setdiff(1:totalRows,randomIdx);
trainData = data(trainDataIdx,:);
% Randomize the training data.
numTrainDataRows = size(trainData,1);
shuffleIdx = randperm(numTrainDataRows);
shuffledTrainData = trainData(shuffleIdx,:);
% Reshape the training and validation data into 4-D matrices to be used with trainNetwork.
numObservations = 8;
numActions = 2;

trainInput = reshape(shuffledTrainData(:,1:8)',[numObservations 1 1 numTrainDataRows]);
trainOutput = reshape(shuffledTrainData(:,9:10)',[numActions 1 1 numTrainDataRows]);

validationInput = reshape(validationData(:,1:8)',[numObservations 1 1 numValidationDataRows]);
validationOutput = reshape(validationData(:,9:10)',[numActions 1 1 numValidationDataRows]);
% validationCellArray = {validationInput,permute(validationOutput, [2,3,1,4])};
validationCellArray = {validationInput,validationOutput};

% Reshape the testing data to be used with predict.
testDataInput = reshape(testData(:,1:8)',[numObservations 1 1 numTestDataRows]);
testDataOutput = testData(:,9:10);
