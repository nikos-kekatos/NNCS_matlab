
%% INITIALIZATION
addpath(genpath('../../'))
clear;clc;close all;
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))
InitBreach;

%% MODELING (plant + control)

run('lane_change_modeling.m')

%% Evaluate STL nominal control

no_attempts=2000; % 1 traces, 1 sec. Tested 2000 traces.

% run('evaluate_nominal_stl.m')

%% DATA GENERATION (not traces but 1-step computations)

% Output u: Steering angle computed by MPC controller

% CHOOSE Input methods
% 1: Pre-generated Data (mathworks),
% 2: generation with random inputs (Mathworks)
% 3: corner cases as an input (Mathworks script),
% 4: coverage (our code -- Inzemam)

input_choice=4;

switch input_choice
    case 1
        load('InputDataFileImLKA.mat'); % The data in InputDataFileImLKA.mat was created by computing the MPC control action
        % for randomly generated states, previous control actions, and measured disturbances.
        data=Data;clear Data;
    case 2
        no_points=1e5;
        data=random_points_generation(no_points);
    case 3
        data=corner_case_generation;
    case 4
        % ref_min=[-2;-1.04;-1;-0.8;-1.04;-0.01*Vx];
        % ref_max=[2;1.04;1;0.8;1.04;0.01*Vx];
        delta_resolution=[0.5;0.52;0.25;0.4;0.52;0.15/2];

        %         delta_resolution=[0.25;0.72;0.25;0.2;0.26;0.15];
        if exist('delta_resolution','var')
            data=coverage_generation(delta_resolution);
        else
            data=coverage_generation();
        end
end

%% DATA SPLITTING
% divide into training, testing data

run('data_splitting.m')

%% GENERATE NEURAL NETWORK

% this code uses the "new" training tool from mathworks.
run('create_neural_network.m')

%% CLOSED-LOOP ANALYSIS (single trace with random initial inputs)
%% Compare Trained Network with MPC Controller

run('closed_loop_analysis.m')

%% FALSIFICATION - RETRAINING LOOP
%% Falsification with Breach

clear Data_all no_viol no_viol_mpc outcome_dnn viol_dnn viol_mpc cex_values
% Note that we randomly sample the input space, generate multiple traces
% (falsif.no_iterations=100;) and evaluate a property with Breach.

% Traces or Points (for retraining)
choice_retrain=1; % 1 for traces, 2 for points
choice_plot_cex=0;


% Maximum number of falsification-retraining loops
falsif.iterations_max=5;
falsif.no_iterations=300;

stop=0;
i_f=1;
% net_all{1}=net;
data_original=data(:,[1:6,9]);
Data_all{1,1}=data_original;
no_viol=cell(1,falsif.iterations_max);

while i_f<=falsif.iterations_max && ~stop
    disp(' ')
    disp('===========================')
    fprintf('\nThis is iteration %i of the falsification-retraining loop.\n\n',i_f)
    disp('===========================')
    no_viol{i_f}=0;data_cex_y=[]; data_cex_u=[];
    no_viol_mpc{i_f}=0;cex_values=cell(falsif.iterations_max,falsif.no_iterations);
    for i=1:falsif.no_iterations
        fprintf("\n\n-----Running iteration %i out of %i.----- \n", i, falsif.no_iterations);
        
        %% Falsification with random points
        x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
%         x0 = [12*(rand-0.5),8.08*(rand-0.5),8*(rand-0.5),1.6*(rand-0.5)]';

        u0 = 2.08*(rand-0.5); % Steering angle: range (-60,60) deg
        rho = 0.02*(rand-0.5); % Curvature: range (-0.01,0.01), minimum road radius 100m.
        
        run('simulation_traces_dnn_mpc.m')
        
        %% STL evaluation
        
        v_dnn=xHistoryDNN(:,1);v_mpc=xHistoryMPC(:,1);
        x_dnn=xHistoryDNN(:,3);x_mpc=xHistoryMPC(:,3);
        r_dnn = BreachRequirement('alw_[2.3,3](x_dnn[t]>-0.55 and x_dnn[t]<0.55 and v_dnn[t]>-0.65 and v_dnn[t]<0.65)');
        r_mpc = BreachRequirement('alw_[2.3,3](x_mpc[t]>-0.55 and x_mpc[t]<0.55 and v_mpc[t]>-0.65 and v_mpc[t]<0.65)');
        run('stl_evaluation.m')

        if outcome_dnn{i_f,i}<=0            
            if choice_retrain==1 % ENTIRE TRACE
                %error("Need to complete this code")
                data_cex_y=[data_cex_y;[xHistoryMPC(1:end-1,:),[u0;uHistoryMPC(1:end-1)],Vx*rho*ones(length(uHistoryMPC),1)]];
                data_cex_u=[data_cex_u; uHistoryMPC];
            elseif choice_retrain==2 % SINGLE POINT
                data_cex_y=[data_cex_y;[xHistoryMPC(1,:),uHistoryMPC(1,:),Vx*rho]];
                data_cex_u=[data_cex_u; uHistoryMPC(2,:)];
            elseif choice_retrain==3 % ENIKO diagnostics
            end
        end
    end
    fprintf('==========\n\nIn iteration %i, there are %i CEX. The nominal controller has %i CEX.\n\n',i_f,no_viol{i_f},no_viol_mpc{i_f});
    if no_viol{i_f}==0
        stop=1;
        disp('There is no CEX. The loop terminated.')
        break
    else
        run('retraining_code.m')
        run('rechecking_cex.m')
    end
    i_f=i_f+1;
end