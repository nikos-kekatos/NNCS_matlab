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
try
delete(findall(0)); % close Simulink scopes
end
%% 2. Iput: specify Simulink model
% The models are saved in ./models/

% SLX_model='models/robotarm/robotarm_PID';
% SLX_model='robotarm_PID';
% SLX_model='quad_1_ref';
% SLX_model='quad_3_ref';
% SLX_model='quad_3_ref_6_y';
% SLX_model='helicopter';
%  SLX_model='watertank_comp_design_mod';
 SLX_model='watertank_inport';
load_system(SLX_model)
% Uncomment next line if you want to open the model
% open(SLX_model)

%% 3. Input: specify configuration parameters
% run('configuration_1.m')
% run('config_quad_1_ref.m')
 run('config_1_watertank.m')
%% 4a. Run simulations -- Generate training data
options.error_mean=0%0.0001;
options.error_sd=0%0.001;

% Breach options
% options.no_traces=30;
% options.breach_segments=2;
[data,options]=trace_generation_nncs(SLX_model,options);

%% 4b. Load previous saved traces
if options.load==1
    % specify dataset from outputs/ folder
    dataset{1}='array_sim_cov_varying_ref_81_traces_1x1_time_20_29-03-2020_07:33.mat';
%     dataset{2}='array_sim_constant_ref_300_traces_30x10_time_60_11-02-2020_08:26.mat';
dataset{1}='array_sim_constant_ref_25_traces_25x1_time_10_18-04-2020_19:22.mat';
    [data,options]= load_data(dataset,options);
end
%% 5a. Data Selection 
options.trimming=0;
options.keepData_factor=1;% we keep one out of every 5 data
options.deleteData_factor=9; % we delete one every 3 data points
if options.trimming
[data]=trim_data(data,options);
end
%% 5b. Data Preprocessing
display_ranges(data);
options.preprocessing_bool=0;
options.preprocessing_eps=0.001;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end
%% 6. Train NN Controller
%the assignments could go a function/file
training_options.retraining=0;
training_options.use_error_dyn=1;
training_options.use_previous_u=2;      % default=2
training_options.use_previous_ref=3;    % default=3
training_options.use_previous_y=3;      % default=3
% training_options.neurons=[20 10 10];
training_options.neurons=[30 30];
% training_options.neurons=[50 ];
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='custom_v1';
% training_options.loss='wmse';
 training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-5;
training_options.max_fail=10; % Validation performance has increased more than max_fail times since the last time it decreased (when using validation).
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm'%'trainlm'; % trainscg % trainrp
%add option for saved mat files
training_options.iter_max_fail=2;
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
plot_NN_sim(data,options)

%% 8a. Create Simulink block for NN

% gensim(net)
[options]=create_NN_diagram(options,net)

%% 8b. Integrate NN block in the Simulink model 
[options]=construct_SLX_with_NN(options);

%% 9. Analyse NNCS in Simulink
model_name=[];
% model_name='watertank_comp_design_mod_NN';
options.ref_Ts=5;
options.input_choice=1;
options.sim_ref=8;
options.ref_min=8.5;
options.ref_max=11.5;
options.sim_cov=[9;11];
run_simulation_nncs(options,model_name)

%% 10. Data matching (analysis w/ training data)
if options.plotting_sim
    plot_coverage_boxes(options,1);
end
warning('This code only works for coverage')
if options.reference_type~=3
    error('It is not possible to perform data matching');
end
options.testing.plotting=0;

options.testing.train_data=0;% 0: for centers, 1: random points
[testing,options]=test_coverage(options,model_name);


% The average MSE error over 49 simulations is 0.00031.

% The maximum MSE error over 49 simulations is 0.00207.
%% 11. Falsification with Breach

clear Data_all data_cex Br falsif_pb net_all phi_1 phi_3 phi_all;

 %%% ------------------------------------------ %%
 %%% ----- 11-A: Falsification with Breach ---- %%
 %%% ------------------------------------------ %%

options.testing_breach=1;
training_options.combining_old_and_cex=1; % 1: combine old and cex
falsif.iterations_max=1;
falsif.method='quasi';
falsif.num_samples=25;
falsif.num_corners=25;
falsif.max_obj_eval=20;
falsif.max_obj_eval_local=20;
falsif.seed=100;
falsif.num_inputs=1;

falsif.property_file='specs_watertank.stl';
falsif.property_all=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{2};%// TO-DO automatically specify the file
falsif.property_cex=falsif.property_all{3};
falsif.breach_ref_min=8;
falsif.breach_ref_max=12;
falsif.stop_at_false=false;
falsif.T=options.T_train;
falsif.input_template='fixed';
try
    falsif.breach_segments=options.breach_segments;
catch
    falsif.breach_segments=2;
end
stop=0;
i_f=1;
file_name=strcat(options.SLX_NN_model,'_cex');
options.input_choice=4;
net_all{1}=net;
seeds_all=falsif.seed*(1:falsif.iterations_max);
while i_f<=falsif.iterations_max && ~stop
    fprintf('\n Iteration %i.\n',i_f)
