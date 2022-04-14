
% Time horizon of simulation in Simulink
options.T_train=40; % simulation time horizon
options.SLX_model=SLX_model;

% Choose reference type: (1) for constant, (2) for time varying and (3) for
% coverage and (4) for Breach

options.dt=1e-3;
options.reference_type=1; %% CONSTANT
options.input_choice=options.reference_type;


%not needed/used but defined
options.model=0;
options.combination=0;
options.debug=0;
options.error_mean=0;
options.error_sd=0; % replace by 0 and rerun all experiments.
options.plotting_sim=0;

%% WORKS for a single reference variable

% CONSTANT references (Specify the values here)
if options.reference_type==1 %constant
    
    % Option 1: min, step, max
    options.simin_ref=25:0.5:35;
    
    % Option 2: linspace -- similar
    % options.simin_ref=linspace(-0.5,0.5,51) %LINSPACE
    
    % Option 3: specify inputs
    % options.simin_ref=[-0.5;-0.35;-0.3;-0.2;0;0.1;0.15;0.2;0.3;0.4;0.45;0.5];
    options.no_ref=numel(options.simin_ref);
    
    options.no_x0=1;
    
    options.simin_x0=0;
    options.no_traces=options.no_ref*options.no_x0;
end