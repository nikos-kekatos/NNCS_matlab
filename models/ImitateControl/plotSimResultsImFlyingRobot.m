function plotSimResultsImFlyingRobot(nlobj,xHistoryMPC,uHistoryMPC,xHistoryDNN,uHistoryDNN,umax,Tf)
% Displays the deep neural network and NLMPC trajectories for x, y,
% theta, Vx, Vy, angular velocity, and actions (Thrusts) of the flying
% robot.
%
% Copyright 2019 The MathWorks, Inc.

% Extract Ts and Tsteps
Ts = nlobj.Ts;
Tsteps = Tf/Ts+1;   

% Plot the state trajectories.
tt = Ts*(0:Tsteps);
figure('Position',[464 173 560 420])
states = {'x1','x2','theta','v1','v2','omega'};
for i = 1:6
    subplot(3,2,i)
    plot(tt,xHistoryDNN(:,i),'+',tt,xHistoryMPC(:,i),'-')
    legend('DNN','MPC','location','best')
    title(states{i})
end

% Plot the control action trajectories.
figure('Position',[1025 173 560 420])
subplot(2,1,1)
stairs(tt(1:end-1),uHistoryDNN(:,1));
title(sprintf('Thrust T1'));
axis([0 tt(end) -1.1*umax 1.1*umax]);
hold on
stairs(tt(1:end-1),uHistoryMPC(:,1));
legend('DNN','MPC')
hold off
subplot(2,1,2)
stairs(tt(1:end-1),uHistoryDNN(:,2));
title(sprintf('Thrust T2'));
axis([0 tt(end) -1.1*umax 1.1*umax]);
hold on
stairs(tt(1:end-1),uHistoryMPC(:,2));
legend('DNN','MPC')
hold off
