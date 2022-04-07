%Set initial condition for the states of the flying robot (x, y, θ, x dot, y dot, θ dot) 
% and the control variables of flying robot (u_l, u_r).
x0 = [-1.8200    0.5300   -2.3500    1.1700   -1.0400    0.3100]';
u0 = [-2.1800   -2.6200]';

% Run a closed-loop simulation of the NLMPC controller.
% Duration
Tf = 15;
% Sample time
Ts = nlobj.Ts;
% Simulation steps
Tsteps = Tf/Ts+1;
% Run NLMPC in closed loop.
tic
[xHistoryMPC,uHistoryMPC] = simModelMPCImFlyingRobot(x0,u0,nlobj,Tf);
toc

% Run a closed-loop simulation of the trained DAgger network.
tic
[xHistoryDNN,uHistoryDNN] = simModelDAggerImFlyingRobot(x0,u0,imitateMPCNetObj,Ts,Tf);
toc

% Plot the results, and compare the NLMPC and trained DNN trajectories.
plotSimResultsImFlyingRobot(nlobj,xHistoryMPC,uHistoryMPC,xHistoryDNN,uHistoryDNN,umax,Tf)
