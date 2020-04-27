%% test retraining in a loop

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

SLX_model='quad_1_ref';
load_system(SLX_model)

%% 3. Input: specify configuration parameters

run('config_quad_1_ref.m')

%% 4a. Run simulations -- Generate training data
options.error_mean=0%0.0001;
options.error_sd=0%0.001;

[data,options]=run_simulations_nncs(SLX_model,options);
data_all=data;

%% Training options
training_options.use_error_dyn=0;
training_options.use_previous_u=0;      % default=2
training_options.use_previous_ref=0;    % default=3
training_options.use_previous_y=0;      % default=3
% training_options.neurons=[20 10 10];
training_options.neurons=[30 30];
% training_options.neurons=[50 ];
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='custom_v1';
% training_options.loss='wmse';
 training_options.div='dividerand';
% training_options.div='dividetrain';

training_options.algo= 'trainlm'%'trainlm'; % trainscg % trainrp
%add option for saved mat files

%% Split training data

% load('data_retraining.mat')
iterations=1;
clear data
no_points=length(data_all.REF);
tStart=tic;
for ii=1:iterations
    %  Train NN Controller
    fprintf('\n\n Iteration %i.\n\n',ii);

    if ii==1
        training_options.retraining=0;
        data.REF=data_all.REF(1:no_points/5,:);
        data.U=data_all.U(1:no_points/5,:);
        data.Y=data_all.Y(1:no_points/5,:);
        tic;
        [net,data_all]=nn_training(data_all,training_options,options);
        T_all=toc;
        T(ii)=toc;
    else
        data.REF_cex=data_all.REF(no_points/5*(ii-1)+1:no_points/5*(ii),:);
        data.Y_cex=data_all.Y(no_points/5*(ii-1)+1:no_points/5*(ii),:);
        data.U_cex=data_all.U(no_points/5*(ii-1)+1:no_points/5*(ii),:);

        options.testing_breach=2;
        training_options.retraining=1; % the structure of the NN remains the same.
        training_options.retraining_method=3; %1: start from scratch with all data,
        % 2: keep old net and use all data...
        % 3: keep old net and use only new data
        % 4: blend/mix old and new data
        % 5: add weighted function
        net.performFcn='msereg';
        % net.performParam.ratio=0.5;
        net.trainParam.goal=1e-5;
        net.trainParam.max_fail=8;
        tic;
        [net,data]=nn_retraining(net,data,training_options,options,[]);
        T(ii)=toc;
        data.REF=[data.REF;data.REF_cex];
        data.U=[data.U;data.U_cex];
        data.Y=[data.Y;data.Y_cex];
       
    end
end
t2=toc;
%% 7. Evaluate NN
plot_NN_sim(data,options)

%% 8. Create Simulink block for NN
gensim(net)

%% 9. Analyse NNCS in Simulink
% Currently, this part is done manually. The user has to copy the block
% created in the previous step with 'gensim' and insert it in the SLX_model
% with the NN.
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref';
% model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_pert';
% model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_pert_2';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_prepro';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_cover';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test_2';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test_3';
model_name='quad_1_ref_NN';
% model_name='helicopter_NN';
% model_name='quad_3_ref_NN';
% model_name='quad_3_ref_6_y_NN';
% % model_name='watertank_comp_design_mod_NN';

cc=-0.1;
% sim(model_name);
% options.testing.sim_cov=[12,11];
options.sim_cov=0;
options.sim_ref=2.93;
options.testing.ref_Ts=5;
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);
%{
figure;
temp.ref_time=ref.time([1, end]);
temp.ref_time_new=temp.ref_time(1):options.dt:temp.ref_time(2);
temp.ref_time_new=temp.ref_time_new(1:end-1);
temp.ref_values=[];
% find set_points
str_block=get_param('mrefrobotarm_modified_previous_y_previous_u_previous_ref/Random Reference','SampleTime');
no_setpoints_sim=ref.time(end)/str2double(str_block);
for i=1:no_setpoints_sim
    temp.ref_values=[temp.ref_values,repmat(ref.signals.values(i),[1,length(temp.ref_time_new)/no_setpoints_sim])];
end
figure;plot(temp.ref_time_new,temp.ref_values,'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
xlabel('time (s)')
ylabel('plant output')
legend('reference','nominal','NN')
title('Simulating NNCS both with PID and NN')
% plot([x(3); x(3)], ylim, '-r')      % Plot the vertical line in red
%}
% ref vs y
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time(1:end),y.signals.values(1:end),'g--',y_nn.time(1:end-1),y_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference','nominal','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');

% u_NN vs u_PID
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ u(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(u.time(1:end),[u.signals.values(1:end-1);u.signals.values(end-1)],'g--',u_nn.time(1:end-1),u_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('nominal-PID','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');

fprintf(' The nominal value is %.5f. \n\n',y.signals.values(end))

fprintf(' The NN value is %.5f. \n\n',y_nn.signals.values(end))

ss_abs=y_nn.signals.values(end)-y.signals.values(end);
fprintf(' The absolute ss error is %.5f. \n\n',ss_abs)
ss_rel=(y_nn.signals.values(end)-y.signals.values(end))/y.signals.values(end)*100;
fprintf(' The reltive ss error is %.5f (perc). \n\n',ss_rel)

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

save_traces_csv(testing,options);
%% Retraining
% we have already identified the counterexamples and here explore different
% options to do the retraining.
%now we just add one cex
index=[6 7 14 36 43];
options.testing_breach=1;
testing.errors_final_index=index;
training_options.retraining=1; % the structure of the NN remains the same.
training_options.retraining_method=4; %1: start from scratch with all data,
% 2: keep old net and use all data...
% 3: keep old net and use only new data
% 4: blend/mix old and new data
% 5: add weighted function
 net.performFcn='msereg'; 
% net.performParam.ratio=0.5;
net.trainParam.goal=1e-6;
net.trainParam.max_fail=50; 
[net_cex,data]=nn_retraining(net,data,training_options,options,testing);

%% Create Simulink block for NN
gensim(net_cex)

%% Plot new NN traces with cex
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cex_3';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cex_3b';
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

