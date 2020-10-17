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
% Written:      22-July-2020
% Last update:  ---
% Last revision:---


%%------------- BEGIN CODE --------------

%% 0. Add files to MATLAB path
%% You need to change current folder to this one.
current_file = matlab.desktop.editor.getActiveFilename;
current_path=fileparts(current_file);
% current_file=which('main_nncs_combination.m');
% current_path=fileparts(current_file);
idcs   = strfind(current_path,filesep);
module_dir = current_path(1:idcs(end)-1); % 1 steps back
cd(current_path);
addpath(genpath(module_dir));
rmpath(genpath([module_dir filesep 'NIPS_submission']));
% clear idcs current_file current_path module_dir
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/'))

%% 1. Initialization
clear;close all;clc; bdclose all;
try
    delete(findall(0)); % close Simulink scopes
end
%% 2. Input: specify Simulink model
% The models are saved in ./models/

SLX_model='watertank_multPID_2018a_v3';

load_system(SLX_model)
% Uncomment next line if you want to open the model
% open(SLX_model)

%% 3. Input: specify configuration parameters
timer_trace_gen=tic;
model=10;
options.model=model;

run('config_1_watertank_comb.m')
options.debug=0;
options.plotting_sim=0;
options.save_sim=0;
%% Falsification nominal controllers
options.falsif_nominal=0;
if options.falsif_nominal
run('falsification_nominal.m')
end
%  Controller -- 1
% We ran 100 scenarios and found 0 (overshoot) and 2 (stabilization)  CEX.
% 
%  Controller -- 2
% We ran 100 scenarios and found 3 and 0 CEX.
%% 4a. Run simulations -- Generate training data (combined)
options.error_mean=0;%0.0001;
options.error_sd=0;%0.001;
% options.save_sim=1;
% options.coverage.points='r';
% options.plotting_sim=1
options.load=0;
options.combination_matlab=2; %use robustness
clear compute_robustness
if ~options.load
[data,options]=trace_generation_nncs(SLX_model,options);
timer.trace_gen=toc(timer_trace_gen)
end
%% 4b. Load previous saved traces
if options.load==1
    % specify dataset from outputs/ folder
    dataset{1}='array_sim_cov_varying_ref_64_traces_1x1_time_20_06-06-2020_03:24.mat';
    %     dataset{1}='data_part_1.mat',  dataset{2}='data_part_2.mat'
    dataset{1}='comb_3_contr_10_sec.mat';
    dataset{1}='comb_32_v3.mat';
    [data,options]= load_data(dataset,options);
    % load('comb_data_16.mat');
    % load('comb_16_v2.mat');
%     load('comb_32_v3.mat')
end
%% 4c. Plot all traces w/ combined
if options.debug
for i=1:floor(options.no_traces)%/10
    fprintf('Testing controllers -- Trace %i.\n\n',i)
    model_name=options.SLX_model_falsif;
    % model_name='watertank_comp_design_mod_NN';
    options.input_choice=3;
    options.error_mean=0;%0.0001;
    options.error_sd=0;%0.001;
    options.ref_Ts=5;options.T_train=10;
    options.sim_ref=11;          % watertank
    options.ref_min=8.5;
    options.ref_max=11.5;
    options.sim_cov=[12;8];%[8.5;11;8;12;9;8];
    if options.coverage.points=='r'
        options.sim_cov=options.coverage.cells{i}.random_value;
    elseif strcmp(options.coverage.points,'r')
        warning('to-do')
    end
    options.u_index_plot=1;
    options.y_index_plot=1;
    options.ref_index_plot=1;
    clear compute_robustness
% global options
    [~,~,~,options]=run_simulation_nncs_comb(options,model_name,'rob'); %'rob': nominal robust, %1: for traces wo/ NN, % 3 for combined (with nominal NN) %4 for combined (no nominal)
    options.input_choice=4;
    
end
end
%% 5a. Data Selection
options.trimming=0;
options.keepData_factor=1;% we keep one out of every 5 data
options.deleteData_factor=5; % we delete one every 3 data points
if options.trimming
    [data]=trim_data(data,options);
end
%% 5b. Data Preprocessing
display_ranges(data);
options.preprocessing_bool=0;
options.preprocessing_eps=0.0001;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end
%% 6. Train NN Controller
%the assignments could go a function/file
timer_train=tic;
training_options.retraining=0;

training_options.use_error_dyn=1;       % watertank=1    %robotarm=0    %quadcopter=0
training_options.use_previous_u=2;      % waterank=2     %robotarm=2    %quadcopter=0
training_options.use_previous_ref=3;    % waterank=3     %robotarm=3    %quadcopter=0
training_options.use_previous_y=3;
options.extra_y=0;
options.extra_ref=0;
training_options.neurons=[30 30];
% training_options.neurons=[50 ];
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
training_options.iter_max_fail=2;
iter=1;reached=0;
training_options.replace_by_zeros=1;
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
timer.train=toc(timer_train)
if options.plotting_sim
    figure;plotperform(tr)
