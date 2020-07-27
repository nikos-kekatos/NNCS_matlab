function [ref,y,u] = sim_SLX(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.

options.workspace = simset('SrcWorkspace','current');


kp = 20.8521889762703;
ki = 19.9734819620964;
kd = 820834909861585;
 
contNb=2;
timeNb=2;


for timeId = 1:timeNb 
    
    Jopt= 10000000000;
    
    
        
    %set_param(model,'StartTime',num2str(starttime),'StopTime',num2str(stoptime),...
    %'SaveFinalState','on',...
    %'FinalStateName','SimState','SaveOperatingPoint','on')
    
    %'SaveCompleteFinalSimState','on')
    %set_param(model,'StopTime','10','SaveFinalState','on',...
    %'FinalStateName','SimState','SaveOperatingPoint','on')

   
    starttime=1*(timeId-1);
    stoptime=1*timeId;
   
   
    for contId = 1:contNb 
       disp('New segment');  
       timeId
       contId
       starttime
       stoptime
       %set_param(model,'LoadInitialState','on','InitialState',...
       %'xFinal','SaveFinalState','on','FinalStateName',...
       %'xFinal','SaveOperatingPoint','on')

       %set_param(model,'StartTime','10','StopTime','20','LoadInitialState','on','InitialState',...
       %'SimState','SaveFinalState','on','FinalStateName',...
       %'xFinal','SaveOperatingPoint','on')
       
       
       
      
       
       
       if timeId<=1 %first time horizon
           set_param(model, 'LoadInitialState','off');
           %set_param(model, 'SaveFinalState','on',...
           %'FinalStateName', 'SimState',...
           %'SaveOperatingPoint', 'on');
       else
           set_param(model,'LoadInitialState','on',...
           'InitialState','SimStateopt');
       end
       
       %set_param(model,'SaveFinalState','on',...
       %   'FinalStateName','SimState',...
       %    'SaveOperatingPoint','on');
       
       
       set_param(model,'StartTime',num2str(starttime),...
           'StopTime',num2str(stoptime));
       
       
       %%% For Matlab earlier than 2019a
       set_param(model,'SaveFinalState', 'on',...
             'FinalStateName', 'SimState');
       
       
           
       %%% This is only for a quick test. We need to set the parameters of
       %%% the PID
       
       %% This is for a test, change the Propotional gain of PID
       kp=kp*contId;
       set_param('watertank_multPID/Controller/PID Controller','P',num2str(kp));

       
       sim(model,[],options.workspace);
       
       Jcurrent = J.Data(end)
       
       %% Finding the optimal controller
       if (Jcurrent<=Jopt) 
           SimStateopt = SimState
       end
    end
 end 
 
 input('done with one reference. Please press ENTER')
end
