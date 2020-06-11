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
%  iii) Set of specification defined in STL
%
% Outputs:
%    i) Neural Network controller (saved as 'net' object),
%   ii) Simulink model with NN controller
%  iii) Simulation results and numerical values
%



%%------------- BEGIN CODE --------------

%% 0. Add files to MATLAB path

addpath(genpath('../../'))
InitBreach;
%% 1. Initialization
clear;close all;clc; bdclose all;
try
    delete(findall(0)); % close Simulink scopes
end
%% 2. Iput: specify Simulink model

SLX_model='robotarm_A2';
load_system(SLX_model)

% Uncomment next line if you want to open the model
% open(SLX_model)
%% 3. Input: specify configuration parameters

timer_trace_gen=tic;
run('config_robotarm_A2.m')

%% 4a. Run simulations -- Generate training data
[data,options]=trace_generation_nncs(SLX_model,options);
timer.trace_gen=toc(timer_trace_gen)
%% 4b. Load previous saved traces
options.load=0;
if options.load==1
    % specify dataset from outputs/ folder
    dataset{1}='array_sim_cov_varying_ref_81_traces_1x1_time_20_29-03-2020_07:33.mat';
    %     dataset{2}='array_sim_constant_ref_300_traces_30x10_time_60_11-02-2020_08:26.mat';
    [data,options]= load_data(dataset,options);
end
%% 5a. Data Selection
options.trimming=0;
options.keepData_factor=50;% we keep one out of every 5 data
options.deleteData_factor=0; % we delete one every 3 data points
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
timer_train=tic;
training_options.retraining=0;

training_options.use_error_dyn=0;
training_options.use_previous_u=2;
training_options.use_previous_ref=3;
training_options.use_previous_y=3;

training_options.neurons=[30 30];
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='wmse';
training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-5;
training_options.max_fail=50; % Validation performance has increased more than max_fail times since the last time it decreased (when using validation).
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm';%'trainlm'; % trainscg % trainrp
training_options.iter_max_fail=1;
iter=1;reached=0;
training_options.replace_by_zeros=0;
disp('====================================')
disp(' ')
disp('--- Options ---')
disp(' ')
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
% options.plotting_sim=0;% make it 1 to plot
plot_NN_sim(data,options);

%% 8a. Create Simulink block for NN

[options]=create_NN_diagram(options,net);

%% 8b. Integrate NN block in the Simulink model
construct_SLX_with_NN(options,options.SLX_model);

%% 9. Analyse NNCS in Simulink
model_name=[];
options.input_choice=3;

options.ref_Ts=5;
options.sim_ref=0.4;          % robotarm
options.ref_min=-0.5;
options.ref_max=0.5;
options.sim_cov=[0.3;0.1;-0.5;0.5];
options.u_index_plot=1;
options.y_index_plot=1;
options.ref_index_plot=1;

[ref,y,u]=run_simulation_nncs(options,model_name,0);
options.input_choice=4;
%% 10. Data matching (analysis w/ training data)

if options.reference_type~=3
    warning('It is not possible to perform data matching. Code works only for coverage.');
else
    if options.plotting_sim
        plot_coverage_boxes(options,1);
    end
    options.testing.plotting=0;
    options.testing.train_data=0;% 0: for centers, 1: random points
    if options.test_dataMatching
        [testing,options]=test_coverage(options,model_name);
    end
end

%% 11. Falsification with Breach

get_param(Simulink.allBlockDiagrams(),'Name')
bdclose all;
clear Data_all data_cex Br falsif_pb net_all phi_1 phi_3 phi_4  phi_5 phi_all
clear robustness_checks_all robustness_checks_false falsif falsif_pb_temp file_name
clear rob_nominal robustness_check_temp block_name falsif_idx data_cex
clear data_cex_cluster tr tr_all condition cluster_all check_nominal model_name
clear data_backup i_f ii In1_dt0 In1_u0 In1_u1 inputs_cex iter iter_best num_cex
clear reached seeds_all stop t__ tm training_perf tspan u__ idx_cluster falsif_pb_zero
clear timer

%%% ------------------------------------------ %%
%%% ----- 11-A: Falsification with Breach ---- %%
%%% ------------------------------------------ %%

options.testing_breach=1;
training_options.combining_old_and_cex=1; % 1: combine old and cex
falsif.iterations_max=3;
falsif.method='quasi';
falsif.num_samples=100;
falsif.num_corners=25;
falsif.max_obj_eval=100;
falsif.max_obj_eval_local=20;
falsif.seed=100;
falsif.num_inputs=1;

falsif.property_file=options.specs_file;
[~,falsif.property_all]=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{1};
falsif.property_cex=falsif.property_all{2};
falsif.property_nom=falsif.property_all{3};

