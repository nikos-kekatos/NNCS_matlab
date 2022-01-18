function DAgger = DAggerModifiedTrainNetwork(nlmpcStruct, dataStruct, neuralNetStruct, tuningParamsStruct)
% Executes the Modified DAgger algorithm. This function output's the
% following structure
% 1. datasetPath - This consists of path where the dataset corresponding to
% each iteration is stored
% 2. policyObjs - This consists of policies that were trained in each
% iteration
% 3. finalData - This consists of the actual data collected till final
% iteration
% 4. finalPolicy - This consists of the information of the best policy
% among all the collected policies
% 5. inputObservationsL2Loss - L2 loss of 6 input states and 2 previous
% actions
% 6. goodPolicyObj - Total number of policies used to update in order to
% fetch new data for every 'policyUpdateCounter'

% After collecting the above information this script saves the final DAgger
% Struct into a .MAT file
% 
% Copyright 2019 The MathWorks, Inc.

% Create required parameters for DAgger
Options = neuralNetStruct.options;
existingData = dataStruct.data;
maxDAggerIterations = tuningParamsStruct.maxDAggerIterations;
policyUpdateCounter = tuningParamsStruct.policyUpdateCounter;
policyObjs(1:maxDAggerIterations) = neuralNetStruct.networkObj;

% create a directory to store MAT file in each iteration
if ~exist([pwd, '\DAgger_datasets_per_iteration'], 'dir')
mkdir([pwd, '\DAgger_datasets_per_iteration'])
end
datasetPath = [pwd, '\DAgger_datasets_per_iteration'];

% To track number of iteration DAgger runs
xHistoryDNN = [];
policyIndex = 0;
inputObservationsL2Loss = zeros(maxDAggerIterations,dataStruct.numObservations);
goodPolicyCounter = 0;
goodPolicyObj(1:policyUpdateCounter) = neuralNetStruct.networkObj;

for i = 1:maxDAggerIterations
    % Data Generation
    % 1. First Generate New Data
    % 2. Merge with the Existing Data
    if ~isempty(xHistoryDNN)
        runs = size(xHistoryDNN,1);
        newData = generateNewDataImFlyingRobot(nlmpcStruct, runs, existingData, xHistoryDNN, u0HistoryDNN);
        mergedData = [existingData; newData];
    else
        mergedData = existingData;
    end
    
    % Data Preparation and extracting Network Information
    [newTrainInput, newTrainOutput, Options] = prepareDataImDAggerFlyingRobot(mergedData, dataStruct, Options);
    
    % Update policy based on policyIndex
    if policyIndex
        goodPolicyCounter = goodPolicyCounter + 1;
        goodPolicyObj(goodPolicyCounter) = policyObjs(policyIndex);
        imitateMPCNetDAggerObj = policyObjs(policyIndex);
    else
        imitateMPCNetDAggerObj = policyObjs(i);
    end
    
    % train network
    imitateMPCNetDAggerObj_Updated = trainNetwork(newTrainInput, newTrainOutput, imitateMPCNetDAggerObj.Layers, Options);
    if i == maxDAggerIterations
        policyObjs(i) = imitateMPCNetDAggerObj_Updated;
    else
        policyObjs(i+1) = imitateMPCNetDAggerObj_Updated;
    end
    
    % find histInfoStruct and L1 Loss using latest trained network
    histInfoStruct = generateHistoryDataImFlyingRobot(imitateMPCNetDAggerObj_Updated, nlmpcStruct, existingData);
    xHistoryMPC = histInfoStruct.xHistoryMPC;
    uHistoryMPC = histInfoStruct.uHistoryMPC;
    xHistoryDNN = histInfoStruct.xHistoryDNN;
    uHistoryDNN = histInfoStruct.uHistoryDNN;
    u0HistoryDNN = histInfoStruct.u0HistoryDNN;
    inputObservationsL2Loss(i,:) = [sqrt(mean((xHistoryMPC - xHistoryDNN).^2)), sqrt(mean((uHistoryMPC - uHistoryDNN).^2))];
    
    % calculate update policy index
    if rem(i,policyUpdateCounter)
        policyIndex = 0;
    else
        startRow = i - policyUpdateCounter + 1;
        endRow = i;
        rmseSum = sum(inputObservationsL2Loss(startRow:endRow,:),2);
        rmseIndex = find(rmseSum == min(rmseSum));
        policyIndex = i - policyUpdateCounter + rmseIndex;
    end
    
    % creating .MAT file
    save([datasetPath, '\DAgger_Modified_Dataset_for_Iteration_', num2str(i), '.mat'],'mergedData')
    existingData = mergedData;
end

% Final DAgger info
DAgger.policyObjs = policyObjs;
DAgger.datasetPath = datasetPath;
DAgger.finalData = existingData;
DAgger.inputObservationsL2Loss = inputObservationsL2Loss;
DAgger.goodPolicyObj = goodPolicyObj;
DAgger.finalPolicy = policyObjs(end);

% Select best policy in DAgger as final policy
DAgger.finalPolicy = DAgger.policyObjs(min(sum(DAgger.inputObservationsL2Loss,2)) == sum(DAgger.inputObservationsL2Loss,2));

% Save DAgger Obj
save('DAggerModifiedImFlyingRobotDNNObj','DAgger')

    