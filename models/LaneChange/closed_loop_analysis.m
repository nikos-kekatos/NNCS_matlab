% To compare the performance of the MPC controller and the trained deep neural network, run closed-loop simulations using the vehicle plant model.
% Generate random initial conditions for the vehicle that are not part of the original input data set, with values selected from the following ranges:
% lateral velocity  : range (-2,2) m/s
% yaw angle rate  : range (-60,60) deg/s
% lateral deviation  : range (-1,1) m
% relative yaw angle  : range (-45,45) deg
% last steering angle (control variable)  : range (-60,60) deg
% measured disturbance (road yaw rate: longitudinal velocity * curvature ()) : range (-0.01,0.01), minimum road radius: 100 m.
%rng(5e7)
[x0,u0,rho] = generateRandomDataImLKA(data);
% Set the initial plant state and control action in the mpcstate object.
initialState.Plant = x0;
initialState.LastMove = u0;
% Extract the sample time from the MPC controller. Also, set the number of simulation steps.
try
    Ts = mpcobj.Ts;
catch
    Ts=0.1;
end
Tsteps = 30;
% Obtain the A and B state-space matrices for the vehicle model.
A = sys.A;
B = sys.B;
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
    xHistoryMPC(k+1,:) = (A*xk + B*[uk;Vx*rho])';
end
% Initialize the state and input trajectories for the deep neural network simulation.
xHistoryDNN = repmat(x0',Tsteps+1,1);
uHistoryDNN = repmat(u0',Tsteps,1);
lastMV = u0;
% Run a closed-loop simulation of the trained network and the plant. The neuralnetLKAmove function computes the deep neural network output using the predict function.
for k = 1:Tsteps
    % Obtain plant output measurements, which correspond to the plant outputs.
    xk = xHistoryDNN(k,:)';
    % Predict the next move using the trained deep neural network.
    uk = neuralnetLKAmove(imitateMPCNetObj,xk,lastMV,rho);
    % Store the control action and update the last MV for the next step.
    uHistoryDNN(k,:) = uk;
    lastMV = uk;
    % Update the state using the control action.
    xHistoryDNN(k+1,:) = (A*xk + B*[uk;Vx*rho])';
end
% Plot the results, and compare the MPC controller and trained deep neural network (DNN) trajectories.
plotValidationResultsImLKA(Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
% The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.
