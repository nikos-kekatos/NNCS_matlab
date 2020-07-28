%% Interface Automatic Transmission model with Breach 

%addpath utilities
%% Initialize Variables

 function [phi,rob,BrFalse] = init_quadrotor_full(newfile,specno,mode)

    %newfile='Quad_sim';
    warning('off');
    B = BreachSimulinkSystem(newfile);
    %toc
    %disp("time for interfacing");

    %define the formula
    %STL_ReadFile('stl/mimo_specs.stl');
    phi_s = STL_Formula('phi_s', 'alw_[3,100] ((abs(Z[t+dt]-Z[t]) < epsi1) and (abs(X[t+dt]-X[t]) < epsi1) and (abs(Y[t+dt]-Y[t]) < epsi1) and (abs(Psi[t+dt]-Psi[t]) < epsi1))');
    phi_s = set_params(phi_s,{'dt', 'epsi1'}, [0.1 0.1]);
    phi_r = STL_Formula('phi_r', 'ev_[0,tau1] ((Z[t] > Zd[t]*bt) and (X[t] > Xd[t]*bt) and (Y[t] > Yd[t]*bt))');
    phi_r = set_params(phi_r,{'tau1', 'bt'}, [2.3 0.8]);  
    
    phi_c = STL_Formula('phi_c', 'ev_[0,tau2] alw ((abs(X[t]-Xd[t]) < epsi2) and (abs(Z[t]-Zd[t]) < epsi2) and (abs(Y[t]-Yd[t]) < epsi2))');
    phi_c = set_params(phi_c,{'tau2', 'epsi2'}, [10 .1]);
    phi_o = STL_Formula('phi_o', 'alw ((Z[t] < al*Zd[t]) and (X[t] < al*Xd[t])and (Y[t] < al*Yd[t]))');
    phi_o = set_params(phi_o,{'al'}, [1.25]);
    %phi_sp = STL_Formula('phi_sp', 'alw ((not(((Z[t+dt]-Z[t])*10 > m) and ev_[0,tau] ((Z[t+dt]-Z[t])*10 < -1*m))) and (not(((X[t+dt]-X[t])*10 > m) and ev_[0,tau] ((X[t+dt]-X[t])*10 < -1*m))) and (not(((Y[t+dt]-Y[t])*10 > m) and ev_[0,tau] ((Y[t+dt]-Y[t])*10 < -1*m))))');
    %phi_sp = set_params(phi_sp,{'tau', 'dt','m'}, [10 0.1 0.5]);
    
    phi_all = STL_Formula('phi_all', '(phi_s and phi_r and phi_c and phi_o)');
    phi_all = set_params(phi_all,{'dt','epsi1','tau1','bt','tau2','epsi2','al'}, [0.1 0.1 2.3 0.8 10 .1 1.25]);
    
    if specno==1
      phi=phi_s;
    elseif specno==2
      phi=phi_r;
    elseif specno==3
      phi=phi_c;
    elseif specno==4
      phi=phi_o;
    %elseif specno==5
    %  phi=phi_sp;
    elseif specno==6
      phi=phi_all;  
    end
    %phi=phi_spike;

    %{
    time_u = 0:.1:30;
    Xdes = 1 - 1*exp(-0.5*time_u);
    Ydes = 1 - 1*exp(-0.5*time_u);
    Zdes = 1 - 1*exp(-0.5*time_u);
    Psides = 0.52 - 0.52*exp(-0.5*time_u);
    U = [time_u' Xdes' Ydes' Zdes' Psides'];
    % order matters!
    B.Sim(0:.01:30,U);
    B.PlotSignals();
    return;
    %}

    %{
    %B.SetTime(0:.01:40); % default simulation time
    input_gen.type = 'UniStep'; % uniform time steps
    input_gen.cp = 3; % number of control points
    B.SetInputGen(input_gen);
    B.SetParam({'Xd_u0','Xd_u1','Xd_u2'}, [0 1 2]);
    B.SetParam({'Yd_u0','Yd_u1','Yd_u2'}, [0 1 2]);
    B.SetParam({'Zd_u0','Zd_u1','Zd_u2'}, [0 1 2]);
    B.SetParam({'Psid_u0','Psid_u1','Psid_u2'}, [0 pi/6 pi/3]);
    %B.Sim(0:0.01:40);
    %B.PlotSignals();
    %return;
    %}

    B.SetTime(0:.01:100);
    x_gen = var_step_signal_gen({'Xd','Yd','Zd','Psid'});

    B.SetInputGen(x_gen);                
    %B.SetParam({'Xd_dt0', 'Xd_dt1', 'Xd_dt2'}, ...
    %                  [10 ; 10; 10;]);  
    %B.SetParam({'Yd_dt0', 'Yd_dt1', 'Yd_dt2'}, ...
    %                  [10 ; 10; 10;]); 
    %B.SetParam({'Zd_dt0', 'Zd_dt1', 'Zd_dt2'}, ...
    %                  [10 ; 10; 10;]); 
    %B.SetParam({'Psid_dt0', 'Psid_dt1', 'Psid_dt2'}, ...
    %                  [10 ; 10; 10;]); 
    %{
    B.SetParamRanges({'dt_u0','dt_u1','dt_u2','dt_u3','dt_u4','dt_u5'}, ...
                       [0.1 10; 0.1 10; 0.1 10; .1 10;.1 10;.1 10;]);        
    B.SetParamRanges({'Xd_u0','Xd_u1','Xd_u2'}, ...
                      [0.2 5;0.2 5;0.2 5;]); 
    B.SetParamRanges({'Yd_u0','Yd_u1','Yd_u2'}, ...
                      [0.2 0.5; 0.2 0.5; 0.2 0.5;]);              
    B.SetParamRanges({'Zd_u0','Zd_u1','Zd_u2'}, ...
                      [0.2 3;0.2 3;0.2 3;]);  
    B.SetParamRanges({'Psid_u0','Psid_u1','Psid_u2'}, ...
                      [ 0 0;0 0; 0 0;]);  
    %}
    B.SetParam({'dt_u0'}, ...
                       [100;]);        
    B.SetParamRanges({'Xd_u0'}, ...
                      [4.1 4.4;]); 
    B.SetParamRanges({'Yd_u0'}, ...
                      [0.4 0.6;]);              
    B.SetParamRanges({'Zd_u0'}, ...
                      [2.1 2.3;]);  
    B.SetParam({'Psid_u0'}, ...
                      [ 0;]);  

    %{
    sg = var_step_signal_gen({'Xd'},3);
    B.SetInputGen(sg);                
    B.SetParam({'Xd_dt0', 'Xd_dt1', 'Xd_dt2'}, ...
                      [10 ; 10; 10]);                 
    B.SetParamRanges({'Xd_u0', 'Xd_u1', 'Xd_u2'}, ...
                      [0.1 0.25;0.1 0.25;0.1 0.25]);                 
    %}

    if mode==1  % falsification mode
       disp("falsify");
       disp(phi);
       falsif_pb = FalsificationProblem(B,phi);
    elseif mode==2  %synthesis mode
       disp("synthesis");  
       disp(get_params(phi_mod));
       falsif_pb = FalsificationProblem(B,phi_mod);
    end   
    falsif_pb.max_time = 180;
    falsif_pb.StopAtFalse=false;
    falsif_pb.solve();
    rob=falsif_pb.obj_best;
    if rob>=0
         BrFalse='';
         return;
    end
    BrFalse = falsif_pb.GetBrSet_False();
    BrFalse=BrFalse.BrSet; 
    BrFalse.PlotRobustSat(phi);

%     end

%     figure
%     BrFalse.PlotSigPortrait('X');
%     figure
%     BrFalse.PlotSigPortrait('Y');
%     figure
%     BrFalse.PlotSigPortrait('Z');
%     BrFalse = falsif_pb.GetBrSet_False();
%     BrFalse=BrFalse.BrSet;
% 
%     %figure    
%     %BrFalse.PlotSignals();
%     figure
%     BrFalse.PlotRobustSat(phi);