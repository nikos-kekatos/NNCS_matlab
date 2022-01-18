function flagMat = collectDataImFlyingRobot(runs)
% Creates  input data for the behavior cloning training. It creates
% runs*Tf/Ts records and saves them into a MAT file
% 'behaviorCloningInputDataFileImFlyingRobot.mat'.
% 
% Copyright 2019 The MathWorks, Inc.

% Use a different seed such as rng('shuffle') to create differing data
rng(10)

% Define Torque, States and Control action limits
umax = 3;
bx = [4,4,3.2,2,2,1]';
bu = [umax,umax]';

% Turn off mpc messages display. 
% mpcverbosity off;

% Create NLMPC object.
nlobj = createMPCobjImFlyingRobot(umax);

% Save predictive horizon value to assign random initial guess to the state
% and manipulated variables
p = nlobj.p;
nloptions = nlmpcmoveopt;

% Calculate number of states and previous actions
nx = size(bx,1);
nu = size(bu,1);

% Collect data
flagMat = zeros(runs,1);
flyingRobotData = Inf*ones(runs*p,nx+2*nu);
for ct = 1:runs
    % States
    x0 = getRandomInputImFlyingRobot(bx, []);
    u0 = getRandomInputImFlyingRobot(bu, []);
    [~,~,info] = nlmpcmove(nlobj,x0,u0,zeros(1,nx),[],nloptions);
    % Store exit flag of nlmpc optimization
    flagMat(ct) = info.ExitFlag;
    % Store data = [theta, theta_dot, uStar] 
    if flagMat(ct)>0
        left = (ct-1)*p+1;
        right = ct*p;
        flyingRobotData(left:right,1:nx) = info.Xopt(1:p,1:nx);
        flyingRobotData(left:right,nx+1:nx+nu) = [u0';info.MVopt(1:p-1,1:nu)];
        flyingRobotData(left:right,nx+nu+1:nx+2*nu) = info.MVopt(1:p,1:nu);
    end
end

% Prepare final data for the MAT file
Data = flyingRobotData;
Data(sum(isinf(Data),2) == size(Data,2),:) = [];

% Save the MAT file
save('behaviorCloningInputDataFileImFlyingRobot','Data');
end
