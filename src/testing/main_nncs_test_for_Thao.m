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
run('configuration_2.m')
%% 4a. Run simulations -- Generate training data

[data,options]=run_simulations_nncs(SLX_model,options);

%% 4b. Load previous saved traces
if options.load==1
    % specify dataset from outputs/ folder
    dataset{1}= 'array_sim_constant_ref_60_traces_15x4_time_20_18-02-2020_02:03';
    % dataset{2}='array_sim_constant_ref_300_traces_30x10_time_60_11-02-2020_08:26.mat';
    % dataset{3}='array_sim_constant_ref_100_traces_20x5_time_20_11-02-2020_11:50';
    [data,options]= load_data(dataset,options);
end
%% 5a. Data Selection (per Thao's suggestion)
options.trimming=1;
options.preprocessing_bool=0;

options.keepData_factor=5;% we keep one out of every 5 data

[data]=trim_data(data,options);
%% 5b. Data Preprocessing
display_ranges(data);
options.preprocessing_bool=0;
options.preprocessing_eps=0.0002;
if options.preprocessing_bool==1
    [data,options]=preprocessing(data,options);
end
%% 6. Train NN Controller
%the assignments could go a function/file
training_options.retraining=0;
training_options.use_error_dyn=0;
training_options.use_previous_u=1;      % default=2
training_options.use_previous_ref=1;    % default=3
training_options.use_previous_y=1;      % default=3
training_options.neurons=[8 20];%training_options.neurons=[30 30];
training_options.neurons=[50 ];
training_options.input_normalization=0;
training_options.loss='mse';
training_options.algo='trainlm'; % trainscg
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

% TEST with constant reference 0.1
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_Thao';
sim(model_name);


%{
% OLD trick
figure;
temp.ref_time=ref.time([1, end]);
temp.ref_time_new=temp.ref_time(1):options.dt:temp.ref_time(2);
temp.ref_time_new=temp.ref_time_new(1:end-1);
temp.ref_values=[];
% find set_points
str_block=get_param(strcat(model_name,'/Random Reference'),'SampleTime');
no_setpoints_sim=ref.time(end)/str2double(str_block);
no_setpoints_sim=max(1,no_setpoints_sim);
for i=1:no_setpoints_sim
    temp.ref_values=[temp.ref_values,repmat(ref.signals.values(i),[1,length(temp.ref_time_new)/no_setpoints_sim])];
end
figure;plot(temp.ref_time_new,temp.ref_values,'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
xlabel('time (s)')
ylabel('plant output')
legend('reference','nominal','NN')
title('Simulating NNCS both with PID and NN')
% plot([x(3); x(3)], ylim, '-r')      % Plot the vertical line in red

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(temp.ref_time_new,temp.ref_values,'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference','nominal','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');
%}
figure;plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
xlabel('time (s)')
ylabel('plant output')
legend('reference','nominal','NN')
title('Simulating NNCS both with PID and NN')
% plot([x(3); x(3)], ylim, '-r')      % Plot the vertical line in red

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference','nominal','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');
%}

%%
open('test_Thao_1_constant.fig')
open('test_Thao_1_net.mat')

%% Cex-1st option
% take the entire trajectory
data.REF_cex=ref.signals.values(1:end-1);
data.U_cex=u.signals.values(1:end-1);
data.Y_cex=y.signals.values(1:end-1);

data.REF_combined=[data.REF_trim;data.REF_cex]
data.U_combined=[data.U_trim;data.U_cex]
data.Y_combined=[data.Y_trim;data.Y_cex]

%% Cex - 2nd option
 figure;plot(ref.time,ref.signals.values,'--r',y.time,y.signals.values)
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
        
        end_point=200;       
data.REF_cex=ref.signals.values(1:end_point);
data.U_cex=u.signals.values(1:end_point);
data.Y_cex=y.signals.values(1:end_point);

data.REF_combined=[data.REF_trim;data.REF_cex]
data.U_combined=[data.U_trim;data.U_cex]
data.Y_combined=[data.Y_trim;data.Y_cex]

%% Retraining - 1st option 
training_options.retraining=1;
training_options.use_error_dyn=0;
training_options.use_previous_u=1;      % default=2
training_options.use_previous_ref=1;    % default=3
training_options.use_previous_y=1;      % default=3
training_options.neurons=[8 20];%training_options.neurons=[30 30];
training_options.neurons=[100 ];
training_options.input_normalization=0;
training_options.loss='mse';
training_options.algo='trainlm'; % trainscg
%add option for saved mat files
[net,data]=nn_training(data,training_options,options);

%% Plot new neural net

model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_Thao';
sim(model_name);
%%
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex.time,y_nn_cex.signals.values,'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
% legend('reference',' NN original','NN with cex','FontSize',14)
legend('reference',' NN with cex part','NN with cex','FontSize',14)

title('Simulating NNCS --  refined NN (part) vs refined NN (entire)','FontSize',18,'FontWeight','bold');

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex.time,y_nn_cex.signals.values,'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference', 'PID', 'NN original','NN with cex','FontSize',14)
title('Simulating NNCS -- PID vs original NN vs refined NN','FontSize',18,'FontWeight','bold');
%%
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ u(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(u.time(1:end-1),u.signals.values(1:end-1),'g--',u_NN.time,u_NN.signals.values,'b-.',u_NN_cex.time,u_NN_cex.signals.values,'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend( 'PID', 'NN original','NN with cex','FontSize',14)
title('Simulating NNCS -- PID vs original NN vs refined NN','FontSize',18,'FontWeight','bold');
%%
%% Cex-1st option
% take the entire trajectory
data.REF_cex_2=ref.signals.values(1:end-1);
data.U_cex_2=u.signals.values(1:end-1);
data.Y_cex_2=y.signals.values(1:end-1);

data.REF_combined_2=[data.REF_combined;data.REF_cex_2]
data.U_combined_2=[data.U_combined;data.U_cex_2]
data.Y_combined_2=[data.Y_combined;data.Y_cex_2]
