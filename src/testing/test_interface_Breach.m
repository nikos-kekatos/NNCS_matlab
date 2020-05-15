%% Interface with Breach

%% initialize
clear;clc; 
InitBreach;
%% use BreachSimulinkSystem 

SLX_model = 'mrefrobotarm_cover_test_3_ports';
SLX_model='quad_1_ref_ports';
%%
% Next, we define the parameters needed to run the model in the workspace.
% These parameters will be detected by Breach, and included in its 
% interface with the system. 

% I think that we do not need to define anything else
% if not loaded, run $configuration.m
% options.reference_type=4
% run('configuration_1.m')

%% Interfacing Signals
% By default, Breach collects the following signals:
%
% * Signals attached to input ports 
% * Signals attached to output ports
% * Logged signals 
% 

% Note: we use inports and outports. The output variables could be defined
% by the signal names. It is better to have y, y_nn, etc. instead of Out1
% Out2... Only works if we add workspace blocks. 
% Update: it is sufficient to adjust the block name.

%
% By default, Breach will look for inputs, outputs and logged signals. 
% Breach interface will then allow to change parameters and constant 
% input signals, simulate the model and collect and observe the resulting 
% trace.

%% Quadcopter if not saved
options.T_train=10;
options.simin_x0=zeros(1,12);
%%
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


%% 
% New model saved $SLX_mode _breach
% in BReach folder/Ext/ModelData
open(SLX_model);
open(strcat(SLX_model,'_breach'));
%%
% We set the default simulation time:
Br.SetTime(0:.01:10);

%%
% Print signals and parameters of the resulting interface:
Br.PrintAll();

%%
% Simulate the system.
Br.Sim();

% We plot the nominal trace using PlotSignals:
figure;Br.PlotSignals({'In1','y_3_','u_1_'});


%% Thao's code

sim_time = 20
invalmin = 7
invalmax = 12

% mdl = 'helicopter_NN_ports1';
% Helicopter_base = BreachSimulinkSystem(mdl);
Br.SetTime(sim_time);

% First, plot coverage measures for the case where we don't snap to grid
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
phi = STL_Formula('phi', ' alw_[0,10] In1(t)<10') 

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
    falsif_pb.max_obj_eval = 100; 
    falsif_pb.setup_random('rand_seed',100,'num_rand_samples',10)
    
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
% falsif_pb.BrSet_Logged.PlotSignals({'In1', 'y', 'y_nn'});


%% constant reference
Br.SetParam('In1_u0', 1);

% Simulate the system.
Br.Sim();

% We plot the nominal trace using PlotSignals:
figure;Br.PlotSignals({'In1','y_3_','u_1_'});
figure;Br.PlotSignals({'In1'});

%% 
Br_VarStep = Br.copy();                % Creates a copy of the system interface 
input_gen.type = 'VarStep';                % uniform time steps 
input_gen.cp = [3 ];                      % number of control points
% input_gen.method = {'previous', 'linear'};  % interpolation methods - see help of interp1.
input_gen.method = {'previous'};  % interpolation methods - see help of interp1.

Br_VarStep.SetInputGen(input_gen); 

% This creates a new input parameterization:
Br_VarStep.PrintParams();
%
%%% Changing Input Functions
% We set values for the control points and plot the result. The 
% semantics is input_ui holds for input_dti seconds 
Br_VarStep.SetParam({'In1_u0','In1_dt0','In1_u1', 'In1_dt1', 'In1_u2'},...
                     [ 1 5 2 6 1]);
Br_VarStep.Sim(0:.05:20);
figure; Br_VarStep.PlotSignals({'In1','y_3_','u_1_'});





%% Constant References

%%% We set the default value for the (constant) input signal: 
Br.SetParam('ref_u0', 0.4);
Br.PrintAll

% Simulate the system.
Br.Sim();

% result is saved at Br.P

