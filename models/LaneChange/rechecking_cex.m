disp('===========================')
disp(' CEX Elimination')
cex_temp=cex_values(i_f,:);
CEX=cex_temp(~cellfun('isempty',cex_temp));
viol_cex_dnn=zeros(length(CEX),1);
outcome_cex_dnn=zeros(length(CEX),1);
v_dnn=[];x_dnn=[];x0=[];u0=[];rho=[];r_dnn_cex=[];Var_dnn=[];
for i=1:numel(CEX)
    
    %% Falsification with random points
    x0 = CEX{i}.x0;
    u0 = CEX{i}.u0;
    rho = CEX{i}.rho;
    
    run('simulation_traces_dnn_mpc.m')
    
    %% STL evaluation
    
    v_dnn=xHistoryDNN(:,1);v_mpc=xHistoryMPC(:,1);
    x_dnn=xHistoryDNN(:,3);x_mpc=xHistoryMPC(:,3);
    r_dnn_cex = BreachRequirement('alw_[2,3](x_dnn[t]>-0.5 and x_dnn[t]<0.5 and v_dnn[t]>-0.5 and v_dnn[t]<0.5)');
    %         r_mpc = BreachRequirement('alw_[2,3](x_mpc[t]>-0.5 and x_mpc[t]<0.5 and v_mpc[t]>-0.5 and v_mpc[t]<0.5)');
    
    %         t = 0:sys.Ts:3;
    Var_dnn=[v_dnn,x_dnn]';
    %         Var_mpc=[v_mpc,x_mpc]';
    
    outcome_cex_dnn(i)=r_dnn_cex.Eval(t,Var_dnn);
    %         outcome_mpc{i_f,i}=r_mpc.Eval(t,Var_mpc);
    if outcome_cex_dnn(i)<=0
        viol_cex_dnn(i)=1;
    end
end
fprintf('\n\n After rechecking, there are still %i CEX out of the original %i.\n\n',sum(viol_cex_dnn),numel(CEX))