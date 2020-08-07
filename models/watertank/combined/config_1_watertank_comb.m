% Here we specify the training parameters.
% we store all the specifications in a structure named options.
% clear options

%%combination
%-----
options.combination=1; % if more than one nominal controllers
if options.combination
    ctrl_configuration='watertank_controllers';
    run(ctrl_configuration)
end
options.combination_matlab=1;
options.no_time_segments=10;
options.time_segments_step=1;

options.Q=[1/4]; % should be diagonal
options.R=[1/10]; %should be diagonal
if ~isdiag(options.Q)
    warning('The Q matrix (for x-ref) is not diagonal')
end
if ~isdiag(options.R)
    warning('The R matrix for (u) is not diagonal')
end
options.y_index_lqr=1; % could be a vector
options.u_des=0; % also a vector
%---------

% debugging
options.debug=1;

% Time horizon of simulation in Simulink
options.T_train=10; % for constant choose 5s
options.SLX_model=SLX_model;
options.SLX_folder='watertank';
% Choose reference type: (1) for constant, (2) for time varying and (3) for
% coverage and (4) for Breach

options.reference_type=3;

% Select if you want to plot one simulation trace from training
options.plotting_sim=0;

options.test_dataMatching=0;
options.specs_file='specs_watertank.stl';
% added for Breach
try
    block_name=strcat(SLX_model,'/Switch1');
    set_param(block_name, 'sw', '1');
    if options.reference_type==1
        block_name=strcat(SLX_model,'/Switch');
        set_param(block_name, 'sw', '0');
    elseif options.reference_type==2
        block_name=strcat(SLX_model,'/Switch');
        set_param(block_name, 'sw', '1');
    elseif options.reference_type==3
        block_name=strcat(SLX_model,'/Switch1');
        set_param(block_name, 'sw', '0');
    end
catch
    options.input_choice=options.reference_type;
end

if options.reference_type==4
    options.simin_ref=0;
    options.sim_cov=0;
    options.sim_ref=0;
    options.no_traces=50;
    options.breach_ref_min=8;
    options.breach_ref_max=12;
    options.breach_segments=2;
end
% end of Breach additions
% CONSTANT references (Specify the values here)
if options.reference_type==1
    options.simin_ref= 8:0.5:12;
    options.simin_ref=linspace(-0.5,0.5,51)
    % options.simin_ref=[-0.5;-0.35;-0.3;-0.2;0;0.1;0.15;0.2;0.3;0.4;0.45;0.5];
    options.no_ref=numel(options.simin_ref);
elseif options.reference_type==2
    options.simin_ref=0; % not used but needed by Simulink to avoid undeclared variables
elseif options.reference_type==3
    options.simin_ref=0;
end

% RANDOM references
% specify min and max values
if options.reference_type==2
    
    options.ref_min=-0.5;
    options.ref_max=0.5;
    options.ref_Ts=4;
    %     options.ref_seed=randi(2^32,[1 1000]); % moved to run_simulations
    
    % Choose number of different traces for references
    options.no_ref=50; %30
else
    options.ref_min=-0.5; % not used but needed by Simulink to avoid undeclared variables
    options.ref_max=0.5; % not used but needed by Simulink to avoid undeclared variables
    options.ref_Ts=10; % not used but needed by Simulink to avoid undeclared variables
    %     options.ref_seed=0;
    options.no_ref=1;
end

% Coverage- time varying refereces
options.testing.train_data=0; %0 for testing centers, 1 for testing training data
if options.reference_type==3
    options.coverage.m=2;
    options.ref_Ts=5;
    options.coverage.ref_min=8;
    options.coverage.ref_max=12;
    options.coverage.delta_resolution=1; %0.5; %0.1
%     options.coverage.no_cells_per_dim=(options.coverage.ref_max-options.coverage.ref_min)/options.coverage.delta_resolution-1;
    options.coverage.no_cells_per_dim=(options.coverage.ref_max-options.coverage.ref_min)/options.coverage.delta_resolution;

    warning('TO-DO: need to generalize by using ceil or floor')
    if mod(options.coverage.no_cells_per_dim,1)~=0
        warning('TO-DO: either have non uniform cells or reduce the minimum and maximum values or increase the resolution');
    end
    options.coverage.no_cells_total=options.coverage.no_cells_per_dim^options.coverage.m;
    fprintf('The number of pieces/dimensions equals %i.\n\n',options.coverage.m);
    fprintf('The number of points/samples per dimension equals %i.\n\n',options.coverage.no_cells_per_dim+1);
    
    fprintf('The number of cells per dimension equals %i.\n\n',options.coverage.no_cells_per_dim);
    fprintf('The number of cells in total equals %i.\n\n',options.coverage.no_cells_total);
    % need to get centers and cell ranges
