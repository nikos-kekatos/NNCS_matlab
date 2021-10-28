% no_attempts=1000;
no_viol_nom=0;

for i=1:no_attempts
    if i==floor(no_attempts)/4
        fprintf('\nThis is iteration %i out of %i attempts.\n',i,no_attempts);
    elseif i==floor(no_attempts)/2
        fprintf('\nThis is iteration %i out of %i attempts.\n',i,no_attempts);
    elseif i==floor(no_attempts)*3/4
        fprintf('\nThis is iteration %i out of %i attempts.\n',i,no_attempts);
    elseif i==1
        fprintf('\nThis is iteration %i out of %i attempts.\n',i,no_attempts);
    end
    x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
    u0 = 2.08*(rand-0.5); % Steering angle: range (-60,60) deg
    rho = 0.02*(rand-0.5); % Curvature: range (-0.01,0.01), minimum road radius 100m.
    Tsteps=3/mpcobj.Ts;
    run('simulate_mpc.m')
    
    
    v_mpc=xHistoryMPC(:,1);
    x_mpc=xHistoryMPC(:,3);
    r_mpc = BreachRequirement('alw_[2.2,3](x_mpc[t]>-0.55 and x_mpc[t]<0.55 and v_mpc[t]>-0.65 and v_mpc[t]<0.65)');
    
    t = 0:sys.Ts:3;
    Var_mpc=[v_mpc,x_mpc]';
    
    nominal_rob{i}=r_mpc.Eval(t,Var_mpc);
    
    if nominal_rob{i}<=0
        no_viol_nom=no_viol_nom+1;
        
        fprintf("The MPC trace %i is violated. There are %i violations so far.\n\n",i,no_viol_nom);
        
%         if choice_plot_cex
%             plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
%         end
    end
end