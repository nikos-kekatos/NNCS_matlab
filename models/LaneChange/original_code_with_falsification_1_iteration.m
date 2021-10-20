% Imitate MPC Controller for Lane Keep Assist
% This example shows how to train, validate, and test a deep neural network that imitates the behavior of a model predictive controller for an automotive lane keeping assist system. It then compares the behavior of the deep neural network with that of the original controller.
% Model predictive control (MPC) solves a constrained quadratic-programming (QP) optimization problem in real time based on the current state of the plant. Since MPC solves its optimization problem in an open-loop fashion, there is the potential to replace the controller with a trained deep neural network. Doing so is an appealing option, since evaluating a deep neural network can be more computationally efficient than solving a QP problem in real-time.
% If the training of the network sufficiently traverses the state-space for the application, you can create a reasonable approximation of the controller behavior. You can then deploy the network for your control application. You can also use the network as a warm starting point for training the actor network of a reinforcement learning agent. For an example, see Train DDPG Agent with Pretrained Actor Network.
% 

%% Initialization
clear
clc
close all
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/')) 
InitBreach;
%% Design MPC Controller
% Design an MPC controller for lane keeping assist. To do so, first create a dynamic model for the vehicle.
global sys Vx mpcobj initialState

[sys,Vx] = createModelForMPCImLKA;
% Create and design the MPC controller object mpcobj. Also, create an mpcstate object for setting the initial controller state. For details on the controller design, type edit createMPCobjImLKA.
[mpcobj,initialState] = createMPCobjImLKA(sys);
% For more information on designing model predictive controllers for lane keeping assist applications, see Lane Keeping Assist System Using Model Predictive Control and Lane Keeping Assist with Lane Detection.

%% Prepare Input Data

% Load the input data from InputDataFileImLKA.mat. 
% Steering angle computed by MPC controller: 
% The data in InputDataFileImLKA.mat was created by computing the MPC control action 
% for randomly generated states, previous control actions, and measured disturbances. 
% To generate your own training data, use the collectDataImLKA function.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------------------------ %
% CHOOSE Input methods
% 1: Pre-generated Data (mathworks), 
% 2: generation with random inputs (Mathworks) 
% 3: corner cases as an input (Mathworks script),
% 4: coverage (our code -- Inzemam)

input_choice=1;
no_points=1e5;
% ref_min=[-2;-1.04;-1;-0.8;-1.04;-0.01*Vx]; 
% ref_max=[2;1.04;1;0.8;1.04;0.01*Vx];
 delta_resolution=[0.5;1.04;0.25;0.4;0.52;0.15]; 

switch input_choice
    case 1 
        load('InputDataFileImLKA.mat');
        data=Data;
    case 2
        data=random_points_generation(no_points);
    case 3
        data=corner_case_generation;
    case 4
        if exist('delta_resolution','var')
            data=coverage_generation(delta_resolution);
        else 
            data=coverage_generation();
        end
end


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
numObservations = 6; 
numActions = 1;

