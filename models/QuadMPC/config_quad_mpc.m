clear;close all;clc;
getQuadrotorDynamicsAndJacobian;
% The getQuadrotorDynamicsAndJacobian script generates the following files:
% QuadrotorStateFcn.m — State function
% QuadrotorStateJacobianFcn.m — State Jacobian function

%Create a nonlinear MPC object with 12 states, 12 outputs, and 4 inputs. By default, all the inputs are manipulated variables (MVs).
nx = 12;
ny = 12;
nu = 4;
nlobj = nlmpc(nx, ny, nu);

options.ref_Ts=5;
options.sim_cov=1*ones(1,12)';
% options.sim_cov=1:6;
options.input_choice=3;

% Specify the prediction model state function using the function name. You can also specify functions using a function handle. 
nlobj.Model.StateFcn = "QuadrotorStateFcn";
% Specify the Jacobian of the state function using a function handle. It is best practice to provide an analytical Jacobian for the prediction model. Doing so significantly improves simulation efficiency. 
nlobj.Jacobian.StateFcn = @QuadrotorStateJacobianFcn;
% Validate your prediction model, your custom functions, and their Jacobians.
rng(0)
validateFcns(nlobj,rand(nx,1),rand(nu,1));
% Specify a sample time of 0.1 seconds, prediction horizon of 18 steps, and control horizon of 2 steps. 
Ts = 0.1;
p = 18;
m = 2;
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
% Closed-Loop Simulation
% Simulate the system for 20 seconds with a target trajectory to follow.
% Specify the initial conditions
x = [7;-10;0;0;0;0;0;0;0;0;0;0];
% Nominal control that keeps the quadrotor floating
nloptions = nlmpcmoveopt;
nloptions.MVTarget = [4.9 4.9 4.9 4.9]; 
mv = nloptions.MVTarget;
% Simulate the closed-loop system using the nlmpcmove function, specifying simulation options using an nlmpcmove object.
Duration = 20;
hbar = waitbar(0,'Simulation Progress');
xHistory = x';
lastMV = mv;
uHistory = lastMV;

for k = 1:(Duration/Ts)
    % Set references for previewing
    t = linspace(k*Ts, (k+p-1)*Ts,p);
    yref = QuadrotorReferenceTrajectory(t);
    % Compute the control moves with reference previewing.
    xk = xHistory(k,:);
    [uk,nloptions,info] = nlmpcmove(nlobj,xk,lastMV,yref',[],nloptions);
    uHistory(k+1,:) = uk';
    lastMV = uk;
    % Update states.
    ODEFUN = @(t,xk) QuadrotorStateFcn(xk,uk);
    [TOUT,YOUT] = ode45(ODEFUN,[0 Ts], xHistory(k,:)');
    xHistory(k+1,:) = YOUT(end,:);
    waitbar(k*Ts/Duration,hbar);
end
close(hbar)
% Visualization and Results
% Plot the results, and compare the planned and actual closed-loop trajectories.
plotQuadrotorTrajectory;
% Because the number of MVs is smaller than the number of reference output trajectories, there are not enough degrees of freedom to track the desired trajectories for all OVs. 
% As shown in the figure for states  and control inputs,
% The states  match the reference trajectory very closely within 7 seconds.
% The states  are driven to the neighborhood of zeros within 9 seconds. 
% The control inputs are driven to the target value of 4.9 around 10 seconds.
% You can animate the trajectory of the quadrotor. The quadrotor moves close to the "target" quadrotor which travels along the reference trajectory within 7 seconds. After that, the quadrotor follows closely the reference trajectory. The animation terminates at 20 seconds.

% animateQuadrotorTrajectory;

