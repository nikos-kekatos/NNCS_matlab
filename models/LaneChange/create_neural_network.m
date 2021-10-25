%% Create Deep Neural Network
% The deep neural network architecture uses the following types of layers.
% imageInputLayer is input layer of the neural network.
% fullyConnectedLayer multiplies the input by a weight matrix and then adds a bias vector.
% reluLayer is the activation function of the neural network.
% tanhLayer constrains the value to the range to [-1,1].
% scalingLayer scales the value to the range to [-1.04,1.04], implies that the steering angle is constrained to be [-60,60] degrees.
% regressionLayer defines the loss function of the neural network.
% Create the deep neural network that will imitate the MPC controller after training.
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
% Plot the network.
plot(layerGraph(imitateMPCNetwork))

% Train Deep Neural Network
% Specify training options.
options_adam = trainingOptions('adam', ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'Shuffle','every-epoch', ...
    'MaxEpochs', 30, ... %original 30
    'MiniBatchSize',512, ...
    'ValidationData',validationCellArray, ...
    'InitialLearnRate',1e-3, ...
    'GradientThresholdMethod','absolute-value', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',10, ...
    'Epsilon',1e-8);
% Train the deep neural network. To view detailed training information in the Command Window, you can set the 'Verbose' training option to true.
imitateMPCNetObj = trainNetwork(trainInput,trainOutput,imitateMPCNetwork,options_adam);
% Training of the deep neural network stops when it reaches the final iteration.
% The training and validation loss are nearly the same for each mini-batch indicating the trained network is not overfit.
%
% Test Trained Network
% Check that the trained deep neural network returns steering angles similar to the MPC controller control actions given the test input data. Compute the network output using the predict function.
predictedTestDataOutput = predict(imitateMPCNetObj,testDataInput);
% Calculate the root mean-squared error between the network output and the testing data.
testRMSE = sqrt(mean((testDataOutput - predictedTestDataOutput).^2));
fprintf('Test Data RMSE = %d\n', testRMSE);
% The small RMSE value indicates that the network outputs closely reproduce the MPC controller outputs.