falsif.breach_ref_min=-0.5;
falsif.breach_ref_max=0.5;

falsif.stop_at_false=false;
falsif.T=options.T_train;
falsif.input_template='fixed';
try
    falsif.breach_segments=options.breach_segments;
catch
    falsif.breach_segments=2;
    options.breach_segments=falsif.breach_segments;
end
stop=0;
i_f=1;

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
    check_nominal=1;
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
        options.input_choice=3;
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
%% 12a. Create a TXT file

txt_name=strcat('output_',options.SLX_model,'.txt');
fid = fopen(txt_name,'wt');
if (fid < 0)
    error('could not open file "%s"',txt_name);
end
fprintf(fid,'The number of cells per dimension equals %i.\n\n',options.coverage.no_cells_per_dim);
fprintf(fid,'The number of cells in total equals %i.\n\n',options.coverage.no_cells_total);
fprintf(fid,'The resolution of each cell is %i.\n\n',options.coverage.delta_resolution);
fprintf(fid,'The cell occupancy (coverage metric) is %i%%.\n\n',options.coverage.cell_occupancy*100);
fprintf(fid,'The time spent for trace generation is %.5f.\n\n',timer.trace_gen);
fprintf(fid,'The time spent for training is %.5f.\n\n\n\n',timer.train);
disp_property=display(falsif.property);
fprintf(fid,'The STL property for the NN is %s.\n\n',disp_property);
fprintf(fid,'The falsification/retraining loop was executed %i times.\n\n',i_f);
for ii=1:i_f
    fprintf(fid,'Iteration %i.\n\n',ii);
    fprintf(fid,'----------------------\n\n');
    fprintf(fid,' The falsification time was %.5f.\n\n',timer.falsif{ii});
    fprintf(fid, 'The nominal produces %i violating traces out of %i total traces.\n\n',numel(find(robustness_checks_all{ii,2}<0)),numel(robustness_checks_all{ii,2}));
    fprintf(fid, 'The NN produces %i violating traces out of %i total traces.\n\n',numel(find(robustness_checks_all{ii,1}<0)),numel(robustness_checks_all{ii,1}));
    if stop && ii==i_f % this means that both quasi and GNM falsification methods have been
        fprintf(fid, 'Before we used sampling-based method for falsification.\n\n');
        fprintf(fid, ' We searched again with optimizaton-based methods as shown below.\n\n');
        fprintf(fid, 'The nominal produces %i violating traces out of %i total traces.\n\n',numel(find(robustness_checks_all{ii,2}<0)),numel(robustness_checks_all{ii,2}));
        fprintf(fid, 'The NN produces %i violating traces out of %i total traces.\n\n',numel(find(robustness_checks_all{ii,1}<0)),numel(robustness_checks_all{ii,1}));
    end
    if numel(robustness_checks_false{ii,1})>0
        fprintf(fid, 'Using clustering, we keep %i counterexamples out of %i total.\n\n',numel(robustness_checks_false{ii,2}),numel(find(robustness_checks_all{ii,1}<0)));
    end
    try
        fprintf(fid,' The retraining time was %.5f.\n\n',timer.retrain{ii});
        fprintf(fid,' The re-checking time was %.5f.\n\n',timer.rechecking{ii});
        fprintf(fid,' Counterexamples: After clustering we had %i counterexamples and after retraining only %i remained.\n\n',numel(robustness_checks_false{ii,1}),numel(find(robustness_checks_false{ii,2}<0)));
        fprintf(fid,' Generalization test: Out of the %i traces, the new NN has %i.\n\n',numel(robustness_checks_all{ii,2}),numel(find(robustness_checks_all{ii,3}<0)));
    end
end
fclose(fid);

%fprintf(' \n The original CEX were %i, CEX after cluster, %i and with the new CEX are %i.\n',numel(find(robustness_checks_false{i_f,1}<0)),numel(idx_cluster),numel(find(robustness_checks_all{i_f,3}<0)));
%fprintf('\n We have %i CEX after clustering and after retraining we have %i.\n\n',numel(idx_cluster),numel(find(robustness_checks_false{i_f,2}<0)));
%% 12b. Check NN-cex on original training data

if options.test_dataMatching
    [original_rob,In_Original] = check_cex_all_data(Data_all,falsif,file_name,options);
    figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)
end
%% 12c. Evaluating retrained SLX model

model_name=[];
options.input_choice=3;

options.sim_ref=0.4;               % robotarm
options.ref_min=-0.4;
options.ref_max=0.3;
options.sim_cov=[0.3;0.1];

run_simulation_nncs(options,model_name,1) %3rd input is true for counterexamples
