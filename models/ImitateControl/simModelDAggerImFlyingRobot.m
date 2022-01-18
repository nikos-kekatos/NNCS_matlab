function [xHistory,uHistory] = simModelDAggerImFlyingRobot(x0,u0,DNN,Ts,Tf)
% Performs closed-loop simulation of tracking control and simulates the
% system for |Tf/Ts+1| steps with DNN
% 
% Copyright 2019 The MathWorks, Inc.

% Initialize Tsteps and required variables
Tsteps = Tf/Ts+1;        
xHistory = x0';
uHistory = [];
lastMV = u0';
numObservations = size(x0,1) + size(u0,1);

for k = 1:Tsteps % from t=0 to t=12 sec
    % Obtain plant output measurements with sensor noise.
    xk = xHistory(k,1:6)';
    feature = [xk',lastMV];
    % Compute the control moves with reference previewing.
    uk = predict(DNN, reshape(feature,[numObservations 1 1 1]));
    % Store the control move and update the last MV for the next step.
    uHistory(k,:) = uk';
    lastMV = uk;
    % Update the real plant states for the next step by solving the
    % continuous-time ODEs based on current states xk and input uk.
    ODEFUN = @(t,xk) ControlFlyingRobotStateFcn(xk,uk);
    [TOUT,YOUT] = ode45(ODEFUN,[0 Ts], xHistory(k,:)');
    % Store the state values.
    xHistory(k+1,:) = YOUT(end,:);            
end
