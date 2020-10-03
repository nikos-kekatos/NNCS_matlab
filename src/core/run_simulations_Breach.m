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
else
    var_names_list={};
end
Br = BreachSimulinkSystem(options.SLX_model,'all',[],var_names_list);
warning('Only works for 1D systems')

% Test with constant
if strcmp(options.SLX_model,'watertank_inport')|| strcmp(options.SLX_model,'watertank_inport_NN')
    Br.SetParam('In1_u0',11);
else
    if options.debug
        disp('For each model, we should replace the default value for testing')
    end
end

if options.input_choice~=4
    options.input_choice=4;
    warning('Changed the input choice')
    % Need to use the function as a standalone // FIX
end
% assert(options.input_choice,'4')
if options.debug
    Br.Sim();
    figure;Br.PlotSignals();
    Br.PrintAll()
end

% sim_time = 20
sim_time=options.T_train;
invalmin = options.breach_ref_min;
invalmax = options.breach_ref_max;

Br.SetTime(sim_time);

% First, plot coverage measures for the case where we don't snap to grid
Br_sys = Br.copy();
try
    nbinputsig=numel(invalmin);
catch
    if options.model==5
        nbinputsig = 3
    else
        nbinputsig = 1
    end
end
nbctrpt = options.breach_segments;

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
Br_sys.SetInputGen(BreachSignalGen({Br_input_gen}));

eps_time = (sim_time/nbctrpt)*0.4;
eps_time = (sim_time/nbctrpt);

input_param = {};
input_range = [];
for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        input_range = [input_range; invalmin(ii) invalmax(ii)];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
            input_range = [input_range; (jj+1)*sim_time/nbctrpt  ((jj+1)*sim_time/nbctrpt + eps_time*0) ];
        end
    end
    
    input_param;
    input_range;
    
end
Br_sys.SetParamRanges(input_param, input_range);
Br_sys.QuasiRandomSample(options.no_traces);
figure; Br_sys.PlotParams();
set(gca,'View', [45 45]);
figure;Br_sys.PlotDomain();

Br_sys.Sim();
figure; Br_sys.PlotSignals();

% We need to get values and save them as a data structure

try
    no_REF=size(data.REF,2);
    no_U=size(data.U,2);
    no_Y=size(data.Y,2);
catch
    no_REF=nbinputsig;
    try
        no_U=options.num_U;
        no_Y=options.num_Y;
    catch
        try
            param_id=[];
            all_param=Br_sys.P.ParamList;
            for ip=1:length(all_param)
                param_id_temp=regexp(all_param{ip},"In");
                if isempty(param_id_temp)
                    param_id_temp=0;
                end
                param_id=[param_id,param_id_temp];
            end
            param_no_In=all_param(not(param_id));
            for ipp=1:numel(param_no_In)
                temp_u(ipp)=~isempty(regexp(param_no_In{ipp},"u"));
            end
            param_u=param_no_In(logical(temp_u));
            for ipp=1:numel(param_no_In)
                temp_y(ipp)=~isempty(regexp(param_no_In{ipp},"y"));
            end
            param_y=param_no_In(logical(temp_y));
            no_U=length(param_u);
            no_Y=length(param_y);
        catch
            no_REF=1;
            no_U=1;
            no_Y=1;
        end
    end
end

index_REF=[];
index_U=[];
index_Y=[];
% to be used for systems with more variables
for i=1:no_REF
    ref_name=strcat('In',num2str(i));
    index_REF=[index_REF;find(strcmp(Br_sys.P.ParamList,ref_name))];
end
for i=1:no_U
    u_name=strcat('u_',num2str(i),'_');
    index_U=[index_U;find(strcmp(Br_sys.P.ParamList,u_name))];
end
for i=1:no_Y
    y_name=strcat('y_',num2str(i),'_');
    index_Y=[index_Y;find(strcmp(Br_sys.P.ParamList,y_name))];
end

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

