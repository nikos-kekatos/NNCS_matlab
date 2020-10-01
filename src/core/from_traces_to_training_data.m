function [REF,Y,U] = from_traces_to_training_data(REF_struct,Y_struct,U_struct,options)
%save_traces From simulation traces obtain arrays
%   The simulation traces are stored as a structure array. This
%   multidimensional structure stores each trace as a different structure.
%   The structures have three fields, including time. Each of the ref, y,
%   and u should have the same dimensions. Also, the points generated at
%   the end of the traces should be discarded. Then, all the traces are
%   composed together and saved as an array.
%

%% Preprocessing -- a common issue

% we can delete the last time point at example the time_horizon
% we do not have enough information apart from one instance when our
% controller tries to reach the new reference point.
% for time horizon =30 s and sampling time of the reference =10, we should
% have 3 reference/setpoints but instead we have 4. Also, we should have
% 10/dt=10/0.02=500 points. So in total 3*500=1500 instead of 1501.
random_index=randi(length(U_struct),1);
u=U_struct(random_index);
if options.plotting_sim
    figure; plot(u.time,u.signals.values,'x',max(u.time),u.signals.values(end),'ro','MarkerSize',8);
    xlabel('time (s)')
    ylabel ('u')
    title('Random Simulation Trace')
    % we need to delete last element from all Y_new, U_new and REF_new
end
if mod(options.T_train,options.ref_Ts)==0
    if options.debug
        fprintf('Last point of all traces will be deleted.\n');
    end
    for i=1:numel(U_struct)
        U_struct(i).time=U_struct(i).time(1:end-1,:);
        U_struct(i).signals.values=U_struct(i).signals.values(1:end-1,:);
        Y_struct(i).time=Y_struct(i).time(1:end-1,:);
        Y_struct(i).signals.values=Y_struct(i).signals.values(1:end-1,:);
        REF_struct(i).time=REF_struct(i).time(1:end-1,:);
        REF_struct(i).signals.values=REF_struct(i).signals.values(1:end-1,:);
        
    end
end
%% Elements mismatch -- problem with reference structure
% Simulink only updates the value of Ref when it changes which happens
% every ref_Ts seconds. As such, we need to match the dimension of Ref with
% the size of U and Y. We practically have to propagate the values of Ref
% for ref_Ts/dt=0.02.



% Testing size of U and Y
for i=1:numel(U_struct)
    if all(U_struct(i).time==Y_struct(i).time)
        if options.debug
            fprintf('Equally sized variables U and Y for iteration %i.\n',i);
        end
        test_size=1;
    else
        warning('Warning: Unequally sized variables U and Y for iteration %i.\n',i);
        test_size=0;
    end
end

%     % if time_varying reference
%     if options.reference_type==2
%         for i=1:options.no_traces
%             REF_cell=[];%=cell(1,total_points);
%             for j=1:options.no_setpoints
%                 REF_cell=[REF_cell, REF_struct(i).signals.values(j)*ones(1,options.samples_per_setpoint)];
%                 REF_new_cell{i}=REF_cell;
%             end
%         end
%     end

REF=[];
U=[];
Y=[];
if test_size
    for i=1:numel(U_struct)
        %             %  only for testing
        %             %           REF=[REF;unique(REF_structure(i).signals.values)*ones(1,100)'];
        %             if options.reference_type==1
        %                 % there is only one reference value and should remain consant
        %                 REF=[REF;unique(REF_struct(i).signals.values)*ones(1,numel(U_struct(i).time))'];
        %             else
        %                 REF=[REF; REF_new_cell{i}'];
        %             end
        REF=[REF;REF_struct(i).signals.values];
        U=[U;U_struct(i).signals.values];
        Y=[Y;Y_struct(i).signals.values];
        
    end
else
    error('The training data do not have consistent sizes.')
end

if options.save_sim
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
    options.sim_name= strcat('array_sim_',temp_st,num2str(options.no_traces),'_traces_',num2str(options.no_ref),'x',num2str(options.no_x0),'_time_',num2str(options.T_train),'_',datestr(now,'dd-mm-yyyy_HH:MM'),'.mat');
    warning('Fix issue with folder names. Probably add a flag with the corresponding folder. Or use which to find dir.\n');
    %             folder= 'robotarm';
    %             folder='quadcopter';
    % %             folder='watertank';
    %             folder='tank'
    folder=options.SLX_folder;
    destination_folder={
        %            strcat('modules/outputs/robotarm/'),...
        %            strcat('outputs/robotarm/'),...
        strcat('..',filesep,'outputs',filesep,[folder],filesep),...
        strcat('..',filesep,'..',filesep,'outputs',filesep,[folder],filesep),...
        strcat('..',filesep,'..',filesep,'..',filesep,'outputs',filesep,[folder],filesep)};
    ic=1;
    while ic<=length(destination_folder)
        if exist(destination_folder{ic},'dir')
            destination_name=strcat(destination_folder{ic},char(options.sim_name));
            break;
        else
            ic=ic+1;
        end
    end
    if exist(destination_name,'var')
        save(destination_name,'REF','U','Y');
        save_bool=1;
    else
        save_bool=0;
    end
    if save_bool
        fprintf('The training data are saved as an array named %s.\n\n',char(options.sim_name));
        fprintf('The training data are saved as an array in %s.\n\n',destination_folder{ic});
    end
end

end

