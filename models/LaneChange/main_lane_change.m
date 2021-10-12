%%%%%%%%%%
%% Adding to paths
try
    addpath(genpath("../../"))
catch
    addpath(('../../'))
end
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))

%% Initialization
clear;clc;
close all;
InitBreach;
%% Plant Model
[sys,Vx] = createModelForMPCImLKA;

%% Controller
% Create and design the MPC controller object mpcobj. Also, create an
% mpcstate object for setting the initial controller state.

[mpcobj,initialState] = createMPCobjImLKA(sys);
mpcobj.p = 20;
mpcobj.c = 20;
%% Setup

% Plant
% 4 states
% 2 inputs (1 disturbance)
% 4 outputs

% Sampling time:      0.1 (seconds)
% Prediction Horizon: 20
% Control Horizon:    20
% -1.04 <= MV1 <= 1.04

% States [vy,r,e1,e2]

% vy range : (-2,2) m/s
% r range  : (-60,60) deg/s
% e1 range : (-1,1) m
% e2 range : (-45,45) deg

% Steering angle: range (-60,60) deg
% u0 = 2.08*(rand-0.5);

% Curvature: range (-0.01,0.01), minimum road radius 100m.
% rho
%
% measured disturbance: [road yaw rate]
% longitudinal velocity * curvature (ρ))
% vx=15 (???)

%%% input coverage: initial conditions (x4), u0, disturbance

%% Input Coverage

%clear options
% Time horizon of simulation in Simulink
options.T_train=3;
%options.SLX_model=SLX_model;

% Choose reference type: (1) for constant, (2) for time varying and (3) for
% coverage and (4) for Breach

options.reference_type=3;

options.specs_file='e8_specs_lookup_table.stl';

options.coverage.points='r'; % default random

% Coverage- time varying refereces
options.testing.train_data=0; %0 for testing centers, 1 for testing training data

options.coverage.ref_min=[-2;-1.04;-1;-0.8;-1.04;-0.01*Vx]; % o
options.coverage.ref_max=[2;1.04;1;0.8;1.04;0.01*Vx];
% options.coverage.ref_min=[-10;0];
% options.coverage.ref_max=[3;4];
options.coverage.dim=numel(options.coverage.ref_min);

options.coverage.delta_resolution=[1;1.04;0.5;0.8;1.04;0.15]; %supports multi-resolution boxes
if numel(options.coverage.delta_resolution)~=numel(options.coverage.ref_min)
    options.coverage.delta_resolution=options.coverage.delta_resolution*ones(numel(options.coverage.ref_min),1);
end
options.coverage.no_cells_per_dim=(options.coverage.ref_max-options.coverage.ref_min)./options.coverage.delta_resolution;
if floor(options.coverage.no_cells_per_dim)==options.coverage.no_cells_per_dim
    disp('The number of boxes is finite.')
    fprintf('The original resolution was:%s \n',mat2str(options.coverage.delta_resolution))
else
    fprintf('The original resolution was:%s \n',mat2str(options.coverage.delta_resolution))
    
    options.coverage.no_cells_per_dim=ceil(options.coverage.no_cells_per_dim);
    options.coverage.delta_resolution=(options.coverage.ref_max-options.coverage.ref_min)./options.coverage.no_cells_per_dim;
    fprintf('The new resolution is: %s\n',mat2str(options.coverage.delta_resolution));
    
    disp('The resolution was modified to create a finite number of boxes')
end

options.coverage.no_cells_total=prod(options.coverage.no_cells_per_dim); % 5*4*... cells

fprintf('The number of cells per dimension is %s.\n\n',mat2str(options.coverage.no_cells_per_dim));
fprintf('The number of cells in total equals %i.\n\n',options.coverage.no_cells_total);

options.coverage.cell_values=[];
for i=1:options.coverage.dim
    temp=(options.coverage.ref_min(i)+options.coverage.delta_resolution(i)/2):options.coverage.delta_resolution(i):(options.coverage.ref_max(i)-options.coverage.delta_resolution(i)/2);
    temp_coverage.cell_values{i}=temp;
