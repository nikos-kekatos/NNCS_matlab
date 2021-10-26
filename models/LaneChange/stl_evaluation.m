t = 0:sys.Ts:3;
        Var_dnn=[v_dnn,x_dnn]';
        Var_mpc=[v_mpc,x_mpc]';
        
        outcome_dnn{i_f,i}=r_dnn.Eval(t,Var_dnn);
        outcome_mpc{i_f,i}=r_mpc.Eval(t,Var_mpc);
        if outcome_dnn{i_f,i}<=0
            viol_dnn{i_f,i}=1;
        elseif outcome_dnn{i_f,i}>0
            viol_dnn{i_f,i}=0;
        end
        if outcome_mpc{i_f,i}<=0
            viol_mpc{i_f,i}=1;
        elseif outcome_mpc{i_f,i}>0
            viol_mpc{i_f,i}=0;
        end
        if outcome_dnn{i_f,i}<=0
            no_viol{i_f}=no_viol{i_f}+1;
            cex_values{i}.x0=x0;
            cex_values{i}.u0=u0;
            cex_values{i}.rho=rho;

            fprintf("The DNN trace %i is violated. There are %i violations so far.\n\n",i,no_viol{i_f});
            if outcome_mpc{i_f,i}<=0
                no_viol_mpc{i_f}=no_viol_mpc{i_f}+1;
                
                fprintf("The MPC trace %i is also violated. \n\n",i);
            else
                fprintf("The MPC trace %i is not violated. \n\n",i);
            end
            
            if choice_plot_cex
                plotValidationResultsImLKA(sys.Ts,xHistoryDNN,uHistoryDNN,xHistoryMPC,uHistoryMPC);
            end
        end