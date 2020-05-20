function [data_cex,falsif_pb] = falsification_breach(options,falsif,model_name)
%falsification_breach We start with an STL property and aim to falsify it
%with Breach.
%   The STL property is written in the `specs` file. First, we need to call 
%   the `stl` file and create a Breach requirement and a corresponding 
%   Breach system. Then, we have to interface the entire Simulink model 
%   with Breach. Note that we work on a different model now. We use
%   `SLX_model` for getting training data and `SLX_NN_model for testing and
%   falsification. So, we need to interface Breach, choose the parameters,
%   the variables, define the input stimulus (template), choose a sampling
%   method, the number of traces and the falsification method. Once, we
%   finish with simulating, we need to find out which are the traces with
%   the worst robustness and choose them for use in the retraining loop.

options.input_choice=4;
if strcmp(model_name,'watertank_inport')|| strcmp(model_name,'watertank_inport_NN')|| strcmp(model_name,'watertank_inport_NN_cex')
    var_names_list={'In1','u','y','u_nn','y_nn'};
    %     no_REF=1;
    %     no_U=1;
    %     no_Y=1;
end
Br_falsif = BreachSimulinkSystem(model_name,'all',[],var_names_list);
warning('Only works for 1D systems')

% Test with constant
if strcmp(model_name,'watertank_inport')|| strcmp(model_name,'watertank_inport_NN')
    Br_falsif.SetParam('In1_u0',11);
else
    disp('For each model, we should replace the default value for testing')
end
Br_falsif.Sim();
figure;Br_falsif.PlotSignals();
Br_falsif.PrintAll();


% sim_time = 20
sim_time=falsif.T;
invalmin = falsif.breach_ref_min;
invalmax = falsif.breach_ref_max;
Br_falsif.SetTime(sim_time);

% First, plot coverage measures for the case where we don't snap to grid
nbinputsig = 1
nbctrpt = falsif.breach_segments;

input_str = {};
input_cp = [];
input_intp = {};
for ii = 1:nbinputsig %only one input
    input_str{end+1} = ['In' num2str(ii)];
    input_cp = [input_cp nbctrpt];
    input_intp{end+1} = 'previous';
end
% Helicopter_input_gen = fixed_cp_signal_gen(input_str, input_cp, input_intp);
Br_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Br_falsif.SetInputGen(BreachSignalGen({Br_input_gen}));

% eps_time = (sim_time/nbctrpt)*0.4;
eps_time = (sim_time/nbctrpt);

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
% input_range(2,1)=0.1;
Br_falsif.SetParamRanges(input_param, input_range);

% phi = STL_Formula('phi', ' alw_[0,10] In1(t)<10')
phi_all=STL_ReadFile(falsif.property_file);
phi_1=phi_all{1};
R = BreachRequirement(phi_1);
falsif_pb = FalsificationProblem(Br_falsif, R);

% method = 'quasi'
% method = input('Which method?');

switch falsif.method
    case 'corners'
        %% Try corners
        falsif_pb.max_obj_eval = falsif.max_obj_eval;
        falsif_pb.solver_options.num_corners = falsif.num_corners; %50
        %falsif_pb.SetupDiskCaching();
        
    case 'rand'
        %% Try random
        falsif_pb.max_obj_eval = falsif.max_obj_eval;
        falsif_pb.setup_random('rand_seed',falsif.seed,'num_rand_samples',falsif.num_samples)
%         falsif_pb.StopAtFalse=true;
        
    case 'quasi'
        %% Try quasi-random
        falsif_pb.max_obj_eval = falsif.max_obj_eval; % 1000
        falsif_pb.setup_random('rand_seed',falsif.seed,'num_rand_samples',falsif.num_samples) % 100
        
    case 'GNM'
        %% Try GNM
        falsif_pb.max_obj_eval = falsif.max_obj_eval;
        falsif_pb.setup_global_nelder_mead('num_corners',falsif.num_corners,...
            'num_quasi_rand_samples',falsif.num_samples, 'local_max_obj_eval',falsif.max_obj_eval_local) %0,  1000,100
        
end


falsif_pb.StopAtFalse=falsif.stop_at_false;
falsif_pb.solve();
Rlog = falsif_pb.GetLog();
figure;BreachSamplesPlot(Rlog);
figure;falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y'});
Br_False = falsif_pb.GetFalse(); % AFC_False contains the falsifying trace
try
    Br_False.PlotSignals({'In1','y','y_nn'});
end

% we need to find out which traces violate the STL property

% if the objective is negative the property is not satisfied
falsif_idx=find(falsif_pb.obj_log<0);

fprintf('\n The number of cex is %i.\n',length(falsif_idx));

% falsif_idx=[5, 13, 24,41,77]

cex=falsif_pb.BrSet_Logged;
cex_traces=cex.P.traj;
no_cex_1=falsif_pb.nb_obj_eval
no_cex_2=length(cex_traces)
no_cex_3=length(cex.P.traj_ref)
isequal(no_cex_1,no_cex_2,no_cex_3)

fprintf('The total number of traces is %i.\n\n',no_cex_2);
fprintf('Each trace includes 1 control output(s), 1 state variable(s) and 1 reference(s).\n')
% In1 is sufficient for the input/reference. We can ignore the rest,
% {'In1_u0'}, {'In1_dt0'}, {'In1_u1'}, {'In1_dt1'}, {'In1_u2'}

fprintf(' Using `cex.P.ParamList` gives the list of parameters and the order.\n')


% need to have variables for no_ref, no_u, no_y. Probably add them in the
% options.

try
    no_REF=size(data.REF,2);
    no_U=size(data.U,2);
    no_Y=size(data.Y,2);
catch
    no_REF=1;
    no_U=1;
    no_Y=1;
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
    if no_U>1
        u_name=strcat('u_',num2str(i),'_'); 
    elseif no_U==1
        u_name='u';
    end
    index_U=[index_U;find(strcmp(cex.P.ParamList,u_name))];
end
for i=1:no_Y
    if no_Y>1
        y_name=strcat('y_',num2str(i),'_');
    elseif no_Y==1
        y_name='y';
    end
    index_Y=[index_Y;find(strcmp(cex.P.ParamList,y_name))];
end
for i=1:no_U
    if no_U>1        
        u_nn_name=strcat('u_nn_',num2str(i),'_');
    elseif no_U==1
        u_nn_name='u_nn';
    end
    index_U_NN=[index_U_NN;find(strcmp(cex.P.ParamList,u_nn_name))];
end
for i=1:no_Y
    if no_Y>1
        y_nn_name=strcat('y_nn_',num2str(i),'_');
    elseif no_Y==1
        y_nn_name='y_nn';
    end
    index_Y_NN=[index_Y_NN;find(strcmp(cex.P.ParamList,y_nn_name))];
end
REF_cex_breach_all=[];
U_cex_breach_all=[];
Y_cex_breach_all=[];
U_NN_cex_breach_all=[];
Y_NN_cex_breach_all=[];

% for i=1:length(cex_traces) not correct as all traces might be logged
for i=falsif_idx
    REF_cex_breach_all=[REF_cex_breach_all,cex.P.traj{i}.X(index_REF,:)];
    U_cex_breach_all=[U_cex_breach_all,cex.P.traj{i}.X(index_U,:)];
    Y_cex_breach_all=[Y_cex_breach_all,cex.P.traj{i}.X(index_Y,:)];
    U_NN_cex_breach_all=[U_NN_cex_breach_all,cex.P.traj{i}.X(index_U_NN,:)];
    Y_NN_cex_breach_all=[Y_NN_cex_breach_all,cex.P.traj{i}.X(index_Y_NN,:)];
end


%{
% For generation/training
for ix=1:options.no_traces
    REF_breach=[REF_breach,Br_sys.P.traj{ix}.X(index_REF,:)];
    U_breach=[U_breach,Br_sys.P.traj{ix}.X(index_U,:)];
    Y_breach=[Y_breach,Br_sys.P.traj{ix}.X(index_Y,:)];
end
%}
data_cex.REF=REF_cex_breach_all';
data_cex.U=U_cex_breach_all';
data_cex.Y=Y_cex_breach_all';
data_cex.U_NN=U_NN_cex_breach_all';
data_cex.Y_NN=Y_NN_cex_breach_all';

end