end

%% 7. Evaluate NN
% options.plotting_sim=1
plot_NN_sim(data,options);

%% 8a. Create Simulink block for NN
options.SLX_model_combined=strcat(options.SLX_model,'_comb')
% gensim(net)
[options]=create_NN_diagram(options,net);

% 8b. Integrate NN block in the Simulink model

file_name=options.SLX_model_falsif
construct_SLX_with_NN(options,file_name,'NN_comb');

%% 9A. Data matching (analysis w/ training data)
% Compare via MSE (y_nn, y_nominal) 
% compare  over training data

%%% ADD OPTION and move 
warning('This code only works for coverage')
file_name=options.SLX_model_falsif;

if options.reference_type==3
    if options.plotting_sim
        plot_coverage_boxes(options,1);
    end
    options.testing.plotting=0;
    options.test_dataMatching=1;
    options.testing.train_data=1;% 0: for centers, 1: random points
    if options.test_dataMatching
        [testing,options]=test_coverage(options,file_name);
    end
end
%% 9B. Matching test against STL property

falsification_options;
options.input_choice=4
[original_rob,In_Original] = check_cex_all_data(data,falsif,file_name,options);

%% 10. Individual Controller---Simulate, generate traces, create NN, plot, etc.

if options.training_nominal
    training_nominal
end
%% 11. Analyse NNCS in Simulink
model_name=options.SLX_model_falsif;
% model_name='watertank_comp_design_mod_NN';
options.input_choice=3;
% model=2;
options.error_mean=0;%0.0001;
options.error_sd=0;%0.001;
options.ref_Ts=5;options.T_train=10;
options.sim_ref=11;          % watertank
options.ref_min=8.5;
options.ref_max=11.5;
options.sim_cov=[11.5;9.5];%[8.5;11;8;12;9;8];
options.sim_cov=options.coverage.cells{12}.random_value
options.u_index_plot=1;
options.y_index_plot=1;
options.ref_index_plot=1;

[ref,y,u]=run_simulation_nncs_comb(options,model_name,5); % 3 for combined (with nominal NN) %4 for combined (no nominal)
options.input_choice=4;


%% 11. Falsification with Breach (NOT FINISHED)

%  delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
get_param(Simulink.allBlockDiagrams(),'Name')
bdclose all;
clear Data_all data_cex Br falsif_pb net_all phi_1 phi_3 phi_4  phi_5 phi_all
clear robustness_checks_all robustness_checks_false  falsif_pb_temp file_name
clear rob_nominal robustness_check_temp block_name falsif_idx data_cex
clear data_cex_cluster tr tr_all condition cluster_all check_nominal model_name
clear data_backup i_f ii In1_dt0 In1_u0 In1_u1 inputs_cex iter iter_best num_cex
clear reached seeds_all stop t__ tm training_perf tspan u__ idx_cluster falsif_pb_zero

%%% ------------------------------------------ %%
%%% ----- 11-A: Falsification with Breach ---- %%
%%% ------------------------------------------ %%
falsif.max_obj_eval_local=100;
falsif.num_samples=100;
falsif.seed=100;
falsif.iterations_max=2;
falsif.property_file='specs_watertank_comb_ctrl_1.stl';
%'specs_watertank_stabilization_ctrl_1.stl'
%'specs_watertank_stabilization_comb.stl';

stop=0;
i_f=1;

% file_name=strcat(options.SLX_NN_model,'_cex');
file_name=strcat(options.SLX_model_falsif);

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
    fprintf('\n We use the model %s for falsification.\n',file_name);
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
%         fprintf('\n\n The NN produces %i falsifying traces out of %i total traces.\n',length(find(falsif_pb_temp.obj_false<0)),length(falsif_pb_temp.obj_log));

        fprintf('\n Trying with a different method (GNN) and more objective evaluations.\n')
        falsif.method='GNM';
        %         falsif.max_obj_eval=falsif.max_obj_eval*2;
        [data_cex,falsif_pb_zero,rob_nominal]= falsification_breach(options,falsif,file_name,check_nominal);
        if check_nominal
            robustness_checks_all{i_f,2}=rob_nominal;
        end
        falsif_pb{i_f}=falsif_pb_zero;
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
            robustness_checks_all{i_f,1}=falsif_pb{i_f}.obj_log;
            robustness_checks_false{i_f,1}=falsif_pb{i_f}.obj_false;
        end
    end
    try
        figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)
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
    %%% ----- 11-AB: Generating new combined traces ---- %%
    %%% ------------------------------------ %%
    
    % the references are stored in data_cex.REF
    options_new=options;
    options_new.coverage=rmfield(options_new.coverage,'cells');
    options_new.no_traces=size(data_cex.REF_values,2);
    options_new.coverage.no_traces_ref=options_new.no_traces;
    for i=1:options_new.no_traces
    options_new.coverage.cells{i}.random_value=[data_cex.REF_values(:,i)];
    end
    options_new.plotting_sim=1;
    options_new.input_choice=3;
    [data_cex_comb,options_new]=trace_generation_nncs(SLX_model,options_new);
    timer.trace_gen_cex=toc(timer_trace_gen)
