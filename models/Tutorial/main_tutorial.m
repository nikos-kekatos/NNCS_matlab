%===================================================
% This program receives a closed-loop model (Simulink) and a property (STL) 
% and produces a Neural Network Control System which satisfies the given 
% property a feedforward neural network.
%===================================================

% Syntax:
%    >> run('main_tutorial.m') or main_tutorial or run(main_tutorial)
%
% Inputs:
%    i) Simulink model with nominal controller and plant, and
%   ii) Configuration file 
%  iii) Specification file
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
% Written:      
% Last update:  ---
% Last revision:---

%%------------- BEGIN CODE --------------

%% Add files to MATLAB path

% The user can either manually add the files e.g. right click on the roor
% directory and choose "add to path/Select folders and subfolder' or simply 
% run the following command.
% the startup script.

addpath(genpath("../../"))
% startup_fcn

disp('You need to add to the path the directory where Breach is located....');
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))

% initialize Breach
InitBreach
%% Initialization

clear;close all;clc; 
try
    delete(findall(0)); % close Simulink scopes
end
% bdclose all; % close all Simulink models
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                   MODEL                       %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1: Specify the inputs (models, config)

% The models are saved in ./models/
%1: watertank, 2: robotarm, 3: linear quadcopter, 4: tank reactor,
%5: nonlinear quad (PID), 7: switched (P-PID) 

model=7;
SLX_model='tutorial_switched_nominal';
load_system(SLX_model)

% Uncomment next line if you want to open the model
% open(SLX_model)

timer_trace_gen=tic; % clock for trace generation

% Specify config file
run('config_tutorial.m')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%               TRACE GENERATION                %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2: Generate simulation data
%overwrite simulation choices
options.error_mean=0;
options.error_sd=0.001; % replace by 0 and rerun all experiments.

options.plotting_sim=0;
options.debug=0;
options.save_sim=0;

% coverage approach
options.reference_type=3 % 3: for coverage (think of 2d box), 4: Breach tool;

options.coverage.points='r'; % options.coverage.points= 'c'
[data1,options]=trace_generation_nncs(SLX_model,options);
timer.trace_gen=toc(timer_trace_gen)


%% call Breach 
options.input_choice=4; %choice for Breach
% options.no_traces=10; % overwrites default options
options.breach_segments=2;% overwrites default options
options.trace_gen_via_sim=1; % 1 for simulation and 0 for falsification
[data2,options]=trace_generation_nncs(SLX_model,options);

%% CHOOSE DATA (breach or manual)
%% combine multiple data
[data]=combine_data(data1,data2);
 
%% otherwise choose, e.g.
data=data1;
 
%% check ranges
display_ranges(data);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%               DATA SELECTION                  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data Preprocessing
options.preprocessing_bool=1; % flag ,if 0 then it wil not do preprocess.
options.preprocessing_eps=1e-5;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end

%% Data Selection (uniform)
options.trimming=1;
options.keepData_factor=10;% we keep one out of every $k$ data
options.deleteData_factor=0; % we delete one every $m$ data points
if options.trimming
    [data]=trim_data(data,options);
end

%% Data Selection (steady-state trimming)
options.trimming_steady_state=1;
options.trim_ss_time=10; % user-defined: it depends on the model
options.keepData_factor=1;% we keep one out of every $k$ data
options.deleteData_factor=2; % we delete one every $m$ data points

if options.trimming_steady_state
    [data]=trim_data_ss(data,options);
end
%% For the turorial purposes
% you need to choose one of these options
options.trimming=0;
options.preprocessing_bool=0;
options.trimming_steady_state=0;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%              TRAINING                  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NEURAL NETWORK ARCHITECTURE

% currently only **feedforward nets** are supported
% we have experimented with LSTM (somewhere in the repo, ther is some
% relevant code)

% stored in "training_options"
training_options.neurons=[20 10 ]; % 2 layers with 20 and 10 neurons each
training_options.use_error_dyn=0;      % answer: 0 or 1, use error dynamics or not
training_options.use_previous_u=0;     % answer: integer, number of previous u values
training_options.use_previous_ref=2;   % answer: integer, number of previous references
training_options.use_previous_y=2;     % answer: integer, number of previous outputs
options.extra_y=0;
training_options.use_time=0;
training_options.retraining=0;