trainInput = reshape(shuffledTrainData(:,1:6)',[numObservations 1 1 numTrainDataRows]);
trainOutput = reshape(shuffledTrainData(:,9)',[numActions 1 1 numTrainDataRows]);

validationInput = reshape(validationData(:,1:6)',[numObservations 1 1 numValidationDataRows]);
validationOutput = reshape(validationData(:,9)',[numActions 1 1 numValidationDataRows]);
validationCellArray = {validationInput,validationOutput};
% Reshape the testing data to be used with predict.
testDataInput = reshape(testData(:,1:6)',[numObservations 1 1 numTestDataRows]);
testDataOutput = testData(:,9);

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
    'MaxEpochs', 30, ...
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

%% Compare Trained Network with MPC Controller
% To compare the performance of the MPC controller and the trained deep neural network, run closed-loop simulations using the vehicle plant model.
% Generate random initial conditions for the vehicle that are not part of the original input data set, with values selected from the following ranges:
% lateral velocity  : range (-2,2) m/s
% yaw angle rate  : range (-60,60) deg/s
% lateral deviation  : range (-1,1) m
% relative yaw angle  : range (-45,45) deg
% last steering angle (control variable)  : range (-60,60) deg
% measured disturbance (road yaw rate: longitudinal velocity * curvature ()) : range (-0.01,0.01), minimum road radius: 100 m.
rng(5e7)
[x0,u0,rho] = generateRandomDataImLKA(data);
% Set the initial plant state and control action in the mpcstate object.
initialState.Plant = x0;
initialState.LastMove = u0;
% Extract the sample time from the MPC controller. Also, set the number of simulation steps.
Ts = mpcobj.Ts;
Tsteps = 30;     
% Obtain the A and B state-space matrices for the vehicle model.
A = sys.A;
B = sys.B;
% Initialize the state and input trajectories for the MPC controller simulation.
xHistoryMPC = repmat(x0',Tsteps+1,1);
uHistoryMPC = repmat(u0',Tsteps,1);
% Run a closed-loop simulation of the MPC controller and the plant using the mpcmove function.
for k = 1:Tsteps
    % Obtain plant output measurements, which correspond to the plant outputs.
    xk = xHistoryMPC(k,:)';
    % Compute the next cotnrol action using the MPC controller.
    uk = mpcmove(mpcobj,initialState,xk,zeros(1,4),Vx*rho);
    % Store the control action.
    uHistoryMPC(k,:) = uk;
    % Update the state using the control action.
    xHistoryMPC(k+1,:) = (A*xk + B*[uk;Vx*rho])';
end
% Initialize the state and input trajectories for the deep neural network simulation.     
xHistoryDNN = repmat(x0',Tsteps+1,1);
uHistoryDNN = repmat(u0',Tsteps,1);
lastMV = u0;
% Run a closed-loop simulation of the trained network and the plant. The neuralnetLKAmove function computes the deep neural network output using the predict function. 
for k = 1:Tsteps
    % Obtain plant output measurements, which correspond to the plant outputs.
    xk = xHistoryDNN(k,:)';
    % Predict the next move using the trained deep neural network.
    uk = neuralnetLKAmove(imitateMPCNetObj,xk,lastMV,rho);
    % Store the control action and update the last MV for the next step.
    uHistoryDNN(k,:) = uk;
    lastMV = uk;
    % Update the state using the control action.
    xHistoryDNN(k+1,:) = (A*xk + B*[uk;Vx*rho])';
end
% Plot the results, and compare the MPC controller and trained deep neural network (DNN) trajectories.
plotValidationResultsImLKA(Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
% The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.

%% Falsification with Breach

% Note that we only sample the input space and evaluate a property with
% Breach.

% clearvars  xHistoryMPC uHistoryMPC %initialState
falsif.no_iterations=100;
no_viol=0;
data_cex.Y=[];
data_cex.U=[];
for i=1:falsif.no_iterations
    fprintf("Running iteration %i out of %i. ", i, falsif.no_iterations);
    x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
    % Steering angle: range (-60,60) deg
    u0 = 2.08*(rand-0.5);
    % Curvature: range (-0.01,0.01), minimum road radius 100m.
    rho = 0.02*(rand-0.5);
        
    % Set the initial plant state and control action in the mpcstate object.
    initialState.Plant = x0;
    initialState.LastMove = u0;
    
    % Initialize the state and input trajectories for the MPC controller simulation.
    xHistoryMPC = repmat(x0',Tsteps+1,1);
    uHistoryMPC = repmat(u0',Tsteps,1);
    % Run a closed-loop simulation of the MPC controller and the plant using the mpcmove function.
    for k = 1:Tsteps
        % Obtain plant output measurements, which correspond to the plant outputs.
        xk = xHistoryMPC(k,:)';
        % Compute the next cotnrol action using the MPC controller.
        uk = mpcmove(mpcobj,initialState,xk,zeros(1,4),Vx*rho);
        % Store the control action.
        uHistoryMPC(k,:) = uk;
        % Update the state using the control action.
        xHistoryMPC(k+1,:) = (sys.A*xk + sys.B*[uk;Vx*rho])';
    end
    % Initialize the state and input trajectories for the deep neural network simulation.
    xHistoryDNN = repmat(x0',Tsteps+1,1);
    uHistoryDNN = repmat(u0',Tsteps,1);
    lastMV = u0;
    % Run a closed-loop simulation of the trained network and the plant. The neuralnetLKAmove function computes the deep neural network output using the predict function.
    for k = 1:Tsteps
        % Obtain plant output measurements, which correspond to the plant outputs.
        xk = xHistoryDNN(k,:)';
        % Predict the next move using the trained deep neural network.
        uk = neuralnetLKAmove(imitateMPCNetObj,xk,lastMV,rho);
        % Store the control action and update the last MV for the next step.
        uHistoryDNN(k,:) = uk;
        lastMV = uk;
        % Update the state using the control action.
        xHistoryDNN(k+1,:) = (sys.A*xk + sys.B*[uk;Vx*rho])';
    end
    % Plot the results, and compare the MPC controller and trained deep neural network (DNN) trajectories.
%     plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
    % The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.
    
    %% Code for falsification
    
    var1=xHistoryDNN(:,1);
    var2=xHistoryDNN(:,3);
    r = BreachRequirement('alw_[2,3](x[t]>-0.01 & x[t]<0.01 & v[t]>-0.1 &v[t]<0.1)')
    t = 0:sys.Ts:options.T_train;
    Var=[var1,var2]';
    
    outcome=r.Eval(t,Var);
    if outcome<0
        no_viol=no_viol+1;
        fprintf("The trace %i is violated. There are %i violations in total\n\n",i,no_viol);
        data_cex.Y=[data_cex.Y;[xHistoryMPC(1:end-1,:),[zeros(1,4);xHistoryMPC(2:end-1,:)],[zeros(2,4);xHistoryMPC(3:end-1,:)],uHistoryMPC]];
        data_cex.U=[data_cex.U; uHistoryMPC];
    end
end
