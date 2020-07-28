function [ref,y,u] = sim_SLX_thao_v2(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.

options.workspace = simset('SrcWorkspace','current');

% controller gains as C{i}.Kp, .Ki, .Kd



C{1}.Kp = 1.00184216792805;
C{1}.Ki = 0.0715029518361115;
C{1}.Kd = -0.0337374499215529;
C{1}.N=25.8481850830944;

C{2}.Kp = 3;%20.8521889762703;
C{2}.Ki = 1;%19.9734819620964;
C{2}.Kd = 0.820834909861585;
C{2}.N=18.1644836383948;

C{3}.Kp = 6.72200601587379;
C{3}.Ki = 2.26506770923699;
C{3}.Kd = -1.4447806890366;
C{3}.N=4.53935325696756;

contNb=length(C);
% time_res=1;
% no_time_segments=options.T_train/time_res;
% timeNb=no_time_segments;
timeNb=10;

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
    
    if timeId<=1 %first time horizon
        set_param(model, 'LoadInitialState','off');
        %set_param(model, 'SaveFinalState','on',...
        %'FinalStateName', 'SimState',...
        %'SaveOperatingPoint', 'on');
    else
        set_param(model,'LoadInitialState','on',...
            'InitialState','SimState_previous');
    end
    
    %set_param(model,'SaveFinalState','on',...
    %   'FinalStateName','SimState',...
    %    'SaveOperatingPoint','on');
    
    
    set_param(model,'StartTime',num2str(starttime),...
        'StopTime',num2str(stoptime));
    
    
    %%% For Matlab earlier than 2019a
    set_param(model,'SaveFinalState', 'on',...
        'FinalStateName', 'SimState');
    
    for contID = 1:contNb
%         disp('New segment');
        timeId;
        contID;
        starttime;
        stoptime;
        %set_param(model,'LoadInitialState','on','InitialState',...
        %'xFinal','SaveFinalState','on','FinalStateName',...
        %'xFinal','SaveOperatingPoint','on')
        
        %set_param(model,'StartTime','10','StopTime','20','LoadInitialState','on','InitialState',...
        %'SimState','SaveFinalState','on','FinalStateName',...
        %'xFinal','SaveOperatingPoint','on') 
        
        set_param('watertank_multPID_2018a_v3/Controller/PID Controller','P',num2str(C{contID}.Kp), ...
            'I',num2str(C{contID}.Ki),'D',num2str(C{contID}.Kd),'N',num2str(C{contID}.N));
        
        
        sim(model,[],options.workspace);
        
        Jcurrent(timeId,contID) = J.Data(end);
        if (Jcurrent(timeId,contID)<=Jopt)
            Jopt=Jcurrent(timeId,contID);
            SimStateopt = SimState;
            min_cost(timeId)=contID;
            ref_opt{timeId}=ref;
            y_opt{timeId}=y;
            u_opt{timeId}=u;

        end
        
    end
    fprintf('For the %i-segment, the Controller %i has the smallest cost.\n\n',timeId,min_cost(timeId));
    SimState_previous=SimStateopt;
end
Jcurrent

% ref_opt is the combined structure
clearvars ref y u
y.signals.values=[];
ref.signals.values=[];
u.signals.values=[];
ref.time=[];
for ii=1:timeNb
    if ii<timeNb
        ref_temp_time=ref_opt{ii}.time(1:(end-1));
        ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
%         u_temp_time=u_opt{ii}(1:(end-1));
        u_temp_values=u_opt{ii}.signals.values(1:(end-1));
%         y_temp_time=y_opt{ii}(1:(end-1));
        y_temp_values=y_opt{ii}.signals.values(1:(end-1));       
    elseif ii==timeNb
        ref_temp_time=ref_opt{ii}.time
        ref_temp_values=ref_opt{ii}.signals.values
        u_temp_values=u_opt{ii}.signals.values(1:(end-1));
        y_temp_values=y_opt{ii}.signals.values(1:(end-1));       
    end
    if ii==1
        ref.time=[ref_temp_time]
    else
        ref.time=[ref.time;ref.time(end)+ ref_temp_time]
    end
    y.signals.values=[y.signals.values;y_temp_values]
    u.signals.values=[u.signals.values;u_temp_values]
    ref.signals.values=[ref.signals.values;ref_temp_values]
end
%%% This is only for a quick test. We need to set the parameters of
%%% the PID

%{
%% This is for a test, change the Propotional gain of PID
kp=kp*contID;
set_param('watertank_multPID_2018a_v3/Controller/PID Controller','P',num2str(kp));


sim(model,[],options.workspace);
Jcurrent = J.Data(end)


%% Finding the optimal controller
if (Jcurrent<=Jopt)
    SimStateopt = SimState
end



input('done with one reference. Please press ENTER')
end
%}