% Training Parameters
training_options.input_normalization=0;
training_options.loss='mse'; %'mae', 'mape'
% we have experimented with our own loss functions
% you can write training_options.loss='wmse' or 'custom_v1';
training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-5;
training_options.max_fail=50; % Validation performance has increased more than max_fail times since the last time it decreased'.
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm'  %'trainrp', 'trainlm', 'traingdx', 'trainscg', 'crossentropy'
training_options.replace_by_zeros=1; % there are 3 options (concatenation & history)
% 0: no accounting for prior values, 1: prior values (when not existing)
% replaced by zero, 2: prior values (when not existing) replace by the
% first existing values (typically at time t=0)

%% Training
[net,data,tr]=nn_training(data,training_options,options);

fprintf('\n The requested training error was %f.\n',training_options.error);
fprintf('The obtained training error is %f.\n',tr.best_perf);
fprintf('The validation error is %f.\n',tr.best_vperf);

%%  Training in a loop
% sometimes training is not easy and the desired errors cannot be reached,
% it is possibl to run multiple times the training with different random 
% initializations. 

training_options.iter_max_fail=2; %maximum number of training attempts
iter=1;reached=0;
while true && iter<=training_options.iter_max_fail
    fprintf('\n Iteration %i.\n',iter);
    [net,data,tr]=nn_training(data,training_options,options);
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


%% TRAINING in Python
% we have experimented using Keras/Tensorflow.
% There is python code (and some scripts for translation) to 
% 1) import the matlab data in Python, 2) perform training with Keras, 3)
% transfer the generated net back to Matlab.

%% TRAINING LSTM

% Problem with creating new closed-loop: there is no way to create a Simulink block.

% Xtrain=data.in;
% Ytrain=data.out;
XTrain = cell(1,1);
XTrain{1}=[data.REF';data.Y'];
YTrain = cell(1);
YTrain{1}=data.U';

numFeatures = 2;
numResponses = 1;
numHiddenUnits = 200; % you can reduce it for computational reasons.

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

lstm_options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

% 250 epochs is too many! Beware that training can last long.
net_lstm = trainNetwork(XTrain,YTrain,layers,lstm_options);

net_lstm = predictAndUpdateState(net_lstm,XTrain);
% [net_lstm,YPred] = predictAndUpdateState(net_lstm,XTrain);

XTest=XTrain;
YPred = predict(net_lstm,XTest);


%% Evaluating/Testing the network in open loop (against input/targets)

options.plotting_sim=1;
plot_NN_sim(data,options);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%     Neural Network Controller                  %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%The network is saved as an object and we need to create a new closed loop.
% It cannot be done automatically (yet).


% we create a copy of the nominal closed-loop
% we add the memory blocks
% we add the connections
% we change the names accordingly 

%% create the simulink neural network 

file_name='tutorial_switched_nets';

% gensim(net)
[options]=create_NN_diagram(options,net);

% Integrate NN block in the Simulink model
construct_SLX_with_NN(options,file_name);

%% Simulate NNCS and nominal
options.input_choice=3;

options.ref_Ts=20;             
options.sim_ref=1.2;
options.ref_min=0;
options.ref_max=2;
options.sim_cov=options.coverage.cells{3}.random_value;
% options.sim_cov=[0.5; 0.25]

options.u_index_plot=1;
options.y_index_plot=1;
options.ref_index_plot=1;

run_simulation_nncs(options,file_name,1);
options.input_choice=4;

%% Check if new NNCS satisfies given STL property

falsification_options_init; % run once to speed up the process
options.input_choice=4;
[original_rob,In_Original] = check_cex_all_data(data,falsif,file_name,options);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%     Falsification and Retraining                %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Falsification with Breach

if ~exist('falsif')
    falsification_options_init
end
falsif.method='quasi';
falsif.num_samples=100;
falsif.max_obj_eval=100;
falsif.iterations_max=2; % specify iterations of falsification loop. 
% overwrites default in falsification_options_init

stop=0;
i_f=1;


