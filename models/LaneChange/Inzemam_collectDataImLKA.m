function Inzemam_collectDataImLKA(isRandom, gridOption)
% Creates the MAT file 'InputDataFileImLKA.mat' based on the value of
% 'isRandom'

% If isRandom is true (1), then random input data is generated and stored in
% the 'InputDataFileImLKA.mat' If isRandom is false (0), then input data is
% generated from the grid formed by changing the values of lateral
% velocity, yaw angle rate, lateral deviation, relative yaw angle, last
% steering angle, curvature under the 'variables' section in the script,
% and stores the data in 'InputDataFileImLKA.mat'

% Copyright 2019 The MathWorks, Inc.

if nargin == 2 && isRandom == true
    exit
end

if nargin == 1 && isRandom == false
    gridOption = 1;
end
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

    %   If gridOption is 
    %       1 => corners of grid cells are data points
    %       2 => centres of grid cells are data points
    %       3 => random data points in the grid cells

    ref_min = [-2 -1.04 -1 -0.8 -1.04 -0.02];
    ref_max = [2 1.04 1 0.8 1.04 0.02];
    dim = [4 4 4 4 4 4];
    increment = (ref_max - ref_min)./dim;

    if gridOption == 1

%         % Generate grid data  
%         % lateral velocity
%         vy = -2:1:2;
%         % yaw angle rate
%         r = -1.04:0.52:1.04;
%         % lateral deviation
%         e1 = -1:0.5:1;
%         % relative yaw angle
%         e2 = -0.8:0.4:0.8;
%         % last steering angle
%         u = -1.04:0.52:1.04;
%         % curvature
%         rho = -0.02:0.01:0.02;

        % collecting all the corners of the grid
        vy = ref_min(1):increment(1):ref_max(1);
        r = ref_min(2):increment(2):ref_max(2);
        e1 = ref_min(3):increment(3):ref_max(3);
        e2 = ref_min(4):increment(4):ref_max(4);
        u = ref_min(5):increment(5):ref_max(5);
        rho = ref_min(6):increment(6):ref_max(6);

    elseif gridOption == 2
        % collecting all the centres of the grid
        firstCentre = ref_min + increment./2;
        lastCentre = ref_max - increment./2;
        
        vy = firstCentre(1):increment(1):lastCentre(1);
        r = firstCentre(2):increment(2):lastCentre(2);
        e1 = firstCentre(3):increment(3):lastCentre(3);
        e2 = firstCentre(4):increment(4):lastCentre(4);
        u = firstCentre(5):increment(5):lastCentre(5);
        rho = firstCentre(6):increment(6):lastCentre(6);

    elseif gridOption == 3
        % collecting random values in the grid
        vy = [];
        r = [];
        e1 = [];
        e2 = [];
        u = [];
        rho = [];

        for i = 1:6
            cornerValues = ref_min(i):increment(i):ref_max(i);
            for j = 1:dim(i)
                lowestCellValue = cornerValues(j);
                highestCellValue = cornerValues(j + 1);
                tempRandValue = lowestCellValue + ...
                                (highestCellValue - lowestCellValue) * ...
                                    rand(1,1);
                if i == 1
                    vy(end + 1) = tempRandValue;
                elseif i == 2
                    r(end + 1) = tempRandValue;
                elseif i == 3
                    e1(end + 1) = tempRandValue;
                elseif i == 4
                    e2(end + 1) = tempRandValue;
                elseif i == 5
                    u(end + 1) = tempRandValue;
                elseif i == 6
                    rho(end + 1) = tempRandValue;
                end
            end
        end
    else
        fprintf("Invalid value of gridOption")
    end
        
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
save('InputDataFileImLKA_inz','Data')

end