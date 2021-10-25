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
            xHistoryDNN(k+1,:) = (sys.A*xk + sys.B*[uk;Vx*rho])';
        end
        % Plot the results, and compare the MPC controller and trained deep neural network (DNN) trajectories.
        %     plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
        % The neural network successfully imitates the behavior of the MPC controller. The vehicle state and control action trajectories for the controller and the deep neural network closely align.
        