options.input_choice=4;
net_all{1}=net;
seeds_all=falsif.seed*(1:falsif.iterations_max);
while i_f<=falsif.iterations_max && ~stop
    timer_falsif=tic;
    fprintf('\n Iteration %i.\n',i_f)
    %     if i_f>1
    %         fprintf('\n Testing the NN on the training data')
    %         [data_cex,falsif_pb]= falsification_breach(options,falsif,model_name);
    %         fprintf('The number of CEX is now %i.\n',length(falsif_pb.obj_false));
    %     end
    fprintf('\n Beginning falsification with Breach.\n')
    fprintf('\n We use the model %s for falsification.\n',options.SLX_model);
    %     if i_f==1
    %         model_name=options.SLX_NN_model;
    %     else
    %         disp('Use model with cex -- currently overwrite the same model. Todo: Add duplicates')
    %         model_name=file_name;
    %     end
    falsif.seed=seeds_all(i_f);
    falsif.iteration=i_f; % choose property
    check_nominal=0;
    [data_cex,falsif_pb_temp,rob_nominal]= falsification_breach(options,falsif,file_name,check_nominal);
    robustness_checks_false{i_f,1}=falsif_pb_temp.obj_false;
    robustness_checks_all{i_f,1}=falsif_pb_temp.obj_log;
    if check_nominal
        robustness_checks_all{i_f,2}=rob_nominal;
    end
    falsif_pb{i_f}=falsif_pb_temp;
    %     fprintf('The number of CEX is now %i.\n',length(falsif_pb{i_f}.obj_false));
    
    if any(structfun(@isempty,data_cex))
        fprintf('\n Breach could not falsify the STL formula.\n')
        fprintf('\n Trying with a different method (GNN) and more objective evaluations.\n')
        falsif.method='GNM';
        %         falsif.max_obj_eval=falsif.max_obj_eval*2;
        [data_cex,falsif_pb_zero,rob_nominal]= falsification_breach(options,falsif,file_name,check_nominal);
        if check_nominal
            robustness_checks_all{i_f,2}=rob_nominal;
        end
        if any(structfun(@isempty,data_cex))
            stop=1;
            fprintf('\n\n The NN produces %i falsifying traces out of %i total traces.\n',length(find(falsif_pb_temp.obj_false<0)),length(falsif_pb_temp.obj_log));
            if check_nominal
            fprintf('\n\n The nominal produces %i falsifying traces out of %i total traces.\n',length(find(rob_nominal<0)),length(falsif_pb_temp.obj_log));
            end
            falsif_temp=toc(timer_falsif);
            timer.falsif{i_f}=falsif_temp
            break;
        else
            falsif.method='quasi';
            falsif_pb{i_f}=falsif_pb_zero;
            robustness_checks_all{i_f,1}=falsif_pb{i_f}.obj_log;
            robustness_checks_false{i_f,1}=falsif_pb{i_f}.obj_false;
        end
    end
  try
        figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)
    end
    try
        figure;falsif_pb{i_f}.BrSet_Logged.PlotSignals({'In1', 'y','y_nn'});
    end
    fprintf('\n\n The NN produces %i falsifying traces out of %i total traces.\n',length(find(falsif_pb{i_f}.obj_false<0)),length(falsif_pb{i_f}.obj_log));
    if check_nominal
        fprintf('\n\n The nominal produces %i falsifying traces out of %i total traces.\n',length(find(rob_nominal<0)),length(falsif_pb{i_f}.obj_log));
    end
    falsif_temp=toc(timer_falsif);
    timer.falsif{i_f}=falsif_temp
    fprintf('\n End falsification with Breach.\n')
    disp('-----------------------------------')
    %%% ------------------------------------ %%
    %%% -----  B: Clustering  CEX     ---- %%
    %%% ------------------------------------ %%
    %
    timer_cluster=tic;
    cluster_all=1;
    [data_cex_cluster,idx_cluster]=cluster_and_sample(data_cex,falsif_pb{i_f},falsif,options,cluster_all);
    
    if i_f==1
        Data_all{i_f,1}=data;
        Data_all{i_f,2}=data_cex;
    elseif i_f>1
        Data_all{i_f,1}=get_new_training_data( Data_all{i_f-1,1},Data_all{i_f-1,3},training_options);
        Data_all{i_f,2}=data_cex;
    end
    Data_all{i_f,3}=data_cex_cluster;
    data_backup=data_cex;
    data_cex=data_cex_cluster;
    timer.cluster{i_f}=toc(timer_cluster)
    %
    %%% ------------------------------------ %%
    %%% ----- C: Retraining with CEX ---- %%
    %%% ------------------------------------ %%
    %
    training_options.combining_old_and_cex=1;
    if stop~=1
        for tm = 1%[2 3 1] % or we choose the preference/order
            timer_retrain=tic;
            fprintf('\nBeginning retraining with cex.\n')
            training_options.retraining=1; % the structure of the NN remains the same.
            training_options.retraining_method=tm; %1: start from scratch with all data,
            % 2: keep old net and use all data,  3: keep old net and use only new data
            % 4: blend/mix old and new data,  5: weighted MSE
            training_options.loss='mse';
            training_options.error=1e-6;
            training_options.max_fail=50;
