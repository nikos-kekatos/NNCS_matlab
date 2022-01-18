function [dataStruct, nlmpcStruct, tuningParamsStruct, neuralNetStruct] = loadDAggerParameters(existingData, ...
    numCol, nlobj, umax, options, imitateMPCNetBehaviorCloningObj)
% Creates required structures for the DAgger and Behavior Cloning
% approaches.
% 
% Copyright 2019 The MathWorks, Inc.

% Create dataStruct which stores the following information:
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

dataStruct.runs = 10;
dataStruct.data = existingData;
dataStruct.validationSplitPercent = 0.1;
dataStruct.numObservations = numCol-2;
dataStruct.numActions = 2;
dataStruct.actionIndex = numCol-1:numCol;
dataStruct.stateIndex = 1:numCol-2;
dataStruct.testSplitPercent = 0.05;

% Create nlmpcStruct. This contains the information of nlmpc parameters
nlmpcStruct.nlobj = nlobj;
nlmpcStruct.umax = umax;
nlmpcStruct.bx = [4,4,3.2,2,2,1]';
nlmpcStruct.bu = [umax,umax]';
nlmpcStruct.Tf = 12;

% Create tuningParamsStruct. This contains the information the following
% 1. maxDAggerIterations, maximum number of iterations that DAgger runs
% 2. policyUpdateCounter, number of iterations for which the policies gets
% updated during iterations
tuningParamsStruct.maxDAggerIterations = 140;
tuningParamsStruct.policyUpdateCounter = 20;

% Save the training options, behavior cloning neural network and neural
% network object into a struct called neuralNetStruct
neuralNetStruct.options = options;
neuralNetStruct.network = imitateMPCNetBehaviorCloningObj.Layers;
neuralNetStruct.networkObj = imitateMPCNetBehaviorCloningObj;