%%% Simulate with user defined function (explicit or stored)
time_u = 0:.1:30;
ref_test = 0.5*cos(time_u) + 0.01;
U = [time_u' ref_test'];  % order matters!
   
Br.Sim(0:.05:30,U); 

%% 
% We plot the nominal trace using PlotSignals:
figure;Br.PlotSignals('In1','y_3_','u_1_');

% equivalent to SplotVar(Br.P)
figure;SplotTraj(Br.P);

% to get all signals
Br.GetAllSignalsList
figure;Br.PlotSignals('u')
figure;Br.PlotSignals({'u','u_nn'})


%% PWC references

% To interact with the system we can also use parameterized input generators. For
% instance, parameters can represent control points, and the input generated by 
% some interpolation between these points.

input_gen.type = 'UniStep';   % uniform time steps 
input_gen.cp = 3;             % number of control points
Br.SetInputGen(input_gen); 

%%%
% This created a signal generator parameterized with 3 control points for
% each input. The corresponding parameters have been added to the
% interface:

Br.PrintParams();

Br.SetParam({'ref_u0','ref_u1','ref_u2'}, [ 0.5 0.1 -0.3]);
Br.Sim(0:.05:40);
figure; Br.PlotSignals();

%% PWC -- Variable Steps Input Generation
% We can have variable step inputs and also different numbers of control 
% points and interpolation methods.

Br_VarStep = Br.copy();                % Creates a copy of the system interface 
input_gen.type = 'VarStep';                % uniform time steps 
input_gen.cp = [3 ];                      % number of control points
% input_gen.method = {'previous', 'linear'};  % interpolation methods - see help of interp1.
input_gen.method = {'previous'};  % interpolation methods - see help of interp1.

Br_VarStep.SetInputGen(input_gen); 

% This creates a new input parameterization:
Br_VarStep.PrintParams();
%
%%% Changing Input Functions
% We set values for the control points and plot the result. The 
% semantics is input_ui holds for input_dti seconds 
Br_VarStep.SetParam({'ref_u0','ref_dt0','ref_u1', 'ref_dt1', 'ref_u2'},...
                     [ 0.1 5 0.5 3 -0.5]);
Br_VarStep.Sim(0:.05:40);
figure; Br_VarStep.PlotSignals();


%%% Mixing Signal Generators for Inputs (1)

ref_gen = pulse_signal_gen({'ref'}); % Generate a pulse signal for pedal angle
ref_gen_alt      = fixed_cp_signal_gen({'ref'}, ... % signal name
                                       3,...                % number of control points
                                      {'spline'});        % interpolation method 
        
%
% Several signal generators can be glued together in a special Breach System: 

% InputGen = BreachSignalGen({ref_gen, ref_gen_alt});
InputGen = BreachSignalGen({ref_gen});
InputGen_alt = BreachSignalGen({ref_gen_alt});

% InputGen is a Breach System in its own right. Meaning we can change
% parameters, plot signals, etc, independantly from a Simulink model
InputGen_alt.SetParam({'ref_u0','ref_u1','ref_u2'},...
                        [0.5 -0.3 0.2]);
InputGen.SetParam({'ref_base_value', 'ref_pulse_period', ...
                         'ref_pulse_amp','ref_pulse_width','ref_pulse_delay'}, ... 
                         [0 15 0.5 .5 10]);
InputGen.PrintParams();

% We can attach InputGen to the Simulink model and simulate as follows.

Br.SetInputGen(InputGen_alt);
Br.Sim(0:.05:40);
figure; Br.PlotSignals();

Br.SetInputGen(InputGen);
Br.Sim(0:.05:40);
figure; Br.PlotSignals();


%
% Also we don't need to specify fixed time steps, e.g., the following will
% work too:
Br.Sim([0 1 5 10 20 21 30]); % Run Simulink simulation from time 0 to time 30 
                                   % and collect outputs at times 0, 1, 5, etc 

%
% Finally, we can set a default time to run simulations:
Br_Time.SetTime(0:.1:40);

%% Multiple Simulations

