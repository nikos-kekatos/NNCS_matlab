function [mpcobj,initialState] = createMPCobjImLKA(sys)
% Creates a MPC object

% Copyright 2019 The MathWorks, Inc.

% turn off the mpc verbosity
oldStatus = mpcverbosity('off');
clnup = onCleanup(@()mpcverbosity(oldStatus));

% Specify the MPC signal types in the plant.
sys = setmpcsignals(sys,'MV',1,'MD',2);

% MPC Design, similar to LKA block
Ts = sys.Ts;
mpcobj = mpc(sys,Ts);

% Specify MV constraints: max/min steering.
mpcobj.MV.Min = -1.04;
mpcobj.MV.Max =  1.04;

% Assign Predictive Horizon (p) and Control horizon (c)
mpcobj.p = 20;
mpcobj.c = 20;

% Specify scale factors based on the operating ranges of the variables.
mpcobj.MV.ScaleFactor = 2.08;        % range of the steering angle
mpcobj.DV.ScaleFactor = 0.3;         % scale factor of road yaw angle rate
mpcobj.OV(1).ScaleFactor = 4;        % scale factor of lateral velocity
mpcobj.OV(2).ScaleFactor = 2.08;     % scale factor of yaw rate
mpcobj.OV(3).ScaleFactor = 2;        % scale factor of lateral deviation w.r.t road
mpcobj.OV(4).ScaleFactor = 1.6;     % scale factor of relative yaw angle w.r.t. road

% Specify weights.
alpha = 1;                             % weights in LKA design
mpcobj.Weights.MVRate = 0.1*alpha;     % weight on change of steering angle
mpcobj.Weights.OV = [0 0 1 0.1]/alpha; % tighter control on lateral deviation over relative yaw angle

% get the initial state
initialState = mpcstate(mpcobj);
end

