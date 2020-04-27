%% Creating an interface with Breach using BreachSimulinkSystem 

%%
clear
% Name of the Simulink model:
mdl = 'helicopter_NN_ports';

%%
% Next, we define the parameters needed to run the model in the workspace.
% These parameters will be detected by Breach, and included in its 
% interface with the system. 
K = 10;
i = 0; 
a = 1;
options.dt=0.01;
%%
% By default, Breach will look for inputs, outputs and logged signals. 
% Breach interface will then allow to change parameters and constant 
% input signals, simulate the model and collect and observe the resulting 
% trace. 
Br = BreachSimulinkSystem(mdl);
open_system(strcat(mdl,'_breach'));
%%
% We set the default simulation time:
Br.SetTime(0:.01:4);

%%
% We set the default value for the (constant) input signal: 
Br.SetParam('psi_u0', 10);

%%
% Print signals and parameters of the resulting interface:
Br.PrintAll();

Br.GetDomainCfg
Br.GetInputParamList
Br.GetParamList
Br.GetPlantParamList
Br.GetSummary


%%
% Simulate the system.
Br.Sim();

%% 
% We plot the nominal trace using PlotSignals:
Br.PlotSignals();

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
Br_Spec=Br.copy();
Br_Spec.CheckSpec(phi_1) 
figure;Br_Spec.PlotRobustSat(phi_1)

Br_Spec.CheckSpec(phi_2) 
figure;Br_Spec.PlotRobustSat(phi_2)


%% 
% We define the options for the parameter synthesis algorithm. The algorithm 
% works by performing a binary search over the possible values of the
% parameter until finding the smallest value for which phi is satisfied.
%{
prop_params.names = {'tau'};
prop_params.ranges = [0 10];  

synth_pb_1 = ParamSynthProblem(Br, phi_1, prop_params.names, prop_params.ranges); 
a1=synth_pb_1.solve();

fprintf('The nominal controller produces the objective value: %.8f. \n',a1)


synth_pb_2 = ParamSynthProblem(Br, phi_2, prop_params.names, prop_params.ranges); 
a2=synth_pb_2.solve();

fprintf('The NN controller produces the objective value: %.8f. \n',a2)



%
% The value computed by solving the synthesis problem is store in x_best:
tau_tight_1 = synth_pb_1.x_best;

tau_tight_2 = synth_pb_2.x_best;

%% 
% We update the formula and plot its satisfaction:
phi_tight_1 = set_params(phi_1, 'tau', tau_tight_1);
figure;Br.PlotRobustSat(phi_tight_1)

% We update the formula and plot its satisfaction:
phi_tight_2 = set_params(phi_2, 'tau', tau_tight_2);
figure;Br.PlotRobustSat(phi_tight_2)

%}
%% Running multiple simulations

%% Parameters

Br_Grid=Br.copy()
Br_Grid.SetParamRanges({'psi_u0'},...
                        [7 12]);
              
Br_Grid.GridSample([5 ]);  
figure
Br_Grid.PlotParams();  
Br_Grid.Sim(0:.05:30);         
figure; Br_Grid.PlotSignals(); % we plot only the input signals and AF
Br_Quasi=Br.copy()
Br_Quasi.SetParamRanges({'psi_u0'},...
                        [7 12]);
              
Br_Quasi.QuasiRandomSample(5);  
figure; Br_Quasi.PlotParams();  
set(gca,'View', [45 45]);  
Br_Quasi.Sim(0:.05:30);         
figure; Br_Quasi.PlotSignals();

Br_Spec=Br_Grid.copy
Br_Spec.CheckSpec(phi_2) 
figure;Br_Spec.PlotRobustSat(phi_2)


%%
Br_VarStep = Br.copy();                % Creates a copy of the system interface 
input_gen.type = 'VarStep';                % uniform time steps 
input_gen.cp = [4 ];     % u0,u1,u2,u3                  % number of control points
% input_gen.method = {'previous', 'linear'};  % interpolation methods - see help of interp1.
input_gen.method = {'previous'};  % interpolation methods - see help of interp1.

Br_VarStep.SetInputGen(input_gen); 
% This creates a new input parameterization:
%
%%% Changing Input Functions
% We set values for the control points and plot the result. The 
% semantics is input_ui holds for input_dti seconds 
Br_VarStep.SetParam({'psi_u0','psi_dt0','psi_u1', 'psi_dt1', 'psi_u2','psi_dt2','psi_u3'},...
                     [ 10 5 9 3 12 10 0 ]);
Br_VarStep.Sim(0:.05:20);
figure; Br_VarStep.PlotSignals({});

Br_VarStep.SetParamRanges({'psi_u0'},...
                        [7 12]);
                    
Br_VarStep.GridSample([7 ]);
Br_VarStep.Sim(0:.05:20);
figure; Br_VarStep.PlotSignals({});


Br_VarStep.CheckSpec(phi_2) 
figure;Br_Spec.PlotRobustSat(phi_2)
%%
Br_VarStep_2 = Br.copy();                % Creates a copy of the system interface 
input_gen.type = 'VarStep';                % uniform time steps 
input_gen.cp = [4 ];     % u0,u1,u2,u3                  % number of control points
% input_gen.method = {'previous', 'linear'};  % interpolation methods - see help of interp1.
input_gen.method = {'previous'};  % interpolation methods - see help of interp1.

Br_VarStep_2.SetInputGen(input_gen); 
% This creates a new input parameterization:
%
%%% Changing Input Functions
% We set values for the control points and plot the result. The 
% semantics is input_ui holds for input_dti seconds 
Br_VarStep_2.SetParam({'psi_u0','psi_dt0','psi_u1', 'psi_dt1', 'psi_u2','psi_dt2','psi_u3'},...
                     [ 10 5 9 3 12 10 0 ]);
Br_VarStep_2.Sim(0:.05:20);
figure; Br_VarStep_2.PlotSignals({});

Br_VarStep_2.SetParamRanges({'psi_u0','psi_dt0'},...
                        [7 12;5 7]);
Br_VarStep_2.GridSample([3 6 ]);
Br_VarStep_2.Sim(0:.05:20);
figure; Br_VarStep_2.PlotSignals({});
              

Br_VarStep_2.CheckSpec(phi_2) 
figure;Br_Spec.PlotRobustSat(phi_2)


%% Enumerating Corners

% Again, we first set the ranges of parameters that we want to sample.
Br_Corners= Br_VarStep_2.copy(); 
Br_Corners.SetParamRanges({'psi_u0', 'psi_u1', 'psi_u2'},...
                        [10 15; 8 10;11 12.5]);
% Next we obtain the corner parameters
Br_Corners.CornerSample();  
figure;Br_Corners.PlotParams();  
set(gca,'View', [45 45]); 

%
Br_Corners.Sim(0:.05:20);
figure; Br_Corners.PlotSignals();
