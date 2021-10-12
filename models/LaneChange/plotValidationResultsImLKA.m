function plotValidationResultsImLKA(Ts,xDNN,uDNN,xMPC,uMPC)
% Displays the deep neural network and controller trajectories for lateral
% velocity Vy, yaw angle rate r, lateral deviation e1, relative yaw angle
% e2, and steering angle of the LKA.

% Copyright 2019 The MathWorks, Inc.

%%
% Plot the state trajectories
figure(1)
Tx  = ((0:(size(xDNN,1))-1)*Ts)';
states = {'Lateral Velocity (m/s)','Yaw Angle Rate (deg/s)',...
    'Lateral Deviation (m)','Relative Yaw Angle (deg)'};
for i = 1:4
    subplot(2,2,i)
    plot(Tx,xDNN(:,i),'+',Tx,xMPC(:,i),'-')
    legend('DNN','MPC','location','southeast')
    xlabel('Time (s)')
    title(states{i})
    grid on
end

%%
% Plot the control action trajectories.
Tu  = ((0:(size(uDNN,1))-1)*Ts)';
figure(2)
stairs(Tu,uDNN);
title(sprintf('Steering angle (deg)'));
xlabel('Time (s)')
axis([0 Tu(end) -1.1 1.1]);
hold on
stairs(Tu,uMPC);
legend('DNN','MPC')
grid on;
hold off

end