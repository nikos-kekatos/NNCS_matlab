function [ref,y,u,options,y_nn,u_nn,J_current] = sim_SLX(model_name,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.
if options.model==4
    load  e4_PIDGainSchedExample
elseif options.model==5
    run('quad_variables.m')
elseif options.model==7
    Kp=0.0055;
    Ki=0.0131;
    Kd=3.3894e-004;
    N=9.9135;
elseif options.model==6
    s=tf('s');
    K1=(-6.694*(s+0.9446)*(s+50.01))/((s^2+13.23*s+9.453^2)*(s+50.05));
    K2=(-2187^2*(s+0.9977)*(s+66.28))/((s^2+467.2*s+486.2^2)*(s+507));
    P=-1000/(s*(s+.875)*(s+50));
    ss1=ss(K1);
    ss2=ss(K2);
    sysP=ss(P);
elseif options.model==8 % lookuptable
    load('initialize.mat')
elseif options.model==9
    PID_THRESH=0.3;
end
get_param(Simulink.allBlockDiagrams(),'Name');
load_system(model_name)
if options.combination
    options.workspace = simset('SrcWorkspace','current');
    
    % controller gains as C{i}.Kp, .Ki, .Kd
    
    C=options.controllers.C;
    
    contNb=length(C);
    % time_res=1;
    % no_time_segments=options.T_train/time_res;
    % timeNb=no_time_segments;
    try
        timeNb= options.T_segments; %% change the name (time horizon)
        timeNb_step=options.time_step_segments;
    catch
        if options.model==10
            timeNb=10;
            timeNb_step=2;
        end
    end
    if mod(timeNb,timeNb_step)==0 % equal segment time steps
        timeId_span=0:timeNb_step:timeNb;
    else % not equal time segments
        % T=10, tau=3
        % solution: 0:3:9 and 10,
        % segments:[0,3], [3,6], [6,9], [9,10]
        timeId_span=0:timeNb_step:floor(timeNb/timeNb_step)*timeNb_step;
        timeId_span=[timeId_span, timeNb];
    end
    if options.debug
        timeId_span
    end
    segment_Id=0;
    for timeId = timeId_span(1:end-1)
        segment_Id=segment_Id+1;
        if options.combination_matlab==1 || options.combination_matlab==0 %cost function, find the minimum
            Jopt= 1e9;
        elseif options.combination_matlab==2
            Jopt= -1e9;
        end
        starttime=timeId;
        stoptime=timeId+timeNb_step;
        if stoptime>timeNb % the case when the intervals are not equal
            stoptime=timeNb;
        end
        if segment_Id==1 %first time horizon
            set_param(model_name, 'LoadInitialState','off');
            %set_param(model, 'SaveFinalState','on',...
            %'FinalStateName', 'SimState',...
            %'SaveOperatingPoint', 'on');
        else
            set_param(model_name,'LoadInitialState','on',...
                'InitialState','SimState_previous');
        end
        
        set_param(model_name,'StartTime',num2str(starttime),...
            'StopTime',num2str(stoptime));
        
        %%% For Matlab earlier than 2019a
        set_param(model_name,'SaveFinalState', 'on',...
            'FinalStateName', 'SimState');
        
        for contID = 1:contNb
            %         disp('New segment');
            timeId;
            segment_Id;
            contID;
            starttime;
            stoptime;
            
            set_param(strcat(options.SLX_model,'/Controller/PID Controller'),'P',num2str(C{contID}.Kp), ...
                'I',num2str(C{contID}.Ki),'D',num2str(C{contID}.Kd),'N',num2str(C{contID}.N));
            
            
            sim(model_name,[],options.workspace);
            if options.combination_matlab==1
                Jcurrent(segment_Id,contID) = compute_cost_function(ref,u,y,options);
                
            elseif options.combination_matlab==0 % use Simulink and existing cost function
                Jcurrent(segment_Id,contID) = J.Data(end);
            elseif options.combination_matlab==2
                [Jcurrent(segment_Id,contID),options] = compute_robustness(ref,u,y,options);
            end
            if options.combination_matlab==1||options.combination_matlab==0
                if (Jcurrent(segment_Id,contID)<=Jopt)
                    Jopt=Jcurrent(segment_Id,contID);
                    SimStateopt = SimState;
                    min_cost(segment_Id)=contID;
                    ref_opt{segment_Id}=ref;
                    y_opt{segment_Id}=y;
                    u_opt{segment_Id}=u;
                end
            elseif options.combination_matlab==2
                if (Jcurrent(segment_Id,contID)>=Jopt)
                    Jopt=Jcurrent(segment_Id,contID);
                    SimStateopt = SimState;
                    min_cost(segment_Id)=contID;
                    ref_opt{segment_Id}=ref;
                    y_opt{segment_Id}=y;
                    u_opt{segment_Id}=u;
                end
            end
        end
        if options.debug
            if options.plotting_sim
                fprintf('For the %i-segment, the Controller %i has the smallest cost.\n\n',segment_Id,min_cost(segment_Id));
            else
                if segment_Id==1
                    fprintf('For the %i-segment, the Controller %i has the smallest cost.\n\n',segment_Id,min_cost(segment_Id));
                end
            end
        end
        SimState_previous=SimStateopt;
    end
    if options.debug
        Jcurrent
    end
    % ref_opt is the combined structure
    clearvars ref y u
    y.signals.values=[];
    ref.signals.values=[];
    u.signals.values=[];
    ref.time=[];u.time=[];y.time=[];
    
    
    for ii=1:segment_Id
        if ii<segment_Id
            ref_temp_time=ref_opt{ii}.time(1:(end-1));
            ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
            u_temp_time=u_opt{ii}.time(1:(end-1));
            u_temp_values=u_opt{ii}.signals.values(1:(end-1));
            y_temp_time=y_opt{ii}.time(1:(end-1));
            y_temp_values=y_opt{ii}.signals.values(1:(end-1));
        elseif ii==segment_Id
            ref_temp_time=ref_opt{ii}.time;
            ref_temp_values=ref_opt{ii}.signals.values;
            u_temp_values=u_opt{ii}.signals.values;
            y_temp_values=y_opt{ii}.signals.values;
            u_temp_time=u_opt{ii}.time;
            y_temp_time=y_opt{ii}.time;
        end
        %{
    if ii==1
        ref.time=[ref_temp_time]
    else
        ref.time=[ref.time;ref.time(end)+ ref_temp_time]
    end
        %}
        ref.time=[ref.time;ref_temp_time];
        u.time=[u.time;u_temp_time];
        y.time=[y.time;y_temp_time];
        y.signals.values=[y.signals.values;y_temp_values];
        u.signals.values=[u.signals.values;u_temp_values];
        ref.signals.values=[ref.signals.values;ref_temp_values];
    end
    if options.plotting_sim
        if options.debug
            plot_single_trace(ref,y,u,options);
        end
        figure;plot(min_cost,'o-')
        xlabel('no time segments)')
        ylabel('contoller choice -- 1, 2, ...')
    else
        if options.debug
            if timeId==1
                plot_single_trace(ref,y,u,options)
                figure;plot(min_cost,'o-')
                xlabel('no time segments')
                ylabel('contoller choice -- 1, 2, ...')
            end
        end
    end
    
else
    options.workspace = simset('SrcWorkspace','current');
    sim(model_name,[],options.workspace);
end
if ~exist('y_nn','var')
    y_nn=[];
end
if ~exist('u_nn','var')
    u_nn=[];
end
if ~exist('J_current','var')
    J_current=[];
end
end

