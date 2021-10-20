function Data=coverage_generation(delta)


global Vx mpcobj initialState

% use a different seed such as rng('shuffle') to create differing data
rng(0)

% note that Vx=15;
Vx=15;
ref_min=[-2;-1.04;-1;-0.8;-1.04;-0.01*Vx];
ref_max=[2;1.04;1;0.8;1.04;0.01*Vx];

if nargin==0
    delta=[0.5;1.04;0.25;0.4;0.52;0.15]; %supports multi-resolution boxes
end



dim=numel(ref_min);

if numel(delta)~=numel(ref_min)
    delta=delta*ones(numel(ref_min),1);
end
no_cells_per_dim=(ref_max-ref_min)./delta;
if floor(no_cells_per_dim) == no_cells_per_dim
    disp('The number of boxes is finite.')
    fprintf('The original resolution was:%s \n',mat2str(delta))
else
    fprintf('The original resolution was:%s \n',mat2str(delta))
    
    no_cells_per_dim=ceil(no_cells_per_dim);
    delta=(ref_max-ref_min)./no_cells_per_dim;
    fprintf('The new resolution is: %s\n',mat2str(delta));
    
    disp('The resolution was modified to create a finite number of boxes')
end

no_cells_total=prod(no_cells_per_dim); % 5*4*... cells

fprintf('The number of cells per dimension is %s.\n\n',mat2str(no_cells_per_dim));
fprintf('The number of cells in total equals %i.\n\n',no_cells_total);

cell_values=[];
for i=1:dim
    temp=(ref_min(i)+delta(i)/2):delta(i):(ref_max(i)-delta(i)/2);
    temp_coverage.cell_values{i}=temp;
end
%%
temp_coverage.cells_centers=[];
temp_coverage.cells_centers=combvec(temp_coverage.cell_values{:});
for i=1:no_cells_total
    cells{i}.centers=temp_coverage.cells_centers(:,i);
    cells{i}.min=temp_coverage.cells_centers(:,i)-delta/2;
    cells{i}.max=temp_coverage.cells_centers(:,i)+delta/2;
    % rand(1) -> [0,1]
    % rand(1)*2 -> [0,2]
    % rand(1)*3+1 -> [1,4]
    % rand(1)*(max-min)+min -> [min,max]
    cells{i}.random_value=(cells{i}.max-cells{i}.min).*rand(dim,1)+cells{i}.min;
end

% options: choose coverage as value from 0 - 1
cell_occupancy=1;

no_traces_ref=cell_occupancy*no_cells_total;
no_traces_ref=floor(no_traces_ref);
fprintf('The selected cell occupancy is %.2f%%.\n\n',cell_occupancy*100);
fprintf('The number of different reference traces (coverage-based) is %i.\n\n',no_traces_ref);
flag=1;
if flag && numel(ref_min)==2
    m=2;
    plot_coverage_boxes(options,flag);
end


vy=[];
r=[];
e1=[];
e2=[];
u=[];
rho=[];

totalNumOfData = length(cells);

% Evaluate the next move and create the dataset
Data = zeros(totalNumOfData,9);
for ct = 1:totalNumOfData
    dataFromGrid = cells{ct}.random_value;
    
    % vy,r,e1,e2,u,rho
    x0 = dataFromGrid(1:4);
    u0 = dataFromGrid(5);
    rho = dataFromGrid(6);
    initialState.Plant = x0;
    initialState.LastMove = u0;
    [uStar,info] = mpcmove(mpcobj,initialState,x0,zeros(1,4),Vx*rho);
    
    % vy,r,e1,e2,u,rho,cost,iterations,uStar
    Data(ct,:) = [x0(:)',u0,rho,info.Cost,info.Iterations,uStar];
end
end





