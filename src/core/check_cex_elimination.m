function [robustness_check] = check_cex_elimination(falsif_pb,falsif,data_cex,model_name)
%check_cex_elimination Extract CEX and check in new Simulink model
%   This should work for single and multiple CEX.


if strcmp(model_name,'watertank_inport_NN_cex')
    var_names_list={'In1','u','y','u_nn','y_nn','u_nn_cex_1','y_nn_cex_1'};
    %     no_REF=1;
    %     no_U=1;
    %     no_Y=1;
end

%1. From falsif_pb find all traces with rob<0.
falsif_idx=find(falsif_pb.obj_log<0);

%2. In falsif_pb.X_false all input parameters are stored.
inputs_all=falsif_pb.X_log;
inputs_cex=falsif_pb.X_false;
no_cex=length(falsif_idx);
no_cex=length(inputs_cex);

%3. Create Breach object
Br_check = BreachSimulinkSystem(model_name,'all',[],var_names_list);

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

input_param = {};

for ii = 1:nbinputsig
    for jj = 0:(nbctrpt-1)
        input_param{end+1} = ['In' num2str(ii) '_u' num2str(jj)];
        if (jj<(nbctrpt-1))
            input_param{end+1} = ['In' num2str(ii) '_dt' num2str(jj)];
        end
    end
    
    input_param
    
end

%4. Specify inputs/old cexs and check their robustness

Br_check.SetParam(input_param, inputs_cex);
Br_check.Sim(sim_time);
% robustness_check{1} = Br_check.CheckSpec(falsif.property);
% robustness_check{2}=Br_check.CheckSpec(falsif.property_cex);
robustness_check=Br_check.CheckSpec(falsif.property_cex);
end

%{
for i=1:no_cex
    
end
%K-means does not specify the number of clusters. So, we need to choose
%beforehand or iterate with different values.
cex_ref_points_array=cell2mat(cex_ref_points)'


end

%}