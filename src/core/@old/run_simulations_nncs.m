function [data,options] = run_simulations_nncs(model,options)
%run_simulations calls the Simulink model and runs multiple simulations
%   The Simulink model with the nominal controller is called. Different
%   initial conditions and configuration parameters are defined via the
%   options structure.

% Note that here we were handling the most complicated case that the length
% of REF was not the same with U and Y. This was the case because the
% sampling time of the Random Reference block was inherited (sample time=-1).

REF_struct=[];
U_struct=[];
Y_struct=[];
t_comput=[];

if options.reference_type==1 % constant reference
    simin_all_constant=combvec(options.simin_ref,options.simin_x0);
elseif options.reference_type==2
    simin_all_varying=repmat(options.simin_x0,[1 options.no_ref]);
end

for i=1:options.no_traces
    if  options.reference_type==1
        options.sim_ref= simin_all_constant(1,i);
        options.sim_x0=simin_all_constant(2,i);
    end
    if options.reference_type==2
        options.sim_x0=simin_all_varying(i);
        options.sim_ref=options.simin_ref;
    end
    fprintf('Beginning of iteration %i\n',i);
    tic;
    [ref,y,u]=sim_SLX(model,options);
    %     sim(model);
    % sim constructs ref,u and y variables
    t_comput{i}=toc;
    
    fprintf('End of iteration %i\n\n',i);
    
    REF_struct=[REF_struct;ref];
    U_struct=[U_struct;u];
    Y_struct=[Y_struct;y];
end

if options.plotting_sim
    if options.reference_type==2
        temp.ref_time=ref.time([1, end])
        temp.ref_time_new=temp.ref_time(1):options.dt:temp.ref_time(2);
        temp.ref_time_new=temp.ref_time_new(1:end-1);
        temp.ref_values=[];
        for i=1:options.no_setpoints
            temp.ref_values=[temp.ref_values,repmat(ref.signals.values(i),[1,length(temp.ref_time_new)/options.no_setpoints])];
        end
        figure;plot(temp.ref_time_new,temp.ref_values,'--r',y.time,y.signals.values)
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
    else
        figure;plot(ref.time,ref.signals.values,'--r',y.time,y.signals.values,'x')
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
    end
end
if options.save_sim
    if ~isfield(options,'sim_name')
        if options.reference_type==1
            temp_st='constant_ref_';
        else
            temp_st='varying_ref_';
        end
        if options.error_sd~=0
            temp_st=strcat(temp_st,'perturb_',num2str(options.error_sd),'_');
        end
        options.sim_name= strcat('struct_sim_',temp_st,num2str(options.no_traces),'_traces_',num2str(options.no_ref),'x',num2str(options.no_x0),'_time_',num2str(options.T_train),'_',datestr(now,'dd-mm-yyyy_HH:MM'),'.mat');
    end
    destination_folder={strcat('../outputs/robotarm/'),...
        strcat('../../outputs/robotarm/'),...
        strcat('../../../outputs/robotarm/')};
    ic=1;
    while ic<=length(destination_folder)
        if exist(destination_folder{ic},'dir')
            destination_name=strcat(destination_folder{ic},char(options.sim_name));
            break;
        else
            ic=ic+1;
        end
    end
    save(destination_name,'REF_struct','U_struct','Y_struct');
end

[REF,Y,U]=from_traces_to_training_data(REF_struct,Y_struct,U_struct,options);
fprintf('The simulation data are saved as a structure named %s.\n\n',char(options.sim_name));
fprintf('The simulation data are saved as a structure in %s.\n\n',destination_folder{ic});
% remove slprj
rmdir('slprj','s')
delete robotarm_PID.slxc
data.REF=REF;
data.U=U;
data.Y=Y;
end

