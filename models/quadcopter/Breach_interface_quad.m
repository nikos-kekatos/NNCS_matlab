%% Interface with Breach

%% initialize
clear;clc;
InitBreach;
%% use BreachSimulinkSystem

SLX_model='quad_1_ref_ports';

% Quadcopter if not saved
% options.T_train=15;
% options.simin_x0=zeros(1,12);
%
%  We initialize the system interface with Breach. This creates an object
% called Br representing this interface. Note that Breach also creates
% its own copy of the Simulink model.
Br = BreachSimulinkSystem(SLX_model);

%{
% Sometimes a model contains many tunable parameters. In that case, we can
% explicitly specify those we want to tune, e.g., some PI parameters:

BrAFC_less_params = BreachSimulinkSystem(mdl, {'ki', 'kp'}, [0.14 0.04]);
BrAFC_less_params.PrintParams();


%%
% Similarly,we may want to have only a few signals among the ones logged
% to be visible:

BrAFC_less_signals = BreachSimulinkSystem(mdl, 'all', [], ... % 'all' means detects all visible paremeters
                                             {'Pedal_Angle','Engine_Speed', 'AF'});
BrAFC_less_signals.PrintAll;
%}

%
% New model saved $SLX_mode _breach
% in BReach folder/Ext/ModelData
% open(SLX_model);
% open(strcat(SLX_model,'_breach'));
%

%% Thao's code

sim_time = 15
invalmin = 0
invalmax = 3

Br.SetTime(sim_time);

Br_sys = Br.copy();
nbinputsig = 1
nbctrpt = 3

input_str = {};
input_cp = [];
input_intp = {};
for ii = 1:1 %only one input
    input_str{end+1} = ['In' num2str(ii)];
    input_cp = [input_cp nbctrpt];
    input_intp{end+1} = 'previous';
end
% Helicopter_input_gen = fixed_cp_signal_gen(input_str, input_cp, input_intp);
Br_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Br_sys.SetInputGen(BreachSignalGen({Br_input_gen}));

eps_time = (sim_time/nbctrpt)*0.4;

input_param = {};
input_range = [];
for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        input_range = [input_range; invalmin invalmax];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
            input_range = [input_range; jj*sim_time/nbctrpt  (jj*sim_time/nbctrpt + eps_time) ];
        end
    end
    
    input_param
    input_range
    
end


Br_sys.SetParamRanges(input_param, input_range);
% phi = STL_Formula('phi', ' alw_[0,10] In1(t)<10')
STL_ReadFile('specs.stl');

R = BreachRequirement(phi);
falsif_pb = FalsificationProblem(Br_sys, R);


method = 'quasi'
%method = input('Which method?');

switch method
    case 'corners'
        %% Try corners
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.solver_options.num_corners = 50;
        %falsif_pb.SetupDiskCaching();
        
    case 'rand'
        %% Try random
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.setup_random('rand_seed',100,'num_rand_samples',50)
        falsif_pb.StopAtFalse=true;
        
    case 'quasi'
        %% Try quasi-random
        falsif_pb.max_obj_eval = 100; % 1000
        falsif_pb.setup_random('rand_seed',100,'num_rand_samples',10) % 100
        
    case 'GNM'
        %% Try GNM
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.setup_global_nelder_mead('num_corners',0,...
            'num_quasi_rand_samples',1000, 'local_max_obj_eval',100)
        
end


falsif_pb.StopAtFalse=false;
falsif_pb.solve();
Rlog = falsif_pb.GetLog();
BreachSamplesPlot(Rlog);
falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y_3_'});
%%
fprintf('Note that `falsif_pb` is a falsification object.\n')
fprintf('However, the `falsif_pb.BrSet_Logged` is a Breach object')

cex=falsif_pb.BrSet_Logged;
cex_traces=cex.P.traj;
no_cex_1=falsif_pb.nb_obj_eval
no_cex_2=length(cex_traces)
no_cex_3=length(cex.P.traj_ref)
isequal(no_cex_1,no_cex_2,no_cex_3)

fprintf('The total number of traces is %i.\n\n',no_cex_2);
fprintf('Each trace includes 4 control outputs, 12 state variables and 1 reference.\n')
% In1 is sufficient for the input/reference. We can ignore the rest,
% {'In1_u0'}, {'In1_dt0'}, {'In1_u1'}, {'In1_dt1'}, {'In1_u2'}

fprintf(' Using `cex.P.ParamList` gives the list of parameters and the order.\n')

% need to have variables for no_ref, no_u, no_y. Probably add them in the
% options.

%otherwise
try
    no_REF=size(data.REF,2);
    no_U=size(data.U,2);
    no_Y=size(data.Y,2);
catch
    no_REF=1;
    no_U=4;
    no_Y=12;
end
%then we need to find indexes for REF
index_REF=[];
index_U=[];index_Y=[];
for i=1:no_REF
    ref_name=strcat('In',num2str(i));
    index_REF=[index_REF;find(strcmp(cex.P.ParamList,ref_name))];
