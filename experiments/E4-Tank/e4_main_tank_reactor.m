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

% NIKOS: problem with toolbox, If a class defines superclasses, all or none must be handle classes.


%%------------- BEGIN CODE --------------

%% 0. Add files to MATLAB path
try
    run('../../startup_nncs.m')
end

%% 1. Initialization
clear;close all;clc; bdclose all;
try
    delete(findall(0)); % close Simulink scopes
end
%% 2. Iput: specify Simulink model
% The models are saved in ./models/
% SLX_model='models/robotarm/robotarm_PID','robotarm_PID','quad_1_ref','quad_3_ref',
%'quad_3_ref_6_y','helicopter','watertank_comp_design_mod';
model=4; % 1: watertank, 2: robotarm, 3: quadcopter

if model==4
    SLX_model='e4_tank_reactor_no_error_dyn';
end
load_system(SLX_model)
% Uncomment next line if you want to open the model
% open(SLX_model)
options.model=model;
%% 3. Input: specify configuration parameters
% run('configuration_1.m'),('config_quad_1_ref.m')
timer_trace_gen=tic;
if model==4
    run('e4_config_tank.m')
end
%% 4a. Run simulations -- Generate training data
options.error_mean=0%0.0001;
options.error_sd=0%0.001;
options.save_sim=0;
% Breach options
% options.no_traces=30;
% options.breach_segments=2;
options.trace_gen_via_sim=0;

options.coverage.points='r';
options.combination=0
options.debug=0
[data,options]=trace_generation_nncs(SLX_model,options);
timer.trace_gen=toc(timer_trace_gen)
%% 4b. Load previous saved traces
if options.load==1
    % specify dataset from outputs/ folder
    dataset{1}='data_part_1.mat'
    dataset{2}='data_part_2.mat'
    [data,options]= load_data(dataset,options);
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
options.trimming_steady_state=0
training_options.use_time=0
% data=data_combined;
if  model==4
    training_options.use_error_dyn=0;       % watertank=1    %robotarm=0    %quadcopter=0
    training_options.use_previous_u=2;      % waterank=2     %robotarm=2    %quadcopter=0
    training_options.use_previous_ref=2;    % waterank=3     %robotarm=3    %quadcopter=0
    training_options.use_previous_y=2;
    %options.extra_y=1;
    %options.extra_ref=0;
end
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
training_options.iter_max_fail=1;
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
%{
% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);
%}

%% 7. Evaluate NN
options.plotting_sim=1
plot_NN_sim(data,options);

%% 8a. Create Simulink block for NN

% gensim(net)
[options]=create_NN_diagram(options,net);

% 8b. Integrate NN block in the Simulink model
construct_SLX_with_NN(options,options.SLX_model);

%% 9. Analyse NNCS in Simulink
model_name=[];
options.input_choice=3;
options.error_mean=0;%0.0001;
options.error_sd=0;%0.001;
if model==4
    options.ref_Ts=10;             %tank_reactor
    options.sim_ref=8.5;
    options.ref_min=2;
    options.ref_max=2.5;
    all_ref=unique(data.REF,'stable');
    options.sim_cov=all_ref(5:6);
%     options.sim_cov=[options.coverage.cells{12}.random_value];
    options.u_index_plot=1;
    options.y_index_plot=1;
    options.ref_index_plot=1;
end
[ref,y,u]=run_simulation_nncs(options,model_name,1);

%% 10. Data matching (analysis w/ training data)

%warning('This code only works for coverage')

if options.reference_type==3
    if options.plotting_sim
        plot_coverage_boxes(options,1);
    end
    options.testing.plotting=0;
    options.testing.train_data=0;% 0: for centers, 1: random points
    options.test_dataMatching=0;
    if options.test_dataMatching
        [testing,options]=test_coverage(options,model_name);
    end
end
%% 10B. testing on training data
file_name=options.SLX_model;
falsification_all_options;
options.input_choice=4;
[original_rob,In_Original] = check_cex_all_data(data,falsif,file_name,options);


%% 11. Falsification with Breach

if ~exist('falsif')
    falsification_all_options
end
%%% ------------------------------------------ %%
%%% ----- 11-A: Falsification with Breach ---- %%
%%% ------------------------------------------ %%
falsif.test_only_original=1;

falsif.iterations_max=3;
falsif.method='quasi';
falsif.num_samples=100;
falsif.max_obj_eval=100;

stop=0;
i_f=1;


% file_name=strcat(options.SLX_NN_model,'_cex');
file_name=strcat(options.SLX_model);

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
            fprintf('\n\n The nominal produces %i falsifying traces out of %i total traces.\n',length(find(rob_nominal<0)),length(falsif_pb_temp.obj_log));
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
    fprintf('\n\n The NN produces %i falsifying traces out of %i total traces.\n',length(find(falsif_pb_temp.obj_false<0)),length(falsif_pb_temp.obj_log));
    fprintf('\n\n The nominal produces %i falsifying traces out of %i total traces.\n',length(find(rob_nominal<0)),length(falsif_pb_temp.obj_log));
    falsif_temp=toc(timer_falsif);
    timer.falsif{i_f}=falsif_temp
    
    fprintf('\n End falsification with Breach.\n')
    disp('-----------------------------------')
    %%% ------------------------------------ %%
    %%% ----- 11-B: Clustering  CEX     ---- %%
    %%% ------------------------------------ %%
    %
    timer_cluster=tic;
    cluster_all=0;
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
        falsif.test_previous_nn=0;

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
        num_cex=2;options.plotting_sim=1;
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

disp(' ')
disp('-----------------')
disp('END of EXPERIMENT')
stop
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