%     options_new.input_choice=4;

    %
    %%% ------------------------------------ %%
    %%% ----- 11-B: Clustering  CEX     ---- %%
    %%% ------------------------------------ %%
    %
    timer_cluster=tic;
    cluster_all=0;
    [data_cex_cluster,idx_cluster]=cluster_and_sample(data_cex_comb,falsif_pb{i_f},falsif,options,cluster_all);
    
    if i_f==1
        Data_all{i_f,1}=data;
        Data_all{i_f,2}=data_cex_comb;
    elseif i_f>1
        Data_all{i_f,1}=get_new_training_data( Data_all{i_f-1,1},Data_all{i_f-1,3},training_options);
        Data_all{i_f,2}=data_cex_comb;
    end
    Data_all{i_f,3}=data_cex_cluster;
    data_backup=data_cex_comb;
    data_cex_comb=data_cex_cluster;
    timer.cluster{i_f}=toc(timer_cluster)
    %
    %%% ------------------------------------ %%
    %%% ----- 11-C: Retraining with CEX ---- %%
    %%% ------------------------------------ %%
    %
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
        %%% ------ 11-D: Simulink Construction  ------ %%
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
        %%% ------ 11-E: Testing if CEX disappeared   ----- %%
        %%% ----------------------------------------------- %%
        timer_rechecking=tic;
        
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
        %%% ------       11-F: Plotting CEX     ----------- %%
        %%% ----------------------------------------------- %%
        %
        options.input_choice=3
        num_cex=2;
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

%% 12a. Checking CEX against SLX
fprintf('\n\n------------\n\n');
fprintf('\nHere we check if there are any problems with the way we store the data.\n');

if exist('idx_cluster')
    fprintf('The number of resulting CEX is %i.\n',numel(idx_cluster));
else
    fprintf('There are no CEX left.\n');
end
data_test=data_cex_cluster;
% data_test=Data_all{2,2};
% data_test=data_backup;
no_points=1000;
no_cex=size(data_test.REF,1)/no_points;REF=[];
for i=1:no_cex
    %     figure;plot(linspace(0,10,no_points),data_test.REF(1+(i-1)*no_points:i*no_points),'r',linspace(0,10,no_points),data_test.Y(1+(i-1)*no_points:i*no_points),'b-.')
    %     title(sprintf('CEX %i.',i))
    %     legend('ref','breach/data\_cex')
    ref_falsif=unique(data_test.REF(1+(i-1)*no_points:i*no_points),'stable');
    REF=[REF,ref_falsif];
end
REF
options.input_choice=3;
options.sim_ref=8;
if numel(ref_falsif)==2
    options.ref_Ts=options.T_train/2;
elseif numel(ref_falsif)==1
    options.ref_Ts=options.T_train;
else
    error('Checking can be done for signals with 2 pieces')
end
for i=1:no_cex
    options.sim_cov=REF(:,i);
    options.workspace = simset('SrcWorkspace','current');
    sim(SLX_model,[],options.workspace);
    %     figure; plot(ref.time(1:(end-1)),ref.signals.values(1:(end-1)),'r',y.time(1:(end-1)),y.signals.values(1:(end-1)),'b-.')
    %     title(sprintf('CEX %i.',i))
    %     legend('ref','SLX')
    
    figure;plot(ref.time(1:(end-1)),ref.signals.values(1:(end-1)),'r',y.time(1:(end-1)),y.signals.values(1:(end-1)),'b-.',linspace(0,10,no_points),data_test.Y(1+(i-1)*no_points:i*no_points),'m-.')
    legend('ref','SLX sim','breach')
    title(sprintf('CEX %i.',i))
end
%%
disp('-----------')
disp('     The last counterexamples:')
REF
disp('      The previous counterexamples:')
REF_previous_temp=unique(Data_all{1,2}.REF,'stable');
REF_previous=reshape(REF_previous_temp,[2,numel(REF_previous_temp)/2])
plot_coverage_boxes(options,1)
hold on
plot(REF_previous(1,:),REF_previous(2,:),'ms')
plot(REF(1,:),REF(2,:),'bx')