end
for i=1:no_U
    u_name=strcat('u_',num2str(i),'_');
    index_U=[index_U;find(strcmp(cex.P.ParamList,u_name))];
end
for i=1:no_Y
    y_name=strcat('y_',num2str(i),'_');
    index_Y=[index_Y;find(strcmp(cex.P.ParamList,y_name))];
end
%{
for i=1:no_U
    u_nn_name=strcat('u_nn_',num2str(i),'_');
    index_U_nn=[index_U_nn;find(strcmp(cex.P.ParamList,u_nn_name))];
end
for i=1:no_Y
    y_nn_name=strcat('y_nn_',num2str(i),'_');
    index_Y_nn=[index_Y_nn;find(strcmp(cex.P.ParamList,y_nn_name))];
end
%}

REF_cex_breach_all=[];
U_cex_breach_all=[];
Y_cex_breach_all=[];
% U_cex_nn_breach_all=[];
% Y_cex_nn_breach_all=[];

for i=1:length(cex_traces)
    REF_cex_breach_all=[REF_cex_breach_all,cex.P.traj{i}.X(index_REF,:)];
    U_cex_breach_all=[U_cex_breach_all,cex.P.traj{i}.X(index_U,:)];
    Y_cex_breach_all=[Y_cex_breach_all,cex.P.traj{i}.X(index_Y,:)];
%     U_cex_nn_breach_all=[U_cex_nn_breach_all,cex.P.traj{i}.X(index_U_nn,:)];
%     Y_cex_nn_breach_all=[Y_cex_nn_breach_all,cex.P.traj{i}.X(index_Y_nn,:)];
end
data.REF_cex_breach=REF_cex_breach_all;
data.U_cex_breach=U_cex_breach_all;
data.Y_cex_breach=Y_cex_breach_all;
% data.U_cex_nn_breach=U_cex_nn_breach_all;
% data.Y_cex_nn_breach=Y_cex_nn_breach_all;
data.time_cex_breach=cex.P.traj{1}.time;

m=length(cex_traces);
if m>20
    m=20;
end
for i=1:m
    figure;plot(cex.P.traj{i}.time,cex.P.traj{i}.X(index_REF,:),'r--',cex.P.traj{i}.time,cex.P.traj{i}.X(index_Y(3),:),'b:');
    legend('reference','y')
    title(sprintf('Simulation -- trace no. %i', i));
end

%% Checking model with NN

SLX_model_NN='quad_1_ref_NN_ports';
warning off;
Br_NN = BreachSimulinkSystem(SLX_model_NN);
open(SLX_model_NN);
% open(strcat(SLX_model_NN,'_breach'));

Br_NN.PrintAll();


sim_time = 15
invalmin = 0
invalmax = 3

Br_NN.SetTime(sim_time);

Br_sys = Br_NN.copy();
nbinputsig = 1
nbctrpt = 3

input_str = {};
input_cp = [];
input_intp = {};
for ii = 1:1 %only one input
    input_str{end+1} = ['In' num2str(ii)];
    input_cp = [input_cp nbctrpt];
    input_intp{end+1} = 'previous';
end
% Helicopter_input_gen = fixed_cp_signal_gen(input_str, input_cp, input_intp);
Br_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Br_sys.SetInputGen(BreachSignalGen({Br_input_gen}));

eps_time = (sim_time/nbctrpt)*0.4;

input_param = {};
input_range = [];
for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        input_range = [input_range; invalmin invalmax];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
            input_range = [input_range; jj*sim_time/nbctrpt  (jj*sim_time/nbctrpt + eps_time) ];
        end
    end
    
    input_param
    input_range
    
end


Br_sys.SetParamRanges(input_param, input_range);
% phi = STL_Formula('phi', ' alw_[0,10] In1(t)<10')
STL_ReadFile('specs.stl');

R = BreachRequirement(phi_2);
falsif_pb = FalsificationProblem(Br_sys, R);


method = 'quasi'
%method = input('Which method?');

switch method
    case 'corners'
        %% Try corners
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.solver_options.num_corners = 50;
        %falsif_pb.SetupDiskCaching();
        
    case 'rand'
        %% Try random
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.setup_random('rand_seed',100,'num_rand_samples',50)
        falsif_pb.StopAtFalse=true;
        
    case 'quasi'
        %% Try quasi-random
        falsif_pb.max_obj_eval = 100; % 1000
        falsif_pb.setup_random('rand_seed',100,'num_rand_samples',20) % 100
        
    case 'GNM'
        %% Try GNM
        falsif_pb.max_obj_eval = 1000;
        falsif_pb.setup_global_nelder_mead('num_corners',0,...
            'num_quasi_rand_samples',1000, 'local_max_obj_eval',100)
        
end


falsif_pb.StopAtFalse=false;
falsif_pb.solve();
Rlog = falsif_pb.GetLog();
figure;BreachSamplesPlot(Rlog);
falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y_3_'});
Br_Sys_NN_False = falsif_pb.GetFalse(); % AFC_False contains the falsifying trace
try
Br_Sys_NN_False.PlotSignals({'In1','y_3_','y_nn_3_'});
end
%% we need to find out which traces violate the STL property

