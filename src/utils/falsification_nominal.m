%% Falsification of nominal controllers

options.SLX_model_nominal=strcat(options.SLX_model,'_nom');
options.SLX_model_nominal='watertank_multPID_2018a_v3_nom_c1';
% options.testing_breach=1;
% training_options.combining_old_and_cex=1; % 1: combine old and cex
falsif.iterations_max=1;
falsif.method='GNM';
falsif.num_samples=100;
falsif.num_corners=10;
falsif.max_obj_eval=100;
falsif.max_obj_eval_local=100;
falsif.seed=200;
falsif.num_inputs=1;

falsif.property_file=options.specs_file;
falsif.property_file='specs_watertank_comb_ctrl_2.stl';

falsif.property_file='specs_watertank_comb_ctrl_3.stl';
% falsif.property_file='specs_watertank_stabilization_ctrl_2.stl';
% falsif.property_file='specs_watertank_overshoot_ctrl_2.stl';

% falsif.property_file='specs_watertank_stabilization_comb.stl';
[~,falsif.property_all]=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{4};%// TO-DO automatically specify the file

falsif.breach_ref_min=8;            %watertank 8 % quadcopter -1 %robotarm -0.5
falsif.breach_ref_max=12;           % watertank 12 % quadcopter 3  % robotarm 0.5
falsif.stop_at_false=false;
falsif.T=options.T_train;
falsif.input_template='fixed';
try
    falsif.breach_segments=options.breach_segments;
catch
    falsif.breach_segments=2;
    options.breach_segments=falsif.breach_segments;
end

% file_name=options.SLX_model_nominal;

C=options.controllers.C;
contNb=length(C);

for index_contr=1: contNb
    if index_contr==1
        file_name='watertank_multPID_2018a_v3_nom_c1';
    elseif index_contr==2
        file_name='watertank_multPID_2018a_v3_nom_c2_values';
    end
    
    timer_falsif=tic;
    
    fprintf('\n Beginning falsification with Breach.\n')
    fprintf('\n We use the model %s for falsification.\n',file_name);
    
    falsif.iteration=1; % choose property
    check_nominal=0;
    [data_cex,falsif_pb_temp,rob_nominal]= falsification_breach(options,falsif,file_name,check_nominal);
    robustness_checks_false{index_contr}=falsif_pb_temp.obj_false;
    robustness_checks_all{index_contr}=falsif_pb_temp.obj_log;
    
    falsif_pb{index_contr}=falsif_pb_temp;
    fprintf('\n End of falsification with Breach.\n')

end
for ic=1:contNb
  fprintf(' Controller -- %i\n',ic)
    fprintf('We ran %i scenarios and found %i CEX.\n\n',numel(robustness_checks_all{ic}),numel((robustness_checks_false{ic})));
end  