function [all_rob,In_Original,In_Cex] = check_cex_all_data(Data,falsif,file_name,options,specific_input)
%check_cex_elimination Extract CEX and check in new Simulink model
%   This should work for single and multiple CEX.

close_system(strcat(options.SLX_model,'_breach'),0)
% delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
options.input_choice=4;
if strcmp(file_name,'watertank_inport_NN_cex') || strcmp(file_name,'watertank_multPID_2018a_v3_falsif')
    var_names_list={'In1','u','y','u_nn','y_nn','u_nn_cex_1','y_nn_cex_1'};
    %     no_REF=1;
    %     no_U=1;
    %     no_Y=1;
else
    var_names_list={};
end
% load_system(file_name) Breach loads the model

%3. Create Breach object
Br_check = BreachSimulinkSystem(file_name,'all',[],var_names_list);
% Br_check = BreachSimulinkSystem(file_name,'all');

nbinputsig = falsif.num_inputs;
nbctrpt = falsif.breach_segments;
input_str = {};
input_cp = [];
input_intp = {};
for ii = 1:nbinputsig %only one input
    input_str{end+1} = ['In' num2str(ii)];
    input_cp = [input_cp nbctrpt];
    input_intp{end+1} = 'previous';
end
Br_input_gen = var_cp_signal_gen(input_str, input_cp, input_intp);
Br_check.SetInputGen(BreachSignalGen({Br_input_gen}));

sim_time=falsif.T;
Br_check.SetTime(sim_time);
Br_check_all_cex=Br_check.copy();
Br_check_original=Br_check.copy();
input_param = {};

for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
        end
    end
    
    input_param;
    if strcmp(falsif.method,'CMA')
        input_param=input_param(1:2:end);
    end
end

if falsif.test_only_original
    
        %test on original data
        In_Original=[];
        if options.input_choice==3
            for i=1:options.coverage.no_traces_ref
                In_Original=[In_Original,options.coverage.cells{i}.random_value];
            end
            In_Original(3,:)=In_Original(2,:);
            In_Original(2,:)=options.ref_Ts;
            try
                In_Original(4,:)=[];
            end
        elseif options.input_choice==4
            if isfield(Data,'REF_all')
                no_points=size(Data.REF_all,1)/options.no_traces;
            else
                no_points=size(Data.REF,1)/options.no_traces;
            end
            
            REF_Original=[];In_Original=[];%REF_comb=zeros((options.breach_segments+options.breach_segments-1)*options.num_REF,1)
            REF_comb=[];
            for i=1:options.no_traces
                if isfield(Data,'REF_all')
                    ref_temp=unique(Data.REF_all(1+(i-1)*no_points:i*no_points,:),'rows','stable');
                else
                    ref_temp=unique(Data.REF(1+(i-1)*no_points:i*no_points,:),'rows','stable');
                end
                
                if i==1
                    fprintf('\nMissing check if reference remains the same across the segments\n\n');
                end
                REF_Original=ref_temp;
%                 REF_comb=REF_Original;
%                 for j=1:2:options.breach_segments
%                     REF_comb(j)=options.ref_Ts;
%                 end
%                 REF_comb(1:2:(options.breach_segments+1)*options.num_REF)=REF_Original;
%                 In_Original=[In_Original REF_comb];
                REF_comb(2,1:options.num_REF)=options.ref_Ts;
                REF_comb([1,3],:)=REF_Original;
                In_Original=[In_Original REF_comb(:)];
            end
            %fprintf('To-DO: need to generalize\n\n')
        end
        Br_check_original.SetParam(input_param, In_Original);
        load_system(strcat(file_name,'_breach'))
        set_param(strcat(file_name,'_breach'),'FastRestart','on')
        Br_check_original.Sim(sim_time);
        original_rob_all_nn=Br_check_original.CheckSpec(falsif.property);
        figure;Br_check_original.PlotRobustSat(falsif.property)
        fprintf('Training data - The NN has %i CEX out of %i.\n\n',numel(find(original_rob_all_nn<0)),numel(original_rob_all_nn));
        
        all_rob.orig_nn=original_rob_all_nn;
        if options.debug
            try
            figure;Br_check_original.PlotRobustMap(falsif.property);
            figure;Br_check_original.PlotSignals(falsif.property);
            end
        end

