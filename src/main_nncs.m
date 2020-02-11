%===================================================
% This program receives a Simulink model (containing a plant and a
% controller) and outputs a feedforward neural network.
%===================================================

% Syntax:
%    >> run('main.m') or main or run(main)
%
% Inputs:
%    i) Simulink model with nominal controller and plant, and
%   ii) Training parameters and options
%
% Outputs:
%    i) Neural Network controller (saved as 'net' object),
%   ii) Simulink model with NN controller
%  iii) Simulation results and numerical values
%
% Example:
%
%
% Author:       Nikos Kekatos
% Written:      9-February-2020
% Last update:  ---
% Last revision:---


%%------------- BEGIN CODE --------------

%% 0. Add files to MATLAB path
try
    run('../startup_nncs.m')
    run('/startup_nncs.m')
end

%% 1. Initialization
clear;close all;clc;

%% 2. Iput: specify Simulink model
% The models are saved in ./models/

% SLX_model='models/robotarm/robotarm_PID';
SLX_model='robotarm_PID';
load_system(SLX_model)
% Uncomment next line if you want to open the model
% open(SLX_model)

%% 3. Input: specify configuration parameters
% run('../models/robotarm/configuration_1.m')
run('configuration_1.m')
%% 4a. Run simulations -- Generate training data

[data,options]=run_simulations_nncs(SLX_model,options);

%% 4b. Load previous saved traces
if options.load==1
    % specify dataset from outputs/ folder
    dataset='array_sim_constant_ref_300_traces_30x10_time_60_11-02-2020_08:26.mat';
    [data,options]= load_data(dataset,options);
end
%% 5. Data Preprocessing
display_ranges(data);
options.preprocessing_bool=1;
options.preprocessing_eps=0.001;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end
%% 6. Train NN Controller
%the assignments could go a function/file

training_options.use_error_dyn=0;
training_options.use_previous_u=1;      % default=2
training_options.use_previous_ref=1;    % default=3
training_options.use_previous_y=1;      % default=3
training_options.neurons=[8 20];
training_options.input_normalization=0;
%add option for saved mat files
[net,data]=nn_training(data,training_options,options);

%% 7. Evaluate NN
plot_NN_sim(data,options)

%% 8. Create Simulink block for NN
gensim(net)

%% 9. Analyse NNCS in Simulink
% Currently, this part is done manually. The user has to copy the block
% created in the previous step with 'gensim' and insert it in the SLX_model
% with the NN.
sim('mrefrobotarm_modified_previous_y_previous_u_previous_ref.slx')
figure;
plot(y.time,y.signals.values,'r--',y_nn.time,y_nn.signals.values,'b')
xlabel('time (s)')
ylabel('plant output')
legend('nominal','NN')
title('Simulating NNCS both with PID and NN')
%% 10. Evaluate Simulink NN
% compare_NN_vs_nominal(data,options);