
%  delete(fullfile(which(strcat(options.SLX_model,'_breach.slx'))))
get_param(Simulink.allBlockDiagrams(),'Name')
bdclose all;
clear Data_all data_cex Br falsif_pb net_all phi_1 phi_3 phi_4  phi_5 phi_all
clear robustness_checks_all robustness_checks_false falsif falsif_pb_temp 
clear rob_nominal robustness_check_temp block_name falsif_idx data_cex
clear data_cex_cluster tr tr_all condition cluster_all check_nominal model_name
clear data_backup i_f ii In1_dt0 In1_u0 In1_u1 inputs_cex iter iter_best num_cex
clear reached seeds_all stop t__ tm training_perf tspan u__ idx_cluster falsif_pb_zero

%%% ------------------------------------------ %%
%%% ----- 11-A: Falsification with Breach ---- %%
%%% ------------------------------------------ %%

falsif.test_only_original=1;

options.testing_breach=1;
falsif.iterations_max=3;
falsif.method='quasi';
falsif.num_samples=20;
falsif.num_corners=25;
falsif.max_obj_eval=100;
falsif.max_obj_eval_local=20;
falsif.seed=100;
try
falsif.num_inputs=options.num_REF;
catch
 falsif.num_inputs=2
end
falsif.property_file=options.specs_file;
% falsif.property_file='specs_quad_z_desired.stl';
%'specs_watertank_stabilization_ctrl_1.stl'
%'specs_watertank_stabilization_comb.stl';

% falsif.property_file='specs_robotarm_overshoot.stl';
[~,falsif.property_all]=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{2};%// TO-DO automatically specify the file
falsif.property_cex=falsif.property_all{3};
falsif.property_nom=falsif.property_all{4};

get_params(falsif.property)

if model==1 || model==10
    falsif.breach_ref_min=8;            %watertank 8 % quadcopter -1 %robotarm -0.5
    falsif.breach_ref_max=12;           % watertank 12 % quadcopter 3  % robotarm 0.5
elseif model==2
    falsif.breach_ref_min=-0.5;            %watertank 8 % quadcopter -1 %robotarm -0.5
    falsif.breach_ref_max=0.5;
elseif model==3
    falsif.breach_ref_min=-1;            %watertank 8 % quadcopter -1 %robotarm -0.5
    falsif.breach_ref_max=3;
elseif model==4
    falsif.breach_ref_min=8;            %watertank 8 % quadcopter -1 %robotarm -0.5
    falsif.breach_ref_max=9;
elseif model==5 
    falsif.breach_ref_min=options.breach_ref_min;    %[0.2 0]        %watertank 8 % quadcopter -1 %robotarm -0.5
    falsif.breach_ref_max=options.breach_ref_max;    %[0.4 0.1]
elseif model==8 || model==6 
    falsif.breach_ref_min=options.ref_min;
    falsif.breach_ref_max=options.ref_max;
elseif model==7
    falsif.breach_ref_min=options.coverage.ref_min;
    falsif.breach_ref_max=options.coverage.ref_max;
end
falsif.stop_at_false=false;
falsif.T=options.T_train;
falsif.input_template='fixed';
try
    falsif.breach_segments=options.breach_segments;
catch
    falsif.breach_segments=2;
    options.breach_segments=falsif.breach_segments;
end