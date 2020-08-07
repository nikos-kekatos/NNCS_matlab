function [ref,y,u] = sim_SLX(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.
if options.model==4
    load  PIDGainSchedExample
elseif options.model==5
    run('quad_variables.m')
elseif options.model==7
    Kp=0.0055;
    Ki=0.0131;
    Kd=3.3894e-004;
    N=9.9135;
end
if options.combination
    options.workspace = simset('SrcWorkspace','current');
    
    % controller gains as C{i}.Kp, .Ki, .Kd
    
    C=options.controllers.C;
    
    contNb=length(C);
    % time_res=1;
    % no_time_segments=options.T_train/time_res;
    % timeNb=no_time_segments;
    try
        timeNb=options.no_time_segments;
        timeNb_step=options.time_segments_step;
    catch
        if options.model==10
            timeNb=10;
            timeNb_step=1;
        end
    end
    
    for timeId = 1:timeNb_step:timeNb
        
        Jopt= 1e6;
        
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
            
            set_param(strcat(options.SLX_model,'/Controller/PID Controller'),'P',num2str(C{contID}.Kp), ...
                'I',num2str(C{contID}.Ki),'D',num2str(C{contID}.Kd),'N',num2str(C{contID}.N));
            
            
            sim(model,[],options.workspace);
            if options.combination_matlab==1
                Jcurrent(timeId,contID) = compute_cost_function(ref,u,y,options);

            elseif options.combination_matlab==0 % use Simulink and existing cost function
                Jcurrent(timeId,contID) = J.Data(end);
                
            end
            if (Jcurrent(timeId,contID)<=Jopt)
                    Jopt=Jcurrent(timeId,contID);
                    SimStateopt = SimState;
                    min_cost(timeId)=contID;
                    ref_opt{timeId}=ref;
                    y_opt{timeId}=y;
                    u_opt{timeId}=u;            
            end
        end
        if options.plotting_sim
        fprintf('For the %i-segment, the Controller %i has the smallest cost.\n\n',timeId,min_cost(timeId));
        else
            if timeId==1
                fprintf('For the %i-segment, the Controller %i has the smallest cost.\n\n',timeId,min_cost(timeId));
            end
        end
        SimState_previous=SimStateopt;
    end
    Jcurrent
    
    % ref_opt is the combined structure
    clearvars ref y u
    y.signals.values=[];
    ref.signals.values=[];
    u.signals.values=[];
    ref.time=[];u.time=[];y.time=[];
    
    
    for ii=1:timeNb
        if ii<timeNb
            ref_temp_time=ref_opt{ii}.time(1:(end-1));
            ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
            u_temp_time=u_opt{ii}.time(1:(end-1));
            u_temp_values=u_opt{ii}.signals.values(1:(end-1));
            y_temp_time=y_opt{ii}.time(1:(end-1));
            y_temp_values=y_opt{ii}.signals.values(1:(end-1));
        elseif ii==timeNb
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
        plot_single_trace(ref,y,u,options);
        figure;plot(min_cost,'o-')
        xlabel('time segments (s)')
        ylabel('contoller choice -- 1...no\_controllers')
    else
        if timeId==1
            plot_single_trace(ref,y,u,options)
            figure;plot(min_cost,'o-')
            xlabel('time segments (s)')
            ylabel('contoller choice -- 1...no\_controllers')
        end
    end

else
    options.workspace = simset('SrcWorkspace','current');
    sim(model,[],options.workspace);
end
end

