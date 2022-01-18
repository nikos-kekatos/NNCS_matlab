function Data = generateNewDataImFlyingRobot(nlmpcStruct, runs, existingData, xHistoryDNN, uHistoryDNN)
% Generates new data for the flying robot based on the states visited by
% the trained policy and corresponding expert actions to generate new
% policies in DAgger.
% 
% Copyright 2019 The MathWorks, Inc.

% Extract NLMPC information of torque, states, and control action limits
bx = nlmpcStruct.bx;
bu = nlmpcStruct.bu;
nlobj = nlmpcStruct.nlobj;

% Initialize variables corresponding to predictive horizon, nloptions, and
% size of states and previous actions
p = nlobj.p;
nloptions = nlmpcmoveopt;
nx = size(bx,1);
nu = size(bu,1);

% Collect data
flagMat = zeros(runs,1);
flyingRobotData = Inf*ones(runs*p,nx+2*nu);
for i = 1: runs
    x0 = xHistoryDNN(i,:)';
    u0 = uHistoryDNN(i,:)';
    [~,~,info] = nlmpcmove(nlobj,x0,u0,zeros(1,nx),[],nloptions);
    % Store exit flag of nlmpc optimization
    flagMat(i) = info.ExitFlag;
    % Store data = [theta, theta_dot, uStar] 
    if flagMat(i)>0
        left = (i-1)*p+1;
        right = i*p;
        flyingRobotData(left:right,1:nx) = info.Xopt(1:p,1:nx);
        flyingRobotData(left:right,nx+1:nx+nu) = [u0';info.MVopt(1:p-1,1:nu)];
        flyingRobotData(left:right,nx+nu+1:nx+2*nu) = info.MVopt(1:p,1:nu);
    end    
end

% Prepare final data
Data = flyingRobotData;
Data(sum(isinf(Data),2) == size(Data,2),:) = [];

% Remove duplicate records from Data
Data(ismember(Data,existingData,'rows'),:) = [];

end
