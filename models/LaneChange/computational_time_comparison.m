%% INITIALIZATION
addpath(genpath('../../'))
clear;clc;close all;
% addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))
% InitBreach;

%% MODELING (plant + control)

run('lane_change_modeling.m')
% imitateMPCNetObj
load('nn_elimin.mat')
%% Simulation time Comparison

no_traces=100;
timer_mpc=zeros(1,no_traces);
timer_dnn=zeros(1,no_traces);
for i=1:no_traces
    %% Random points
    x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
    u0 = 2.08*(rand-0.5); % Steering angle: range (-60,60) deg
    rho = 0.02*(rand-0.5); % Curvature: range (-0.01,0.01), minimum road radius 100m.
   
    %% Simulation MPC
    
    % Set the initial plant state and control action in the mpcstate object.
    initialState.Plant = x0;
    initialState.LastMove = u0;
    
    timer_temp=tic;
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
    timer_mpc(i)=toc(timer_temp);
    
    timer_temp2=tic;

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
    timer_dnn(i)=toc(timer_temp2);

    % Plot the results, and compare the MPC controller and trained deep neural network (DNN) trajectories.
    %     plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
    % The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.
    
end

fprintf('For one trace of the MPC, the minimum computational time is %.3f, the maximum time is %.3f, and the average is %.3f',min(timer_mpc),max(timer_mpc),mean(timer_mpc));
fprintf('For one trace of the DNN, the minimum computational time is %.3f, the maximum time is %.3f, and the average is %.3f',min(timer_mpc),max(timer_dnn),mean(timer_dnn));
