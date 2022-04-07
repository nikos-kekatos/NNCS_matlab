%% Create Deep Neural Network
% The deep neural network architecture uses the following types of layers.
% imageInputLayer is input layer of the neural network.
% fullyConnectedLayer multiplies the input by a weight matrix and then adds a bias vector.
% reluLayer is the activation function of the neural network.
% tanhLayer constrains the value to the range to [-1,1].
% scalingLayer scales the value to the range to [-1.04,1.04], implies that the steering angle is constrained to be [-60,60] degrees.
% regressionLayer defines the loss function of the neural network.
% Create the deep neural network that will imitate the MPC controller after training.
numCol = 10;
numObservations = numCol-2;
numActions = 2;
hiddenLayerSize = 256;

imitateMPCNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','observation')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc4')
    reluLayer('Name','relu4')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc5')
    reluLayer('Name','relu5')
    fullyConnectedLayer(hiddenLayerSize,'Name','fc6')
    reluLayer('Name','relu6')    
    fullyConnectedLayer(numActions,'Name','fcLast')
    tanhLayer('Name','tanhLast')
    scalingLayer('Name','ActorScaling','Scale',umax)
    regressionLayer('Name','routput')];
% Plot the network.
plot(layerGraph(imitateMPCNetwork))

% intialize validation cell array
% validationCellArray = {0,0};

options = trainingOptions('adam', ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'Shuffle', 'every-epoch', ...
    'MiniBatchSize', 512, ...
    'ValidationData', validationCellArray, ...
    'InitialLearnRate', 1e-3, ...
    'ExecutionEnvironment', 'cpu', ...
    'GradientThreshold', 10, ...
    'MaxEpochs', 40 ...
    );

% validationOutput = permute(validationOutput, [2,3,1,4]);
% Train Network
imitateMPCNetObj = trainNetwork(trainInput,permute(trainOutput,[2,3,1,4]),imitateMPCNetwork,options);
% imitateMPCNetObj = trainNetwork(trainInput,trainOutput,imitateMPCNetwork,options);
% Test Network
predictedTestDataOutput = predict(imitateMPCNetObj,testDataInput);

% RMSE calculation
testRMSE = sqrt(mean((testDataOutput - predictedTestDataOutput).^2));
fprintf('Test Data RMSE Behavior Cloning = %d\n', testRMSE);