else
    if nargin<=4
        
        %test on original data
        fprintf('\n\n Add case for Breach!!!\n\n')
        In_Original=[];
        for i=1:options.coverage.no_traces_ref
            In_Original=[In_Original,options.coverage.cells{i}.random_value];
        end
        In_Original(3,:)=In_Original(2,:);
        In_Original(2,:)=5;
        try
            In_Original(4,:)=[];
        end
        Br_check_original.SetParam(input_param, In_Original);
        Br_check_original.Sim(sim_time);
        original_rob_all_cex=Br_check_original.CheckSpec(falsif.property_cex);
        original_rob_all_nn=Br_check_original.CheckSpec(falsif.property);
        original_rob_all_nom=Br_check_original.CheckSpec(falsif.property_nom);
        figure;Br_check_original.PlotRobustSat(falsif.property_nom)
        fprintf('Original - The retrained has %i CEX out of %i.\n\n',numel(find(original_rob_all_cex<0)),numel(original_rob_all_cex));
        fprintf('Original - The last NN has %i CEX out of %i.\n\n',numel(find(original_rob_all_nn<0)),numel(original_rob_all_nn));
        fprintf('Original - The nominal  has %i CEX out of %i.\n\n',numel(find(original_rob_all_nom<0)),numel(original_rob_all_nom));
        
        all_rob.orig_nom=original_rob_all_nom;
        all_rob.orig_nn=original_rob_all_nn;
        all_rob.orig_cex=original_rob_all_cex;
        
        % test on all cex
        Br_check_all_cex=Br_check.copy();
        In_Cex=[];
        for i=1:size(Data,1)
            data_cex_temp=Data{i,2}.REF;
            no_points=options.T_train/options.dt;
            for ii=1:size(data_cex_temp,1)/no_points
                % we iterate over the number of separate traces
                % we need to find out how many pieces we have
                data_used=data_cex_temp((no_points*(ii-1)+1):ii*no_points);
                index_needed=1:(no_points/options.breach_segments):no_points;
                data_cex=data_used(index_needed);
                %data_cex_temp=unique(data_cex_temp,'stable');
                %data_cex=reshape(data_cex_temp,2,numel(data_cex_temp)/2);
                In_Cex=[In_Cex,data_cex];
            end
        end
        In_Cex(3,:)=In_Cex(2,:);
        In_Cex(2,:)=5;
        Br_check_all_cex.SetParam(input_param, In_Cex);
        Br_check_all_cex.Sim(sim_time);
        old_rob_all_cex=Br_check_all_cex.CheckSpec(falsif.property_cex);
        old_rob_all_nn=Br_check_all_cex.CheckSpec(falsif.property);
        old_rob_all_nom=Br_check_all_cex.CheckSpec(falsif.property_nom);
        fprintf('Old Cex - The retrained has %i CEX out of %i.\n\n',numel(find(old_rob_all_cex<0)),numel(old_rob_all_cex));
        fprintf('Old Cex - The last NN has %i CEX out of %i.\n\n',numel(find(old_rob_all_nn<0)),numel(old_rob_all_nn));
        fprintf('Old Cex - The nominal  has %i CEX out of %i.\n\n',numel(find(old_rob_all_nom<0)),numel(old_rob_all_nom));
        
        all_rob.old_nom=old_rob_all_nom;
        all_rob.old_nn=old_rob_all_nn;
        all_rob.old_cex=old_rob_all_cex;
        
        close_system(strcat(options.SLX_model,'_breach'),0);
        % delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
        % delete(fullfile(which(strcat(options.SLX_model,'_breach.slxc'))))
    elseif nargin==5
        if size(specific_input,1)==3
            In_Specific=specific_input;
        elseif size(specific_input,1)==2
            In_Specific(3,:)=specific_input(2,:);
            In_Specific(2,:)=5;
        end
        Br_check_original.SetParam(input_param, In_Specific);
        Br_check_original.Sim(sim_time);
        original_rob_all_cex=Br_check_original.CheckSpec(falsif.property_cex);
        original_rob_all_nn=Br_check_original.CheckSpec(falsif.property);
        original_rob_all_nom=Br_check_original.CheckSpec(falsif.property_nom);
        fprintf('Original - The retrained has %i CEX out of %i.\n\n',numel(find(original_rob_all_cex<0)),numel(original_rob_all_cex));
        fprintf('Original - The last NN has %i CEX out of %i.\n\n',numel(find(original_rob_all_nn<0)),numel(original_rob_all_nn));
        fprintf('Original - The nominal  has %i CEX out of %i.\n\n',numel(find(original_rob_all_nom<0)),numel(original_rob_all_nom));
        
        all_rob.orig_nom=original_rob_all_nom;
        all_rob.orig_nn=original_rob_all_nn;
        all_rob.orig_cex=original_rob_all_cex;
        
    end
end
end