%     options.coverage.cells_values=options.coverage.ref_min+options.coverage.delta_resolution:options.coverage.delta_resolution:options.coverage.ref_max-options.coverage.delta_resolution;
    options.coverage.cells_values=(options.coverage.ref_min+options.coverage.delta_resolution/2):options.coverage.delta_resolution:(options.coverage.ref_max-options.coverage.delta_resolution/2);
    if options.coverage.m==2
        options.coverage.cells_centers=combvec(options.coverage.cells_values,options.coverage.cells_values);
    elseif options.coverage.m==3
        options.coverage.cells_centers=combvec(options.coverage.cells_values,options.coverage.cells_values,options.coverage.cells_values);
    elseif options.coverage.m==4
        options.coverage.cells_centers=combvec(options.coverage.cells_values,options.coverage.cells_values,options.coverage.cells_values,options.coverage.cells_values);
    else
        temp=cell(1,options.coverage.m);
        for i=1:options.coverage.m
            temp{i}=options.coverage.cells_values;
        end
        options.coverage.cells_centers=combvec(temp{:});
    end
    no_cells=numel(options.coverage.cells_centers)/options.coverage.m;
    for i=1:no_cells
        options.coverage.cells{i}.centers=options.coverage.cells_centers(:,i);
        options.coverage.cells{i}.min=options.coverage.cells_centers(:,i)-options.coverage.delta_resolution/2*ones(options.coverage.m,1);
        options.coverage.cells{i}.max=options.coverage.cells_centers(:,i)+options.coverage.delta_resolution/2*ones(options.coverage.m,1);
        % rand(1) -> [0,1]
        % rand(1)*2 -> [0,2]
        % rand(1)*3+1 -> [1,4]
        % rand(1)*(max-min)+min -> [min,max]
        options.coverage.cells{i}.random_value=(options.coverage.cells{i}.max-options.coverage.cells{i}.min).*rand(options.coverage.m,1)+options.coverage.cells{i}.min;
        
    end
    options.coverage.points='c' % r:random, c:centers
    % options: choose coverage as value from 0 - 1
    options.coverage.cell_occupancy=1;
    options.coverage.no_traces_ref=options.coverage.cell_occupancy*options.coverage.no_cells_total;
    options.coverage.no_traces_ref=floor(options.coverage.no_traces_ref);
    fprintf('The selected cell occupancy (given a resolution %.5f) is %.2f%%.\n\n',options.coverage.delta_resolution,options.coverage.cell_occupancy*100);
    fprintf('The number of different reference traces (coverage-based) is %i.\n\n',options.coverage.no_traces_ref);
    flag=1;
    if options.plotting_sim
        plot_coverage_boxes(options,flag);
    end
end
% Choose number of initial conditions for x_0, to be used in simulations
options.no_x0=1;
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

% select if for testing you want to visualize the results
options.testing.plotting=1;

% select metric to be used for comparing nominal and nn behavior
options.testing.metric_method='mse';
options.testing.metric_y=1;
options.testing.metric_u=1;



% Select if you want prepropreccing
options.preprocessing_bool=0;
options.preprocessing_eps=0.01;

% Select if you want trimming
options.trimming=0;

% Select if you want to save the simulation data
options.save_sim=0;
% options.sim_name=''; %if empty or commented, there will be a default option

% Load old datasets
options.load=0;

% Add error on the PID output that follows the normal distribution
options.error_mean=0;
options.error_sd=0.01;

% Do NOT change this part
options.dt=0.01; % PID sampling time
if options.reference_type==1
    options.no_ref=numel(options.simin_ref);
end
if options.reference_type==2 || options.reference_type==1
    options.no_traces=options.no_ref*options.no_x0;
elseif options.reference_type==3
    disp('To DO - check consistency of traces')
    disp('Add option to input the number of traces instead of the occupancy.')
    disp(' ')
    
    options.no_traces=options.coverage.no_traces_ref*options.no_x0;
end
if options.reference_type~=4
    disp('')
    fprintf('The total number of traces is %i.\n\n',options.no_traces);
end

if options.reference_type==2
    options.no_setpoints=floor(options.T_train/options.ref_Ts);
    if mod(options.T_train,options.ref_Ts)~=0
        warning(' The setpoints they do not have equal length. The REF array might have incorrect values')
    end
    options.samples_per_setpoint=options.ref_Ts/options.dt+1;
    fprintf('Each simulation trace produces %i points for each setpoint.\n',options.samples_per_setpoint);
    fprintf('The number of setpoints is %i.\n\n',options.no_setpoints);
    
    options.points_per_sim=options.T_train/options.dt; %to account for zero
    total_points=options.no_traces*options.points_per_sim;
    fprintf('Each simulation trace produces %i points for u and y.\n\n',options.points_per_sim);
    fprintf('All simulations produce %i points for u and y.\n\n',total_points);
end
% options.main_dir=main_dir;

clearvars i no_cells flag x0_default x0_max x0_min block_name