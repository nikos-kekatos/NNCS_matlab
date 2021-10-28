% Set the initial plant state and control action in the mpcstate object.
initialState.Plant = x0;
initialState.LastMove = u0;

% Initialize the state and input trajectories for the MPC controller simulation.
xHistoryMPC = repmat(x0',Tsteps+1,1);
uHistoryMPC = repmat(u0',Tsteps,1);
% Run a closed-loop simulation of the MPC controller and the plant using the mpcmove function.
for k = 1:Tsteps
    % Obtain plant output measurements, which correspond to the plant outputs.
    xk = xHistoryMPC(k,:)';
    % Compute the next cotnrol action using the MPC controller.
    uk = mpcmove(mpcobj,initialState,xk,zeros(1,4),Vx*rho);
    % Store the control action.
    uHistoryMPC(k,:) = uk;
    % Update the state using the control action.
    xHistoryMPC(k+1,:) = (sys.A*xk + sys.B*[uk;Vx*rho])';
end
