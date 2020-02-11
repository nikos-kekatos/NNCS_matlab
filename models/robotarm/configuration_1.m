% Here we specify the training parameters.
% we store all the specifications in a structure named options.

% Time horizon of simulation in Simulink
options.T_train=60;

% Choose reference type: (1) for constant and (2) for time varying
options.reference_type=2;

if options.reference_type==1
    block_name=strcat(SLX_model,'/Switch');
    set_param(block_name, 'sw', '0');
else
    block_name=strcat(SLX_model,'/Switch');
    set_param(block_name, 'sw', '1');
end

% CONSTANT references (Specify the values here)
if options.reference_type==1
    options.simin_ref=-0.5:0.5:0.5;
    % options.simin_ref=linspace(-0.5,0.5,20)
    % options.simin_ref=[-0.5;-0.35;-0.3;-0.2;0;0.1;0.15;0.2;0.3;0.4;0.45;0.5];
    options.no_ref=numel(options.simin_ref);
else
    options.simin_ref=0; % not used but needed by Simulink to avoid undeclared variables
end

% RANDOM references
% specify min and max values
if options.reference_type==2
    
    options.ref_min=-0.5;
    options.ref_max=0.5;
    options.ref_Ts=4;
    %     options.ref_seed=randi(2^32,[1 1000]); % moved to run_simulations
    
    % Choose number of different traces for references
    options.no_ref=30;
else
    options.ref_min=-0.5; % not used but needed by Simulink to avoid undeclared variables
    options.ref_max=0.5; % not used but needed by Simulink to avoid undeclared variables
    options.ref_Ts=10; % not used but needed by Simulink to avoid undeclared variables
    options.ref_seed=0;
end
% Choose number of initial conditions for x_0, to be used in simulations
options.no_x0=10;
options.no_x0_repeated=1; %1 if all different

% Minimum and maximum value of x0
x0_min=-0.2;
x0_max=0.2;

% Default x_0 (needed only if x_0 remains constant)
if options.no_x0==0 || options.no_x0==1
    x0_default=0;
    options.simin_x0=x0_default;
else
    if options.no_x0_repeated==1
        options.simin_x0=linspace(x0_min,x0_max,options.no_x0);
    else
        no_x0_ceiled=ceil(options.no_x0/options.no_x0_repeated)*options.no_x0_repeated;
        temp_x0=linspace(x0_min,x0_max,no_x0_ceiled/options.no_x0_repeated);
        simin_x0=repelem(temp_x0,options.no_x0_repeated);
        options.simin_x0=simin_x0(1:options.no_x0);
    end
end

% Select if you want to plot one simulation trace from training
options.plotting_sim=1;

% Select if you want prepropreccing
options.preprocessing_bool=1;
options.preprocessing_eps=0.01;

% Select if you want to save the simulation data
options.save_sim=1;
% options.sim_name=''; %if empty or commented, there will be a default option

% Do NOT change this part
options.dt=0.02; % PID sampling time
if options.reference_type==1
    options.no_ref=numel(options.simin_ref);
end
options.no_traces=options.no_ref*options.no_x0;
disp('')
fprintf('The total number of traces is %i.\n\n',options.no_traces);

if options.reference_type==2
    options.no_setpoints=floor(options.T_train/options.ref_Ts);
    if mod(options.T_train,options.ref_Ts)~=0
        warning(' The setpoints they do not have equal length. The REF array might have incorrect values')
    end
    options.samples_per_setpoint=options.ref_Ts/options.dt;
    fprintf('Each simulation trace produces %i points for each setpoint.\n',options.samples_per_setpoint); 
    fprintf('The number of setpoints is %i.\n\n',options.no_setpoints);
end
points_per_sim=options.T_train/options.dt;
total_points=options.no_traces*points_per_sim;
fprintf('Each simulation trace produces %i points for u and y.\n\n',points_per_sim);
fprintf('All simulations produce %i points for u and y.\n\n',total_points);

% options.main_dir=main_dir;