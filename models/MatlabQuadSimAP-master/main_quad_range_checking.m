%===================================================
% This program receives a Quadcopter Simulink model (containing a plant and a
% controller) and checks if the operating ranges produce simulation errors).
% Uses Breach toolbox.
%===================================================

% Syntax:
%    >> run('main.m') or main or run(main)
%


%%------------- BEGIN CODE --------------

%% 0. Add files to MATLAB path

current_file = matlab.desktop.editor.getActiveFilename;
current_path=fileparts(current_file);

idcs   = strfind(current_path,filesep);
module_dir = current_path(1:idcs(end-1)-1); % 2 steps back
cd(current_path);
addpath(genpath(module_dir));
rmpath(genpath([module_dir filesep 'NIPS_submission']));

[~,user_name]=system('echo $USER');  % it produces a new line character
user_name=regexprep(user_name,'\n+',''); % deleted new lines
if strcmp(user_name,'kekatos')
    addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))
else
    disp('Add the absolute path to the Breach directory')
end
InitBreach

%% 1. Initialization
clear;close all;clc; bdclose all;
try
    delete(findall(0)); % close Simulink scopes
end
%% 2. Iput: specify Simulink model
% The models are saved in ./models/
disp('==============================')
disp('Model and configuration done')

model=5;
options.SLX_model='Quadrotor_rangeChecking';

load_system(options.SLX_model)
options.model=model;

%% 3. Input: specify configuration parameters
% replace configuration script by following commands
timer_trace_gen=tic;

options.debug=0;
options.model=5;
addpath(genpath('utilities'))
run('quad_variables.m')

% Time horizon of simulation in Simulink
options.T_train=20; % for constant choose 5s

%%% Here you specify the ranges of the inputs (references in our case) for
%%% Breach. The min, max can be scalar or vectors.

options.reference_type=4;
options.input_choice=options.reference_type;
options.no_traces=100;
options.breach_ref_min=[0.2 0 0.5];
options.breach_ref_max=[0.4 0.1 0.5];
options.breach_segments=2;

% Select if you want prepropreccing
options.preprocessing_bool=0;
options.preprocessing_eps=0.01;

% Select if you want trimming
options.trimming=0;

% Do NOT change this part
options.dt=0.01; % PID sampling time

fprintf('The total number of traces is %i.\n\n',options.no_traces);

%% 4a. Run simulations -- Generate training data

disp('------------------------------')
disp('Trace generation ')
disp('------------------------------')

warning off
[data,options]=trace_generation_nncs(options.SLX_model,options);
disp(' ')
disp('Check above in the terminal if any simulation errors occured!')
pause
timer.trace_gen=toc(timer_trace_gen);

%% 5a. Data Selection
options.trimming=0;
options.keepData_factor=50;% we keep one out of every 5 data
options.deleteData_factor=0; % we delete one every 3 data points
if options.trimming
    [data]=trim_data(data,options);
end

% 5b. Data Preprocessing
display_ranges(data);
options.preprocessing_bool=0;
options.preprocessing_eps=0.001;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end

%% 6. Train NN Controller
% this is for testing that the data concatenation is done correctly and
% training can be started.
choice=input('Do you want to train an NN (press 0 for "no", or any number for "yes")? ');
if ~choice
   return
end
timer_train=tic;
training_options.retraining=0;
training_options.use_error_dyn=0;       % watertank=1    %robotarm=0    %quadcopter=0
training_options.use_previous_u=0;      % waterank=2     %robotarm=2    %quadcopter=0
training_options.use_previous_ref=0;    % waterank=3     %robotarm=3    %quadcopter=0
training_options.use_previous_y=0;
training_options.neurons=[30 30 ];
% training_options.neurons=[50 ];
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='custom_v1';
% training_options.loss='wmse';
training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-6;
training_options.max_fail=50; % Validation performance has increased more than max_fail times since the last time it decreased (when using validation).
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm';%'trainlm'; % trainscg % trainrp
training_options.replace_by_zeros=0;

[net,data,tr]=nn_training(data,training_options,options);

fprintf('\n The requested training error was %.9f.\n',training_options.error);
fprintf('\n The smallest training error was %.9f.\n',tr.best_vperf);
fprintf('\n The smallest validation error was %.9f.\n',tr.best_vperf);

timer.train=toc(timer_train)

%% 7. Evaluate NN

options.plotting_sim=1;
plot_NN_sim(data,options);

%% 8a. Create Simulink block for NN

gensim(net);