%     if i_f>1
%         fprintf('\n Testing the NN on the training data')
%         [data_cex,falsif_pb]= falsification_breach(options,falsif,model_name);
%         fprintf('The number of CEX is now %i.\n',length(falsif_pb.obj_false));
%     end
    fprintf('\n Beginning falsification with Breach.\n')
    fprintf('\n We use the model %s for falsification.\n',options.SLX_NN_model);
    if i_f==1
        model_name=options.SLX_NN_model;
    else
        disp('Use model with cex -- currently overwrite the same model. Todo: Add duplicates')
        model_name=file_name;
    end
    falsif.seed=seeds_all(i_f);
    falsif.iteration=i_f; % choose property
    [data_cex,falsif_pb]= falsification_breach(options,falsif,model_name);
    fprintf('The number of CEX is now %i.\n',length(falsif_pb.obj_false));

    fprintf('\n End falsification with Breach.\n')
    
    if any(structfun(@isempty,data_cex))
        fprintf('\n Breach could not falsify the STL formula.\n')
        fprintf('\n Trying with a different method (GNN) and more objective evaluations.\n')
        falsif.method='GNM';
%         falsif.max_obj_eval=falsif.max_obj_eval*2;
        [data_cex,falsif_pb]= falsification_breach(options,falsif,model_name);        
        if any(structfun(@isempty,data_cex))
            stop=1;
             break;
        end
    end
%     [data_cex_cluster]=cluster_and_sample(data_cex,falsif_pb,options)

    %%% ------------------------------------ %%
    %%% ----- 11-B: Retraining with CEX ---- %%
    %%% ------------------------------------ %%
    
    if stop~=1
        for tm = [2 3 1] % or we choose the preference/order
           
            fprintf('\n Beginning retraining with cex.\n')
            training_options.retraining=1; % the structure of the NN remains the same.
            training_options.retraining_method=tm; %1: start from scratch with all data,
            % 2: keep old net and use all data,  3: keep old net and use only new data
            % 4: blend/mix old and new data,  5: weighted MSE
            training_options.loss='mse';
            training_options.error=1e-6;
            training_options.max_fail=10;
            % net.performParam.ratio=0.5;
            % Data_all contains the data from all cases (training, cex) and
            % iterations.
            if i_f==1
                Data_all{i_f,1}=data;
                Data_all{i_f,2}=data_cex;
            elseif i_f>1
                Data_all{i_f,1}=get_new_training_data( Data_all{i_f-1,1},Data_all{i_f-1,2},training_options);
                Data_all{i_f,2}=data_cex;
            end
            
            % [net_cex,data]=nn_retraining(net,data,training_options,options,[],data_cex);
            [net_all{i_f+1},~,tr]=nn_retraining(net_all{i_f},Data_all{i_f,1},training_options,options,[],Data_all{i_f,2});
            if tr.best_perf <= training_options.error*100
                fprintf('\n Desired MSE value reached.\n')
                break;
            end
            fprintf('\n End retraining with cex.\n')
        end
     %%% ------------------------------------------ %%
     %%% ------ 11-C: Simulink Construction  ------ %%
     %%% ------------------------------------------ %%

    fprintf('\n Beginning Simulink construction with cex.\n')
    [options]=create_NN_diagram(options,net_all{i_f+1})
%     block_name=strcat('NN_cex_',num2str(i_f));
    block_name=strcat('NN_cex_',num2str(1));

    construct_SLX_with_NN(options,file_name,block_name)
    fprintf('\n End Simulink construction with cex.\n')

    %%% ----------------------------------------------- %%
    %%% ------ 11-D: Testing if CEX disappeared   ----- %%
    %%% ----------------------------------------------- %%

    fprintf('\n Testing the NN on the training data.\n')
    fprintf('The number of original CEX was %i.\n',length(falsif_pb.obj_false));
    
    robustness_checks=check_cex_elimination(falsif_pb,falsif,data_cex,file_name);
%     fprintf(' \n The original robustness values were %s.\n',num2str(robustness_checks{1}));
    fprintf(' \n The new robustness values are %s.\n',num2str(robustness_checks));

    end
    fprintf('\n End of Iteration %i.\n',i_f)
    if i_f<falsif.iterations_max
        i_f=i_f+1;
    else
        fprintf('\n\n------------\n\n');
        fprintf('Reached maximum number of iterations.\n');
        break;
    end
    
end

%% 11. Evaluating retrained SLX model

model_name=[];
model_name='watertank_inport_NN_cex';
options.input_choice=3;
options.sim_ref=8;
options.ref_min=8.5;
options.ref_max=11.5;
options.sim_cov=[12;8];   
options.sim_cov=[10.6830;8.7123];

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
% fig_open
%% 10. Evaluate Simulink NN
% same results with 7
 compare_NN_vs_nominal(data,options);
%}
