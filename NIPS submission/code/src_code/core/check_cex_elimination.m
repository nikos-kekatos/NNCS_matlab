function [robustness_check,robustness_check_all,inputs_cex,inputs_all,options] = check_cex_elimination(falsif_pb,falsif,data_cex,file_name,idx_cluster,options)
%check_cex_elimination Extract CEX and check in new Simulink model
%   This should work for single and multiple CEX.

close_system(strcat(options.SLX_model,'_breach'),0)
% delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
options.input_choice=4;
if strcmp(file_name,'watertank_inport_NN_cex')
    var_names_list={'In1','u','y','u_nn','y_nn','u_nn_cex_1','y_nn_cex_1'};
    %     no_REF=1;
    %     no_U=1;
    %     no_Y=1;
else
    var_names_list={};
end
% load_system(file_name) Breach loads the model

%0. if used clustering, we need to update the falsif_index.
%1. From falsif_pb find all traces with rob<0.
condition=length(idx_cluster)==length(falsif_pb.obj_false);
if condition
%     falsif_idx=find(falsif_pb.obj_log<0);
    falsif_idx=find(falsif_pb.obj_false<0);
else
    falsif_idx=idx_cluster;
end
fprintf('\nThe number of CEX after clustering is %i.\n',numel(falsif_idx));

%2. In falsif_pb.X_false all input parameters are stored.
if condition
%     inputs_all=falsif_pb.X_log;
    inputs_cex=falsif_pb.X_false;
else
%     inputs_all=falsif_pb.X_log(:,falsif_idx);
    inputs_cex=falsif_pb.X_false(:,falsif_idx);
end
no_cex=length(falsif_idx);
no_cex=size(inputs_cex,2);

%3. Create Breach object
% Br_check = BreachSimulinkSystem(file_name,'all',[],var_names_list);
Br_check = BreachSimulinkSystem(file_name,'all');

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
Br_check_all=Br_check.copy();
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
        input_param=input_param(1:2:end)
    end
end

%4. Specify inputs/old cexs and check their robustness

Br_check.SetParam(input_param, inputs_cex);
% Br_check.Sim(sim_time-options.dt);
Br_check.Sim(sim_time);
% robustness_check{1} = Br_check.CheckSpec(falsif.property);
% robustness_check{2}=Br_check.CheckSpec(falsif.property_cex);
robustness_check=Br_check.CheckSpec(falsif.property_cex);

inputs_all=falsif_pb.X_log;
if ~isequal(inputs_all,inputs_cex)
Br_check_all.SetParam(input_param, inputs_all);
% Br_check_all.Sim(sim_time-options.dt);
Br_check_all.Sim(sim_time);
% robustness_check{1} = Br_check.CheckSpec(falsif.property);
% robustness_check{2}=Br_check.CheckSpec(falsif.property_cex);
new_rob_all_cex=Br_check_all.CheckSpec(falsif.property_cex);
new_rob_all_nn=Br_check_all.CheckSpec(falsif.property);
new_rob_all_nom=Br_check_all.CheckSpec(falsif.property_nom);
fprintf('The retrained has %i CEX out of %i.\n\n',numel(find(new_rob_all_cex<0)),numel(new_rob_all_cex));
fprintf('The last NN has %i CEX out of %i.\n\n',numel(find(new_rob_all_nn<0)),numel(new_rob_all_nn));
fprintf('The nominal  has %i CEX out of %i.\n\n',numel(find(new_rob_all_nom<0)),numel(new_rob_all_nom));
robustness_check_all=new_rob_all_cex;
else
    robustness_check_all=robustness_check;
end
close_system(strcat(options.SLX_model,'_breach'),0);
% delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
% delete(fullfile(which(strcat(options.SLX_model,'_breach.slxc'))))

end

%{
for i=1:no_cex
    
end
%K-means does not specify the number of clusters. So, we need to choose
%beforehand or iterate with different values.
cex_ref_points_array=cell2mat(cex_ref_points)'


end

%}