%% BreachSets
% Each BreachSystem is also a BreachSet object, i.e., a collection of
% parameter values and traces. Some basic operations are available to
% generate new values, such as grid sampling and quasi-random sampling
% which we demonstrate next. 

% We first need to set the ranges of parameters that we want to vary.
Br_Grid= Br.copy(); 
Br_Grid.SetParamRanges({'ref_pulse_period', 'ref_pulse_amp'},...
                        [10 15; 0 0.5]);
Br_Grid.SetParamRanges({'ref_pulse_period'},...
                        [10 15]);
                            
% Next we creates a 5x5 grid sampling and plot it.
Br_Grid.GridSample([2 ]);  
figure;
Br_Grid.PlotDomain();
Br_Grid.PlotParams();  

Br_Grid.Sim(0:.05:30);         
figure; Br_Grid.PlotSignals('u'); 

%%
Br_Rand= Br.copy(); 
Br_Rand.SetParamRanges({'ref_pulse_period', 'ref_pulse_amp'},...
                        [10 15; 0 0.5]);
% Next we creates a random sampling with 50 samples and plot it.
Br_Rand.QuasiRandomSample(50);  
figure; Br_Rand.PlotParams();  
set(gca,'View', [45 45]);  

Br_Rand.Sim(0:.05:30);         
figure; Br_Rand.PlotSignals({'ref','Engine_Speed','AF'}); % we plot only the input signals and AF


%% Parameter synthesis
% In the following, we analyse how fast $\dot{\theta}$ converges toward 
% the input $\psi$ by using the parameter synthesis algorithm on a PSTL 
% formula. 

%% 
% The following loads the PSTL property phi in the workspace.
STL_ReadFile('specs.stl');

%%
% It's defined as: 
% param tau = 5 
% phi :=  ev_[0,tau] ( abs(theta_dot[t]-psi[t]) < 0.01 ) 
%
% We can check if it is satisfied and plot the satisfaction functions,
% Boolean and quantitative 
Br.CheckSpec(phi) 
figure;Br.PlotRobustSat(phi)


%% 
% We define the options for the parameter synthesis algorithm. The algorithm 
% works by performing a binary search over the possible values of the
% parameter until finding the smallest value for which phi is satisfied.
prop_params.names = {'tau'};
prop_params.ranges = [0 10];  

synth_pb = ParamSynthProblem(Br, phi, prop_params.names, prop_params.ranges); 
synth_pb.solve();

%%
% The value computed by solving the synthesis problem is store in x_best:
tau_tight = synth_pb.x_best;

%% 
% We update the formula and plot its satisfaction:
phi_tight = set_params(phi, 'tau', tau_tight);
figure;Br.PlotRobustSat(phi_tight)

%% Falsification 
% Now we try to find a configuration of the system which will violate the 
% previous specification, satisfied by the nominal trajectory.

%% 
% We defines the system parameter name(s) and range(s).  Here, we consider
% that the parameter K can vary between 9 and 11.
falsif_params.names = {'a' ... ,
                      };
falsif_params.ranges = [0.9 1.1; ...
];

%% 
% We prepare a falsification problem.
falsif_pb = FalsificationProblem(Br, phi_tight, falsif_params.names, falsif_params.ranges);
falsif_pb.solve();

%%
% We plot the falsifying trajectory.  
BrFalse = falsif_pb.GetBrSet_False();
BrFalse.PlotRobustSat(phi_tight)


%% Mining  
% Next, we use the ReqMiningProblem routine to combine parameter synthesis and
% falsification until finding an STL formula that the falsifier cannot
% violate. 
mining_phi = ReqMiningProblem(Br,phi, falsif_params, prop_params);
mining_phi.solve();


%% Validation 
% The model analysed in this example is quite trivial, and we know that the
% longest time to converge toward the input is obtained by the smallest
% value for K. This is what the solver found in the first iteration: K=9.
% Note that in the second iteration, the solver didn't retry K=9. 