end
temp_coverage.cells_centers=[];
temp_coverage.cells_centers=combvec(temp_coverage.cell_values{:});
for i=1:options.coverage.no_cells_total
    options.coverage.cells{i}.centers=temp_coverage.cells_centers(:,i)
    options.coverage.cells{i}.min=temp_coverage.cells_centers(:,i)-options.coverage.delta_resolution/2
    options.coverage.cells{i}.max=temp_coverage.cells_centers(:,i)+options.coverage.delta_resolution/2
    % rand(1) -> [0,1]
    % rand(1)*2 -> [0,2]
    % rand(1)*3+1 -> [1,4]
    % rand(1)*(max-min)+min -> [min,max]
    options.coverage.cells{i}.random_value=(options.coverage.cells{i}.max-options.coverage.cells{i}.min).*rand(options.coverage.dim,1)+options.coverage.cells{i}.min;
    
end
% options: choose coverage as value from 0 - 1
options.coverage.cell_occupancy=1;
options.coverage.no_traces_ref=options.coverage.cell_occupancy*options.coverage.no_cells_total;
options.coverage.no_traces_ref=floor(options.coverage.no_traces_ref);
fprintf('The selected cell occupancy is %.2f%%.\n\n',options.coverage.cell_occupancy*100);
fprintf('The number of different reference traces (coverage-based) is %i.\n\n',options.coverage.no_traces_ref);
flag=1;
if flag && numel(options.coverage.ref_min)==2
    options.coverage.m=2;
    plot_coverage_boxes(options,flag);
end

clearvars temp temp_coverage

%%

