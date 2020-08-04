function [data,options] = trace_generation_nncs_td(model,options)
%run_simulations calls the Simulink model and runs multiple simulations
%   The Simulink model with the nominal controller is called. Different
%   initial conditions and configuration parameters are defined via the
%   options structure.

% Note that here we specify the sampling time of the REF so that the ref, y
% and u always have the same size. This can be done by replacing the
% sampling time of the ref block from -1 to dt.

REF_struct=[];
U_struct=[];
Y_struct=[];
t_comput=[];

if options.reference_type==1 % constant reference
    simin_all_constant=combvec(options.simin_ref,options.simin_x0);
elseif options.reference_type==2 % time-varying
    simin_all_varying=repmat(options.simin_x0,[1 options.no_ref]);
elseif options.reference_type==3 % coverage
    sim_cov_ref=[];
    for i_cov=1:options.coverage.no_traces_ref
        if options.coverage.points=='r'
            sim_cov_ref=[sim_cov_ref,options.coverage.cells{i_cov}.random_value];
        elseif options.coverage.points=='c'
            sim_cov_ref=[sim_cov_ref,options.coverage.cells{i_cov}.centers];
        end
    end
    simin_all_coverage=combvec(sim_cov_ref,options.simin_x0);    
end

if options.reference_type~=4
    for i=1:options.no_traces
        if  options.reference_type==1
            options.sim_ref= simin_all_constant(1,i);
            options.sim_x0=simin_all_constant(2,i);
            options.sim_cov=0;
        end
        if options.reference_type==2
            options.sim_x0=simin_all_varying(i);
            options.sim_ref=options.simin_ref;
            options.sim_cov=0;
        end
        if options.reference_type==3
            options.sim_x0=simin_all_coverage(end,i); %last row is x0
            options.sim_ref=0;
            options.sim_cov=simin_all_coverage(1:end-1,i); %
        end
        fprintf('Beginning of iteration %i\n',i);
        tic;
        warning off
        if ~iscell(model) 
            [ref,y,u]=sim_SLX_thao_v2(model,options);
            t_comput{i}=toc;
        
            fprintf('End of iteration %i\n\n',i);
        
            REF_struct=[REF_struct;ref];
            U_struct=[U_struct;u];
            Y_struct=[Y_struct;y];
        end
        if iscell(model) && length(model)==1
            [ref,y,u]=sim_SLX_thao_v2(model{1},options);
            t_comput{i}=toc;        
            fprintf('End of iteration %i\n\n',i);
        
            REF_struct=[REF_struct;ref];
            U_struct=[U_struct;u];
            Y_struct=[Y_struct;y];
        elseif iscell(model) && length(model)>1
            model_no=length(model);
            for ii=1:model_no
                options_comb{ii}=options;
                if ii==1
                    options_comb{ii}.T_train=1.5;
                elseif ii==2
                    options_comb{ii}.T_train=options.T_train-1.5;
                    options_comb{ii}.x0=y_temp{ii-1}.signals.values(end);
                    fprintf('The last value for y is %i.\n\n',y_temp{ii-1}.signals.values(end));
                end
                [ref_temp{ii},y_temp{ii},u_temp{ii}]=sim_SLX(model{ii},options_comb{ii});
                if i==1 && options.plotting_sim
                    plot_single_trace(ref_temp{ii},y_temp{ii},u_temp{ii},options)
                end
            end
            t_comput{i}=toc;
            
            fprintf('End of iteration %i\n\n',i);
            % only works for 2d need to extend
            %{
            ref=[];u=[];y=[];
            sampling_times=ref_temp{1}.time;
            for j=1:model_no
                sampling_times=[sampling_times;ref_temp{j}.time]
                ref.signals.values=[ref.signals.val]                    
            end
            %}
            ref.time=[ref_temp{1}.time(1:(end-1));ref_temp{2}.time(1:(end-1))+ref_temp{1}.time(end)];
               u.time=ref.time;
               y.time=ref.time;
               u.signals.values=[u_temp{1}.signals.values(1:(end-1));u_temp{2}.signals.values(1:(end-1))]
               ref.signals.values=[ref_temp{1}.signals.values(1:(end-1));ref_temp{2}.signals.values(1:(end-1))]
               y.signals.values=[y_temp{1}.signals.values(1:(end-1));y_temp{2}.signals.values(1:(end-1))]

            REF_struct=[REF_struct;ref];
            U_struct=[U_struct;u];
            Y_struct=[Y_struct;y];
        end
        %     sim(model);
        % sim constructs ref,u and y variables
        
    end
    
    if options.plotting_sim
        %     if options.reference_type==2
        %         temp.ref_time=ref.time([1, end])
        %         temp.ref_time_new=temp.ref_time(1):options.dt:temp.ref_time(2);
        %         temp.ref_time_new=temp.ref_time_new(1:end-1);
        %         temp.ref_values=[];
        %         for i=1:options.no_setpoints
        %             temp.ref_values=[temp.ref_values,repmat(ref.signals.values(i),[1,length(temp.ref_time_new)/options.no_setpoints])];
        %         end
        %         figure;plot(temp.ref_time_new,temp.ref_values,'--r',y.time,y.signals.values)
        %         xlabel('time (sec)')
        %         ylabel ('angle (rad)')
        %         legend('ref','y')
        %         title('Random Simulation Trace')
        %     else
        figure;plot(ref.time,ref.signals.values,'--r',y.time,y.signals.values)
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
        %     end
    end
    if options.save_sim
        if ~isfield(options,'sim_name')
            if options.reference_type==1
                temp_st='constant_ref_';
            elseif options.reference_type==2
                temp_st='varying_ref_';
            elseif options.reference_type==3
                temp_st='cov_varying_ref_';
            end
            if options.error_sd~=0
                temp_st=strcat(temp_st,'perturb_',num2str(options.error_sd),'_');
            end
            options.sim_name= strcat('struct_sim_',temp_st,num2str(options.no_traces),'_traces_',num2str(options.no_ref),'x',num2str(options.no_x0),'_time_',num2str(options.T_train),'_',datestr(now,'dd-mm-yyyy_HH:MM'),'.mat');
        end
        
        warning('Fix issue with folder names. Probably add a flag with the corresponding folder. Or use which to find dir.\n');
        folder= 'robotarm';
        folder='quadcopter';
        folder='watertank';
        folder='tank';
        folder='MatlabQuadSimAP-master';
        
        destination_folder={
            %            strcat('modules/outputs/robotarm/'),...
            %            strcat('outputs/robotarm/'),...
            strcat('../outputs/',[folder],'/'),...
            strcat('../../outputs/',[folder],'/'),...
            strcat('../../../outputs/',[folder],'/')};
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
    if options.save_sim~=0
        fprintf('The simulation data are saved as a structure named %s.\n\n',char(options.sim_name));
        fprintf('The simulation data are saved as a structure in %s.\n\n',destination_folder{ic});
    end
    data.REF=REF;
    data.U=U;
    data.Y=Y;
    try
        delete([options.SLX_model,'.slxc'])
    end
elseif options.reference_type==4
    data=run_simulations_Breach(options);
    try
        delete([options.SLX_model,'_breach.slxc']);
    end
end
options.num_REF=size(data.REF,2);
options.num_Y=size(data.Y,2);
options.num_U=size(data.U,2);

% remove slprj
rmdir('slprj','s');

end
