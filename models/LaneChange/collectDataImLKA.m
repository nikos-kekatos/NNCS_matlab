function collectDataImLKA(isRandom)
% Creates the MAT file 'InputDataFileImLKA.mat' based on the value of
% 'isRandom'

% If isRandom is true (1), then random input data is generated and stored in
% the 'InputDataFileImLKA.mat' If isRandom is false (0), then input data is
% generated from the grid formed by changing the values of lateral
% velocity, yaw angle rate, lateral deviation, relative yaw angle, last
% steering angle, curvature under the 'variables' section in the script,
% and stores the data in 'InputDataFileImLKA.mat'

% Copyright 2019 The MathWorks, Inc.


% use a different seed such as rng('shuffle') to create differing data
rng(0)

% Generate MPC object.
[sys,Vx] = createModelForMPCImLKA;

[mpcobj,initialState] = createMPCobjImLKA(sys);
mpcobj.p = 20;
mpcobj.c = 20;

if (isRandom)
    % Generate random data
    Data = zeros(1e5,9);
    for ct = 1:1e5
        [x0,u0,rho] = getFeaturesRandomImLKA;
        initialState.Plant = x0;
        initialState.LastMove = u0;
        [uStar,info] = mpcmove(mpcobj,initialState,x0,zeros(1,4),Vx*rho);
        
        % vy,r,e1,e2,u,rho,cost,iterations,uStar
        Data(ct,:) = [x0(:)',u0,rho,info.Cost,info.Iterations,uStar];
    end
else
    % You can generate data from a grid using the following example.
    % Customize the grid for the data generation and the generated data is
    % later used in the training process. Following are the variables that
    % should be varied to generate the data:
    %       1. vy, r, e1, e2, u, rho : vary the range of these
    %       variables to customize the grid 
    %       2. totalNumOfData : This variable stores the value of the 
    %       total number of rows that goes into the generated dataset. The 
    %       ideal value for this variable is as follows
    
    %    'length(vy)*length(r)*length(e1)*length(e2)*length(u)*length(rho)'
    
    %       If this value is too big to collect data, then you can select
    %       the data with required number of rows from the 'actionGrid'
    %       randomly. So that the 'mat' file is created and saved properly.
    
    % Generate grid data  
    % lateral velocity
    vy = -2:1:2;
    % yaw angle rate
    r = -1.04:0.52:1.04;
    % lateral deviation
    e1 = -1:0.5:1;
    % relative yaw angle
    e2 = -0.8:0.4:0.8;
    % last steering angle
    u = -1.04:0.52:1.04;
    % curvature
    rho = -0.02:0.01:0.02;
    
    % Create data grid
    [Vy,R,E1,E2,U,Rho] = ndgrid(vy,r,e1,e2,u,rho);
    totalNumOfData = numel(Vy);
    actionGrid = [Vy(:),R(:),E1(:),E2(:),U(:),Rho(:)]';
    
    % Evaluate the next move and create the dataset
    Data = zeros(totalNumOfData,9);
    for ct = 1:totalNumOfData
        dataFromGrid = actionGrid(:,ct);
        
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

% Create MAT file
save('InputDataFileImLKA','Data')

end