options.dt=mpcobj.Ts;
Tsteps=options.T_train/options.dt;
data_u=[];
data_y=[];%zeros(Tsteps,numel(options.coverage.dim));
for i=1:numel(options.coverage.cells)
    X_all= options.coverage.cells{i}.random_value;
    x0=X_all(1:4);
    u0=X_all(5);
    rho=X_all(6);
    initialState.Plant = x0;
    initialState.LastMove = u0;
    %     [uStar,info] = mpcmove(mpcobj,initialState,x0,zeros(1,4),Vx*rho);
    
    % vy,r,e1,e2,u,rho,cost,iterations,uStar
    %     Data(i,:) = [x0(:)',u0,rho,info.Cost,info.Iterations,uStar];
    
    xHistoryMPC = repmat(x0',Tsteps+1,1);
    uHistoryMPC = repmat(u0',Tsteps,1);
    deltaHistoryMPC=repmat(Vx*rho,Tsteps+1,1);
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
        % Update the disturbance
        deltaHistoryMPC(k+1,:)=0;
    end
    data_MPC = [xHistoryMPC(1:end-1,:),uHistoryMPC,deltaHistoryMPC(1:end-1,:)];
    data_y=[data_y; data_MPC];
    data_u=[data_u; uHistoryMPC];
end
data.REF=[];
data.U=data_u;
data.Y=data_y;
%% TRAINING old -- NNtraintool

data.REF=[];
options.preprocessing_bool=0;
options.trimming=0;
options.trimming_steady_state=0;
options.plotting_sim=1;
timer_train=tic;
training_options.retraining=0;
training_options.use_error_dyn=0;
training_options.use_previous_u=0;
training_options.use_previous_ref=0;
training_options.use_previous_y=0;
options.extra_y=0;
training_options.use_time=0;
training_options.neurons=[45 45 45];
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='custom_v1';
% training_options.loss='wmse';
training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-5;
training_options.max_fail=50; % Validation performance has increased more than max_fail times since the last time it decreased (when using validation).
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm'%'trainlm'; % trainscg % trainrp
%add option for saved mat files
training_options.iter_max_fail=1;
iter=1;reached=0;
training_options.replace_by_zeros=1;
while true && iter<=training_options.iter_max_fail
    fprintf('\n Iteration %i.\n',iter);
    [net,data,tr]=nn_training_mpc(data,training_options,options);
    net_all{iter}=net;
    tr_all{iter}=tr;
    if tr_all{iter}.best_perf<training_options.error*10 && tr_all{iter}.best_vperf<training_options.error*100
        reached=1;
        break;
    else
        if iter<training_options.iter_max_fail
            iter=iter+1;
        else
            break;
        end
    end
end
fprintf('\n The requested training error was %f.\n',training_options.error);
if reached
    fprintf('The obtained training error is %f reached after %i random initializations.\n',tr_all{iter}.best_perf,iter);
    fprintf('The validation error is %f.\n',tr_all{iter}.best_vperf);
    net=net_all{iter};
    tr=tr_all{iter};
else
    fprintf('\n We ran %i training attempts with random initializations.\n',iter);
    for ii=1:iter
        training_perf(ii)=tr_all{ii}.best_perf;
    end
    iter_best=find(training_perf==min(training_perf));
    fprintf('\n The smallest training error was %f.\n',tr_all{iter_best}.best_vperf);
    fprintf('\n The smallest validation error was %f.\n',tr_all{iter_best}.best_vperf);
    net=net_all{iter_best};
    tr=tr_all{iter_best};
end
timer.train=toc(timer_train)
if options.plotting_sim
    figure;plotperform(tr)
end
%{
% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);
%}

% Evaluating/Testing the network in open loop (against input/targets)

% options.plotting_sim=1;
% plot_NN_sim(data,options);

%% TRAINING new -- Deep Learning

data_new=[data_y,data_u];
% Divide the input data into training, validation, and testing data. First, determine number of validation data rows based on a given percentage.
totalRows = size(data_new,1);
validationSplitPercent = 0.1;
numValidationDataRows = floor(validationSplitPercent*totalRows);
% Determine the number of test data rows based on a given percentage.
testSplitPercent = 0.05;
numTestDataRows = floor(testSplitPercent*totalRows);
% Randomly extract validation and testing data from the input data set. To do so, first randomly extract enough rows for both data sets.
randomIdx = randperm(totalRows,numValidationDataRows + numTestDataRows);
randomData = data_new(randomIdx,:);
% Divide the random data into validation and testing data.
validationData = randomData(1:numValidationDataRows,:);
testData = randomData(numValidationDataRows + 1:end,:);
% Extract ther remaining rows as training data.
trainDataIdx = setdiff(1:totalRows,randomIdx);
trainData = data_new(trainDataIdx,:);
% Randomize the training data.
numTrainDataRows = size(trainData,1);
shuffleIdx = randperm(numTrainDataRows);
shuffledTrainData = trainData(shuffleIdx,:);
% Reshape the training and validation data into 4-D matrices to be used with trainNetwork.
numObservations = 6;
numActions = 1;

trainInput = reshape(shuffledTrainData(:,1:6)',[numObservations 1 1 numTrainDataRows]);
trainOutput = reshape(shuffledTrainData(:,7)',[numActions 1 1 numTrainDataRows]);

validationInput = reshape(validationData(:,1:6)',[numObservations 1 1 numValidationDataRows]);
validationOutput = reshape(validationData(:,7)',[numActions 1 1 numValidationDataRows]);
validationCellArray = {validationInput,validationOutput};
% Reshape the testing data to be used with predict.
testDataInput = reshape(testData(:,1:6)',[numObservations 1 1 numTestDataRows]);
testDataOutput = testData(:,7);

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

%% Compare Trained Network with MPC Controller
% To compare the performance of the MPC controller and the trained deep neural network, run closed-loop simulations using the vehicle plant model.
% Generate random initial conditions for the vehicle that are not part of the original input data set, with values selected from the following ranges:
% lateral velocity  : range (-2,2) m/s
% yaw angle rate  : range (-60,60) deg/s
% lateral deviation  : range (-1,1) m
% relative yaw angle  : range (-45,45) deg
% last steering angle (control variable)  : range (-60,60) deg
% measured disturbance (road yaw rate: longitudinal velocity * curvature ()) : range (-0.01,0.01), minimum road radius: 100 m.
clearvars  xHistoryMPC uHistoryMPC %initialState
%
x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
% Steering angle: range (-60,60) deg
u0 = 2.08*(rand-0.5);
% Curvature: range (-0.01,0.01), minimum road radius 100m.
rho = 0.02*(rand-0.5);

%rng(5e7)

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
plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
% The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.

%% Falsification with Breach

% Note that we only sample the input space and evaluate a property with
% Breach.

clearvars  xHistoryMPC uHistoryMPC %initialState
falsif.no_iterations=100;
no_viol=0;
for i=1:falsif.no_iterations
    fprintf("Running iteration %i out of %i", i, falsif.no_iterations);
    x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
    % Steering angle: range (-60,60) deg
    u0 = 2.08*(rand-0.5);
    % Curvature: range (-0.01,0.01), minimum road radius 100m.
    rho = 0.02*(rand-0.5);
    
    %rng(5e7)
    
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
    % plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
    % The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.
    
    x=xHistoryDNN(:,1);
    r = BreachRequirement('alw x[t]>0')
    t = 0:sys.Ts:options.T_train;
    outcome=r.Eval(t, x);
    if outcome<0
        no_viol=no_viol+1;
        fprintf("The trace %i is violated. There are %i number of violations\n\n",i,no_viol);
    end
end