%             training_options.div='dividetrain';
            % net.performParam.ratio=0.5;
            % Data_all contains the data from all cases (training, cex) and
            % iterations.
            
%             training_options.neurons=[30 30 30]
            % [net_cex,data]=nn_retraining(net,data,training_options,options,[],data_cex);
            [net_all{i_f+1},~,tr]=nn_retraining(net_all{i_f},Data_all{i_f,1},training_options,options,[],Data_all{i_f,3});
            if tr.best_perf <= training_options.error*100
                fprintf('\nDesired MSE value reached.\n');
                fprintf('\nEnd retraining with cex.\n')
                break;
            end
            fprintf('\n End retraining with cex.\n')
        end
        disp('-----------------------------------')
        timer.retrain{i_f}=toc(timer_retrain)
        %%% ------------------------------------------ %%
        %%% ------ D: Simulink Construction  ------ %%
        %%% ------------------------------------------ %%
        %
        fprintf('\n Beginning Simulink construction with cex.\n')
        [options]=create_NN_diagram(options,net_all{i_f+1});
        %     block_name=strcat('NN_cex_',num2str(i_f));
        block_name=strcat('NN_cex_',num2str(1));
        
        construct_SLX_with_NN(options,file_name,block_name);
        fprintf('\n End Simulink construction with cex.\n')
        disp('-----------------------------------')
        
        %%% ----------------------------------------------- %%
        %%% ------ E: Testing if CEX disappeared   ----- %%
        %%% ----------------------------------------------- %%
        timer_rechecking=tic;
        falsif.test_previous_nn=1

        fprintf('\n Testing the NN on the training data.\n')
        fprintf('The number of original CEX was %i.\n',length(falsif_pb{i_f}.obj_false));
        [rob_temp_false,rob_temp_all,inputs_cex,inputs_all,options]=check_cex_elimination(falsif_pb{i_f},falsif,data_cex,file_name,idx_cluster,options);
        %     fprintf(' \n The original robustness values were %s.\n',num2str(robustness_checks{1}));
        timer.rechecking{i_f}=toc(timer_rechecking);

        fprintf(' \n The new robustness values are %s.\n',num2str(rob_temp_false));
        robustness_checks_false{i_f,2}=rob_temp_false
        robustness_checks_all{i_f,3}=rob_temp_all
        fprintf(' \n The original CEX were %i, CEX after cluster, %i and with the new CEX are %i.\n',numel(find(robustness_checks_false{i_f,1}<0)),numel(idx_cluster),numel(find(robustness_checks_all{i_f,3}<0)));
        fprintf('\n We have %i CEX after clustering and after retraining we have %i.\n\n',numel(idx_cluster),numel(find(robustness_checks_false{i_f,2}<0)));
        
        if  isequal(falsif_pb_temp.X_log,inputs_all)
            disp(' We have tested the same inputs with CheckSpec.')
        end
        %%% ----------------------------------------------- %%
        %%% ------       F: Plotting CEX     ----------- %%
        %%% ----------------------------------------------- %%
        %
        options.input_choice=3
        num_cex=1;options.plotting_sim=1;
        run_and_plot_cex_nncs(options,file_name,inputs_cex,num_cex); %4th input number of counterexamples
        options.input_choice=4;
    end
    %
    fprintf('\n End of Iteration %i.\n',i_f)
    if i_f<falsif.iterations_max
        i_f=i_f+1;
    else
        fprintf('\n\n------------\n\n');
        fprintf('Reached maximum number of iterations.\n');
        break;
    end
    
end
