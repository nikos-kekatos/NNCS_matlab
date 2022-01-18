function nlobj = createMPCobjImFlyingRobot(umax)
% Trajectory Optimization and Control of Flying Robot Using Nonlinear MPC
% Creates a nonlinear MPC object for the flying robot with |6| states,
% |2| previous actions, and |2| inputs.

% Copyright 2019 The MathWorks, Inc.

% Set the values of number of states, outputs and inputs and Create
% Nonlinear MPC Controller
nx = 6;
ny = 6;
nu = 2;
nlobj = nlmpc(nx,ny,nu);

% Define state function and weights to the nlmpc object
nlobj.Model.StateFcn = 'ControlFlyingRobotStateFcn';
nlobj.Jacobian.StateFcn = 'ControlFlyingRobotStateJacobianFcn';

% Assign Ts, predictive and control horizon
Ts = 0.4;
nlobj.Ts = Ts;
p = 30;
nlobj.PredictionHorizon = p;
nlobj.ControlHorizon = p;

% Define weights of output variables
nlobj.Weights.OutputVariables = [1 1 2 0 0 0];

% Define solver options
sol = nlobj.Optimization.SolverOptions;
sol.ConstraintTolerance = 0.01;
sol.MaxIterations = 100;
sol.OptimalityTolerance = 0.01;
sol.FunctionTolerance = 0.01;
sol.StepTolerance = 0.01;

% Each thrust has an operating range between |-umax| and |umax|, which is
% translated into lower and upper bounds on the MVs.
for ct = 1:nu
    nlobj.MV(ct).Min = -umax;
    nlobj.MV(ct).Max = umax;
end

end
