%% Falsification of nominal controllers
% clear 
run('config_Hespanha.m')
% options.testing_breach=1;
% training_options.combining_old_and_cex=1; % 1: combine old and cex
falsif.iterations_max=1;
falsif.method='quasi';
falsif.num_samples=20;
falsif.num_corners=25;
falsif.max_obj_eval=100;
falsif.max_obj_eval_local=10;
falsif.seed=100;
falsif.num_inputs=1;

% falsif.property_file=options.specs_file;
falsif.property_file='specs_hespanha_riseTime.stl';
% falsif.property_file='specs_hespanha_ringing.stl';


[~,falsif.property_all]=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{1};%// TO-DO automatically specify the file

falsif.breach_ref_min=0.1;            %watertank 8 % quadcopter -1 %robotarm -0.5
falsif.breach_ref_max=2;           % watertank 12 % quadcopter 3  % robotarm 0.5
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
try
C=options.controllers.C;
contNb=length(C);
catch
    contNb=2
end
for index_contr=1: contNb
    if index_contr==1
        file_name='controller1';
    elseif index_contr==2
        file_name='controller2';
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
figure;falsif_pb{1}.BrSet_Logged.PlotRobustSat(phi_5_nom)
end
for ic=1:contNb
  fprintf(' Controller -- %i\n',ic)
    fprintf('We ran %i scenarios and found %i CEX.\n\n',numel(robustness_checks_all{ic}),numel((robustness_checks_false{ic})));
end  