%% 12b. Check NN-cex on original training data

[original_rob,In_Original] = check_cex_all_data(Data_all,falsif,file_name,options);
figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)

%% 12c. Evaluating retrained SLX model

model_name=[];
options.input_choice=3;

if model==1
    model_name='watertank_inport_NN_cex';
    options.ref_Ts=5;
    options.T_train=10;
    options.sim_ref=8;               %watertank 8
    options.ref_min=8.5;                %watertank 8.5
    options.ref_max=11.5;               %watertank 11.5
    options.sim_cov=[8.7;11.8];             %watertank [12;8]
    %     options.sim_cov=[10.125;10.08];
    options.sim_cov=[inputs_all(1,3),inputs_all(3,3)];
elseif model==2
    model_name='robotarm';
    options.sim_ref=0.4;               % robotarm
    options.ref_min=-0.4;
    options.ref_max=0.3;
    options.sim_cov=[0.3;0.1];
elseif model==3
    model_name='quadcopter_NN_cex';
    options.sim_ref=0.4;               % quadcopter
    options.ref_min=1;
    options.ref_max=2.5;
    options.sim_cov=[2.5;-1.5];
elseif model==4
    options.ref_Ts=10;             %tank_reactor
    options.sim_ref=3;
    options.ref_min=2;
    options.ref_max=5;
    options.sim_cov=[8.9];
    options.u_index_plot=1;
    options.y_index_plot=1;
    options.ref_index_plot=1;
end

run_simulation_nncs(options,model_name,1) %3rd input is true for counterexamples

%{
%% Test multiple reference traces
plot_coverage_boxes(options,0)

model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test_3';
model_name='watertank_comp_design_mod_NN';

options.testing.train_data=0;% 0: for centers
[testing,options]=test_coverage(options,model_name);

%% Evaluate w/ Metrics
% load('cover_testing.mat')
% load('trained_net_for_cex.mat')
testing=plot_coverage_boxes(options,0,testing);
disp (' ')
% increasing order
fprintf('Potential candidates - Worst 10%% in terms of MSE error:\n\n');
fprintf('%g ',testing.errors_mse_index');
disp (' ')
fprintf('Potential candidates - Worst 10%% in terms of MAE error:\n\n');
fprintf('%g ',testing.errors_mae_index');
disp (' ')

index=intersect(testing.errors_mae_index,testing.errors_mse_index);
% index=[2 5];
testing.errors_final_index=index;
fprintf('Potential candidates. There are %i common traces:\n\n', numel(index));
fprintf('%g ',index);
disp (' ')

fprintf('Plotting these %i traces...\n\n',numel(index))
% index=testing.errors_mae_index;
plot_trace_testing_coverage(testing,index)

fprintf('Plotting finished.\n\n')

% write a function to plot trace & evaluate other errors?

% 1) plot_trace_with worst error
% 2) how many to choose?
% 3) plot worst 10 & visual inspections
% 4) from 4 check for other properties? check other metrics? and compare
% 5) r-value??? add check for different error functions? merge worst
% cells!
% 6) comparing only y and not u
% 7) from this 10, find worstthat are bad with both metrics
% 8)use them as counterexamples
% 9) store and save them
% 10) find best way to check them
%% save simulation traces to csv for mining

options.save_csv=0;
if options.save_csv
    save_traces_csv(testing,options);
end
%% Retraining
% we have already identified the counterexamples and here explore different
% options to do the retraining.
%now we just add one cex
index=[6 7 14 36 43];
options.testing_breach=0;
testing.errors_final_index=index;
training_options.retraining=1; % the structure of the NN remains the same.
training_options.retraining_method=2; %1: start from scratch with all data,
% 2: keep old net and use all data...
% 3: keep old net and use only new data
% 4: blend/mix old and new data
% 5: add weighted function
 net.performFcn='msereg';
% net.performParam.ratio=0.5;
net.trainParam.goal=1e-6;
net.trainParam.max_fail=10;
[net_cex,data]=nn_retraining(net,data,training_options,options,testing);

%% Create Simulink block for NN
gensim(net_cex)

%% Plot new NN traces with cex
% model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cex_3';
% model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cex_3b';
model_name='watertank_comp_design_mod_NN_comp';

cc=-0.1;
index=43;
% options.testing.sim_cov=[0.4,0.2];
options.testing.sim_cov=options.coverage.cells{index}.centers';
options.testing.sim_cov=[11.8; 10.5];
% plot_cex_traces;
plot_cex_traces_all;
%% improve figures
% fig_openb
%% 10. Evaluate Simulink NN
% same results with 7
 compare_NN_vs_nominal(data,options);
%}
