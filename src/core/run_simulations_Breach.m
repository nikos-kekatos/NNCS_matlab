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
% set_param(strcat(options.SLX_model,'_breach'),'FastRestart','on')

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
% attempts to store specific values, not enough
% Br_sys.SetTime(0:1:sim_time);
if isfield(options,'Breach_user_defined')
    input_gen      = fixed_cp_signal_gen({'In1','In2'}, ... % signal name
        4,...                % number of control points
        {'spline'});        % interpolation method
    InputGen = BreachSignalGen({input_gen});   
    InputGen.SetParamRanges(input_gen.params,...%input_param,...
        [0.22 0.26;  0.20 0.25; 0.2 0.23;0.28 0.3; 0 0.1; 0.020 0.075; 0.04 0.06; 0 0.1; 0 0.1]);
    InputGen.SetParamRanges(input_gen.params,...%input_param,...
        [repmat([options.breach_ref_min(1) options.breach_ref_max(1)],4,1);  repmat([options.breach_ref_min(2) options.breach_ref_max(2)],4,1) ]);
  
    InputGen.PrintParams();    
    Br_sys.SetInputGen(InputGen);
    Br_sys.QuasiRandomSample(options.no_traces);
%     Br_sys.CornerSample
else
    Br_sys.SetParamRanges(input_param, input_range);
    Br_sys.QuasiRandomSample(options.no_traces);
end
if options.trace_gen_via_sim
    figure; Br_sys.PlotParams();
    set(gca,'View', [45 45]);
    figure;Br_sys.PlotDomain();
    Br_sys.Sim();
    figure; Br_sys.PlotSignals();
else
    [~,property_all]=STL_ReadFile(options.specs_file);
    property=property_all{1};
    R = BreachRequirement(property);
    falsif_pb = FalsificationProblem(Br_sys, R);
    falsif_pb.max_obj_eval = options.no_traces; % 1000
    falsif_pb.setup_random('rand_seed',1,'num_rand_samples',options.no_traces); % 100
    falsif_pb.StopAtFalse=false;
    falsif_pb.solve();
    Rlog = falsif_pb.GetLog();
    Rlog.GetStatement
    figure;BreachSamplesPlot(Rlog);
    % num_constraints_evaluations returns 0
    % use num_traces_vi0lations:
    %fprintf('\nThere are %i violations out of %i traces.\n\n',falsif_pb.num_constraints_failed,falsif_pb.nb_obj_eval);
    fprintf('\nThere are %i violations out of %i traces.\n\n',Rlog.GetStatement.num_traces_violations,falsif_pb.nb_obj_eval);
    
end
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

if ~options.trace_gen_via_sim %falsification
    Br_sys=falsif_pb.BrSet_Logged;
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
    u_name=strcat('u_',num2str(i),'_'); % test with param_u
    index_U=[index_U;find(strcmp(Br_sys.P.ParamList,u_name))];
end
if isempty(index_U) % one dimension and var saved as "u"
    index_U=find(strcmp(Br_sys.P.ParamList,'u'))
end
for i=1:no_Y
    y_name=strcat('y_',num2str(i),'_'); % replace and test by param_y
    index_Y=[index_Y;find(strcmp(Br_sys.P.ParamList,y_name))];
end
if isempty(index_Y) % one dimension and var saved as "y"
    index_Y=find(strcmp(Br_sys.P.ParamList,'y'));
end
REF_breach=[];
U_breach=[];
Y_breach=[];

%delete last point of each trace/ it is common to have a step change at the
%very end of the time horizon. As such, there is an instantaneous step
%change which also causes large changes in the controller.
for ix=1:options.no_traces
    REF_breach=[REF_breach,Br_sys.P.traj{ix}.X(index_REF,1:(end-1))];
    U_breach=[U_breach,Br_sys.P.traj{ix}.X(index_U,1:(end-1))];
    Y_breach=[Y_breach,Br_sys.P.traj{ix}.X(index_Y,1:(end-1))];
end

% for ix=1:options.no_traces
%     REF_breach=[REF_breach,Br_sys.P.traj{ix}.X(index_REF,:)]; keep old
%     U_breach=[U_breach,Br_sys.P.traj{ix}.X(index_U,:)];
%     Y_breach=[Y_breach,Br_sys.P.traj{ix}.X(index_Y,:)];
% end

data_breach.REF=REF_breach';
data_breach.U=U_breach';
data_breach.Y=Y_breach';

