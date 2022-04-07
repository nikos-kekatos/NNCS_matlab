
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