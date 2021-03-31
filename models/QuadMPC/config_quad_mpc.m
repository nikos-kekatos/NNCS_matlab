options.T_train=20;
% options.breach_segments=2;
options.dt=Ts;

options.combination=0;

% options.trace_gen_via_sim=1; % trace generation via Simulation or via falsification

options.debug=0;

% Select if you want to plot one simulation trace from training
options.plotting_sim=1;

options.test_dataMatching=0;
options.specs_file='specs_hespanha.stl';


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

options.testing.train_data=0; %0 for testing centers, 1 for testing training data

% Specifically, the references that we generated with a coverage approach in mind 
% were of the form: rx = In1 ⋅ sin (t/3), ry = In2 ⋅ sin (t/3) ⋅ cos (t/3), 
% rz = In3 ⋅ sin (t/3), with 5.5 ≤ In1 ≤ 6.5, − 6.6 ≤ In2 ≤ 5.6 and 5.5 ≤ In3 ≤ 6.5.

%  references: positions in x, y ,z  
options.ref_min=[ 5.5 -6.5 5.5] ; % %% HERE we specify the amplitude of the sinusoidal references
options.ref_max=[6.5 -5.5 6.5];

% partition the state space in rectangulars 
% Grid resolution, box width

options.delta_resolution=1/2; %0.1
options.no_cells_per_dim=(options.ref_max-options.ref_min)/options.delta_resolution;

options.no_cells_total=prod(options.no_cells_per_dim);

fprintf('The number of cells in total equals %i.\n\n',options.no_cells_total);
% need to get centers and cell ranges
for i=1:numel(options.ref_min)
options.temp_cells_centers{i}=(options.ref_min(i)+options.delta_resolution/2):options.delta_resolution:(options.ref_max(i)-options.delta_resolution/2);
end

no_cells=options.no_cells_total
options.cells_centers=combvec(options.temp_cells_centers{1},options.temp_cells_centers{2},options.temp_cells_centers{3});

for i=1:no_cells
    options.cells{i}.centers=options.cells_centers(:,i);
    options.cells{i}.min=options.cells_centers(:,i)-options.delta_resolution/2*ones(3,1);
    options.cells{i}.max=options.cells_centers(:,i)+options.delta_resolution/2*ones(3,1);
    options.cells{i}.random_value=(options.cells{i}.max-options.cells{i}.min).*rand(3,1)+options.cells{i}.min;
end

options.coverage.points='c'; % c for centers, 'r' for random points

% options: choose coverage as value from 0 - 1
options.coverage.cell_occupancy=1;

options.no_traces=options.no_cells_total;
clear i no_cells