% if the objective is negative the property is not satisfied
falsif_idx=find(falsif_pb.obj_log<0);

fprintf('\n The number of cex is %i.\n',length(falsif_idx));

%%

cex=falsif_pb.BrSet_Logged;
cex_traces=cex.P.traj;
no_cex_1=falsif_pb.nb_obj_eval
no_cex_2=length(cex_traces)
no_cex_3=length(cex.P.traj_ref)
isequal(no_cex_1,no_cex_2,no_cex_3)

fprintf('The total number of traces is %i.\n\n',no_cex_2);
fprintf('Each trace includes 4 control outputs, 12 state variables and 1 reference.\n')
% In1 is sufficient for the input/reference. We can ignore the rest,
% {'In1_u0'}, {'In1_dt0'}, {'In1_u1'}, {'In1_dt1'}, {'In1_u2'}

fprintf(' Using `cex.P.ParamList` gives the list of parameters and the order.\n')

% need to have variables for no_ref, no_u, no_y. Probably add them in the
% options.

%otherwise
try
    no_REF=size(data.REF,2);
    no_U=size(data.U,2);
    no_Y=size(data.Y,2);
catch
    no_REF=1;
    no_U=4;
    no_Y=12;
end
%then we need to find indexes for REF
index_REF=[];
index_U=[];index_Y=[];
index_U_NN=[];index_Y_NN=[];

for i=1:no_REF
    ref_name=strcat('In',num2str(i));
    index_REF=[index_REF;find(strcmp(cex.P.ParamList,ref_name))];
end
for i=1:no_U
    u_name=strcat('u_',num2str(i),'_');
    index_U=[index_U;find(strcmp(cex.P.ParamList,u_name))];
end
for i=1:no_Y
    y_name=strcat('y_',num2str(i),'_');
    index_Y=[index_Y;find(strcmp(cex.P.ParamList,y_name))];
end
for i=1:no_U
    u_nn_name=strcat('u_nn_',num2str(i),'_');
    index_U_NN=[index_U_NN;find(strcmp(cex.P.ParamList,u_nn_name))];
end
for i=1:no_Y
    y_nn_name=strcat('y_nn_',num2str(i),'_');
    index_Y_NN=[index_Y_NN;find(strcmp(cex.P.ParamList,y_nn_name))];
end
REF_cex_breach_all=[];
U_cex_breach_all=[];
Y_cex_breach_all=[];
U_NN_cex_breach_all=[];
Y_NN_cex_breach_all=[];

% for i=1:length(cex_traces) not correct as all traces are logged
for i=falsif_idx
    REF_cex_breach_all=[REF_cex_breach_all,cex.P.traj{i}.X(index_REF,:)];
    U_cex_breach_all=[U_cex_breach_all,cex.P.traj{i}.X(index_U,:)];
    Y_cex_breach_all=[Y_cex_breach_all,cex.P.traj{i}.X(index_Y,:)];
    U_NN_cex_breach_all=[U_NN_cex_breach_all,cex.P.traj{i}.X(index_U_NN,:)];
    Y_NN_cex_breach_all=[Y_NN_cex_breach_all,cex.P.traj{i}.X(index_Y_NN,:)];
end
data2.REF_cex_breach=REF_cex_breach_all';
data2.U_cex_breach=U_cex_breach_all';
data2.Y_cex_breach=Y_cex_breach_all';
data2.U_NN_cex_breach=U_NN_cex_breach_all';
data2.Y_NN_cex_breach=Y_NN_cex_breach_all';
data2.time_cex_breach=cex.P.traj{1}.time;
data2.no_cex=length(falsif_idx);
data2.obj_log=falsif_pb.obj_log;
data2.falsif_idx=falsif_idx;
%% 
for i=falsif_idx
    figure;plot(cex.P.traj{i}.time,cex.P.traj{i}.X(index_REF,:),'r--',cex.P.traj{i}.time,cex.P.traj{i}.X(index_Y(3),:),'g:',cex.P.traj{i}.time,cex.P.traj{i}.X(index_Y_NN(3),:),'b-.','Linewidth',2);
    legend('reference','y_{nom}','y_{nn}')
    title(sprintf('Simulation -- trace no. %i', i));
    file_name=strcat('cex_',num2str(i),'.png');
%     saveas(gcf,file_name)
end

%% Print All traces

m=length(cex_traces);
if m>20
    m=20;
end
for i=1:m
    figure;plot(cex.P.traj{i}.time,cex.P.traj{i}.X(index_REF,:),'r--',cex.P.traj{i}.time,cex.P.traj{i}.X(index_Y(3),:),'g:',cex.P.traj{i}.time,cex.P.traj{i}.X(index_Y_NN(3),:),'b-.','Linewidth',2);
    legend('reference','y_{nom}','y_{nn}')
    title(sprintf('Simulation -- trace no. %i', i));
end

