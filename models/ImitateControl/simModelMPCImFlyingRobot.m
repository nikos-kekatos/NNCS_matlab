function [xHistory,uHistory] = simModelMPCImFlyingRobot(x0,u0,nlobj,Tf)
% Performs closed-loop simulation of tracking control and simulates the
% system for |Tf/Ts+1| steps with MPC
% 
% Copyright 2019 The MathWorks, Inc.

% Initialize Tsteps and required variables
Ts = nlobj.Ts;
Tsteps = Tf/Ts+1;       
xHistory = x0';
uHistory = [];
lastMV = u0;

% Use |nlmpcmove| and |nlmpcmoveopt| command for closed-loop simulation.
hbar = waitbar(0,'Simulation Progress');
options = nlmpcmoveopt;

for k = 1:Tsteps % from t=0 to t=12 sec
    % Obtain plant output measurements with sensor noise.
    xk = xHistory(k,1:6)';
    % Compute the control moves with reference previewing.
    [uk,options,simInfo] = nlmpcmove(nlobj,xk,lastMV,zeros(1,6),[],options);
    if simInfo.ExitFlag<0
        fprintf('Infeasible solution')
    end
    % Store the control move and update the last MV for the next step.
    uHistory(k,:) = uk';
    lastMV = uk;
    % Update the real plant states for the next step by solving the
    % continuous-time ODEs based on current states xk and input uk.
    ODEFUN = @(t,xk) ControlFlyingRobotStateFcn(xk,uk);
    [TOUT,YOUT] = ode45(ODEFUN,[0 Ts], xHistory(k,:)');
    % Store the state values.
    xHistory(k+1,:) = YOUT(end,:);            
    % Update the status bar.
    waitbar(k/Tsteps, hbar);
end
close(hbar)


