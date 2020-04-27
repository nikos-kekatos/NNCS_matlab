
clear;

addpath('/Users/thaodang/Metaheuristics/breach-dev')

addpath('/Users/thaodang/Metaheuristics/src')
addpath('.')

addpath('/Users/thaodang/Metaheuristics/wordgen')
InitBreach('/Users/thaodang/Metaheuristics/breach-dev',true);


%%  Checking reachable labels
STL_ReadFile('specs.stl');

%% 
% init_helicopter;
options.dt = .01
sim_time = 4
invalmin = -5
invalmax = 5

mdl = 'helicopter_NN_ports1';
Helicopter_base = BreachSimulinkSystem(mdl);
Helicopter_base.SetTime(sim_time);

% First, plot coverage measures for the case where we don't snap to grid
Helicopter_sys = Helicopter_base.copy();
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
Helicopter_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Helicopter_sys.SetInputGen(BreachSignalGen({Helicopter_input_gen}));

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


Helicopter_sys.SetParamRanges(input_param, input_range);
%Helicopter_sys.SetupDiskCaching();


%% 
R = BreachRequirement(phi);
falsif_pb = FalsificationProblem(Helicopter_sys, R);
    

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
    falsif_pb = FalsificationProblem(Helicopter_sys, R);
    falsif_pb.max_obj_eval = 1000; 
    falsif_pb.setup_random('rand_seed',100,'num_rand_samples',50)
    
    case 'GNM'
    %% Try GNM
    falsif_pb.max_obj_eval = 1000;
    falsif_pb.setup_global_nelder_mead('num_corners',0,...
        'num_quasi_rand_samples',1000, 'local_max_obj_eval',100)
        
end


falsif_pb.StopAtFalse=true;
falsif_pb.solve(); 
Rlog = falsif_pb.GetLog();
BreachSamplesPlot(Rlog);
falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y', 'y_nn'});

%% Initial Counter-example
% BFalse = falsif_pb.BrSet_False;
% BFalse = falsif_pb.GetFalse();
% if (~isempty(BFalse))
%     BFalse.PlotSignals({'In1', 'y', 'y_nn'});
% end


%% Plotting Log
%Rpb= falsif_pb.GetLog();
%Fpb = BreachSamplesPlot(Rpb); 
%Fpb.set_y_axis('notphi');

