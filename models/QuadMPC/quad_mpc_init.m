
% The getQuadrotorDynamicsAndJacobian script generates the following files:
% QuadrotorStateFcn.m — State function
% QuadrotorStateJacobianFcn.m — State Jacobian function
getQuadrotorDynamicsAndJacobian;

%Create a nonlinear MPC object with 12 states, 12 outputs, and 4 inputs. By default, all the inputs are manipulated variables (MVs).
nx = 12;
ny = 12;
nu = 4;
nlobj = nlmpc(nx, ny, nu);

% Specify the prediction model state function using the function name. You can also specify functions using a function handle. 
nlobj.Model.StateFcn = "QuadrotorStateFcn";
% Specify the Jacobian of the state function using a function handle. It is best practice to provide an analytical Jacobian for the prediction model. Doing so significantly improves simulation efficiency. 
nlobj.Jacobian.StateFcn = @QuadrotorStateJacobianFcn;
% Validate your prediction model, your custom functions, and their Jacobians.
rng(0)
validateFcns(nlobj,rand(nx,1),rand(nu,1));

% Specify a sample time of 0.1 seconds, prediction horizon of 18 steps, and control horizon of 2 steps. 
Ts = 0.1;
p = 18; % prediction horizon
m = 2; % control horizon

nlobj.Ts = Ts;
nlobj.PredictionHorizon = p;
nlobj.ControlHorizon = m;
% Limit all four control inputs to be in the range [0,12].
nlobj.MV = struct('Min',{0;0;0;0},'Max',{12;12;12;12});
% The default cost function in nonlinear MPC is a standard quadratic cost function suitable for reference tracking and disturbance rejection. In this example, the first 6 states  are required to follow a given reference trajectory. Because the number of MVs (4) is smaller than the number of reference output trajectories (6), there are not enough degrees of freedom to track the desired trajectories for all output variables (OVs).
nlobj.Weights.OutputVariables = [1 1 1 1 1 1 0 0 0 0 0 0];
% In this example, MVs also have nominal targets to keep the quadrotor floating, which can lead to conflict between the MV and OV reference tracking goals. To prioritize targets, set the average MV tracking priority lower than the average OV tracking priority.
nlobj.Weights.ManipulatedVariables = [0.1 0.1 0.1 0.1];
% Also, penalize aggressive control actions by specifying tuning weights for the MV rates of change.
nlobj.Weights.ManipulatedVariablesRate = [0.1 0.1 0.1 0.1];
