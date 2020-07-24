function [ref,y,u] = sim_SLX(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.

options.workspace = simset('SrcWorkspace','current');


 %kp = 20.8521889762703;
 %ki = 19.9734819620964;
 %kd = 820834909861585;
 
contNb=2;
timeNb=2;

for timeId = 1:timeNb 
    
    
    if (timeId==1)
        set_param(model,'LoadInitialState','off')
    end
        
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
       
       
       
       kgain=num2str(2*contId)

       set_param('watertank_multPID/Controller/Gain','Gain',num2str(kgain));

       if timeId<=1
           set_param(model,'StartTime',num2str(starttime),'StopTime',...
           num2str(stoptime),...
           'SaveFinalState','on',...
           'FinalStateName','SimState',...
           'SaveOperatingPoint','on',...
           'SaveOutput','on','OutputSaveName','youtNew');
       else
           set_param(model,'LoadInitialState','on','InitialState',...
           'SimStateopt',...
           'SaveFinalState','on',...
           'FinalStateName','SimState','SaveOperatingPoint','on',...
           'SaveOutput','on','OutputSaveName','youtNew');
           set_param(model,'StartTime',num2str(starttime),'StopTime',...
           num2str(stoptime));
       end
       
       sim(model,[],options.workspace);
       
       if (contId==contNb) 
           SimStateopt = SimState
       end
    end
 end 
 
 input('done with one reference. Please press ENTER')
end
