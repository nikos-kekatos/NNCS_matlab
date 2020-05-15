function [data_breach] = run_simulations_Breach(options)
%run_simulations_Breach Calling Breach for generating simulation traces
%   We first need to create a Breach interface, then we define the
%   variables, we choose the settings, the input stimulus, we run
%   simulations, plot optionally and store the results as a structure.
% Br = BreachSimulinkSystem(options.SLX_model);

if strcmp(options.SLX_model,'watertank_inport')|| strcmp(options.SLX_model,'watertank_inport_NN')
    var_names_list={'In1','u','y'};
    %     no_REF=1;
    %     no_U=1;
    %     no_Y=1;
end
Br = BreachSimulinkSystem(options.SLX_model,'all',[],var_names_list);
warning('Only works for 1D systems')

% Test with constant
if strcmp(options.SLX_model,'watertank_inport')|| strcmp(options.SLX_model,'watertank_inport_NN')
    Br.SetParam('In1_u0',11);
else
    disp('For each model, we should replace the default value for testing')
end

if options.input_choice~=4
    options.input_choice=4;
    warning('Changed the input choice')
    % Need to use the function as a standalone // FIX
end
% assert(options.input_choice,'4')
Br.Sim();
figure;Br.PlotSignals();
Br.PrintAll()


% sim_time = 20
sim_time=options.T_train;
invalmin = options.breach_ref_min;
invalmax = options.breach_ref_max;

Br.SetTime(sim_time);

% First, plot coverage measures for the case where we don't snap to grid
Br_sys = Br.copy();
nbinputsig = 1
nbctrpt = options.breach_segments;

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
Br_sys.SetParamRanges(input_param, input_range);
Br_sys.QuasiRandomSample(options.no_traces);
figure; Br_sys.PlotParams();
set(gca,'View', [45 45]);
figure;Br_sys.PlotDomain();

Br_sys.Sim();
figure; Br_sys.PlotSignals();

% We need to get values and save them as a data structure

index_REF=find(strcmp(Br_sys.P.ParamList,'In1'));
index_U=find(strcmp(Br_sys.P.ParamList,'u'));
index_Y=find(strcmp(Br_sys.P.ParamList,'y'));
%{
% to be used for systems with more variables
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
%}
REF_breach=[];
U_breach=[];
Y_breach=[];

for ix=1:options.no_traces
    REF_breach=[REF_breach,Br_sys.P.traj{ix}.X(index_REF,:)];
    U_breach=[U_breach,Br_sys.P.traj{ix}.X(index_U,:)];
    Y_breach=[Y_breach,Br_sys.P.traj{ix}.X(index_Y,:)];
end
data_breach.REF=REF_breach';
data_breach.U=U_breach';
data_breach.Y=Y_breach';

