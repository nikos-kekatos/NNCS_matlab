%% This script is written to evaluate how to write a stabilization control
%% objective in the presence of an input step change.
%
%
% Inputs: none
%
% Outputs: none
%
% Syntax/usage:
%     STL_stabilization_property
%
% Run:
%     Navigate to the testing/STL_stabilization folder and run this file.
%
%
% Written on 15, May 2020

%% Initialization (skip if you do not need it)

clear;close all; clc;

%% Simulink model

Simulink_model='watertank_STL_test';

% loading the model without opening it

load_system(Simulink_model);

% uncomment the following command if you want to open and see the Simulink
% model

% open_system

%% STL formula

STL_formula_file='specs_stabilization.stl';
phi_all=STL_ReadFile(STL_formula_file);
try
    phi=phi_all{3};
catch
    phi=phi_all{1};
end
%% Setting up Falsification Problem

% Creating  Breach System
var_names_list={'In1','u','y','u_nn','y_nn'};
Br_falsif = BreachSimulinkSystem(Simulink_model,'all',[],var_names_list);

% Setting up the Falsification Problem
sim_time = 10;
invalmin =8;
invalmax = 12;
Br_falsif.SetTime(sim_time);

nbinputsig = 1;
nbctrpt = 3;

input_str = {};
input_cp = [];
input_intp = {};
for ii = 1:nbinputsig %only one input
    input_str{end+1} = ['In' num2str(ii)];
    input_cp = [input_cp nbctrpt];
    input_intp{end+1} = 'previous';
end

Br_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Br_falsif.SetInputGen(BreachSignalGen({Br_input_gen}));

eps_time = (sim_time/nbctrpt);

% Defining the ranges
input_param = {};
input_range = [];
for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        input_range = [input_range; invalmin invalmax];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
            input_range = [input_range; (jj+1)*sim_time/nbctrpt  (jj+1)*sim_time/nbctrpt ];
        end
    end
    
    input_param
    input_range
    
end
Br_falsif.SetParamRanges(input_param, input_range);
R = BreachRequirement(phi);
falsif_pb = FalsificationProblem(Br_falsif, R);


%% Try quasi-random

choice='quasi';
falsif_pb.max_obj_eval = 10; % 1000

if strcmp(choice,'GNN')
    falsif_pb.setup_global_nelder_mead('num_corners',5,...
            'num_quasi_rand_samples',15, 'local_max_obj_eval',100) %0,  1000,100
elseif strcmp(choice,'quasi')
    falsif_pb.setup_random('rand_seed',100,'num_rand_samples',25) % 100
end

falsif_pb.StopAtFalse=false;
falsif_pb.solve();

%% Plotting

Rlog = falsif_pb.GetLog();
BreachSamplesPlot(Rlog);
figure;falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y'});
Br_False = falsif_pb.GetFalse(); 
try
    Br_False.PlotSignals({'In1','y','y_nn'});
    figure;Br_False.PlotRobustSat(phi)
end
%% Evaluation
figure;falsif_pb.BrSet_Logged.PlotRobustSat(phi)
falsif_pb.BrSet_Logged.CheckSpec(phi)
