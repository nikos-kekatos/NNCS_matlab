falsif.property_file=options.specs_file;
falsif.property_file='specs_robotarm_overshoot.stl';
[~,falsif.property_all]=STL_ReadFile(falsif.property_file);
falsif.property=falsif.property_all{2};%// TO-DO automatically specify the file
falsif.property_cex=falsif.property_all{3};
falsif.property_nom=falsif.property_all{4};

Data_all=data
[original_rob,In_Original] = check_cex_all_data(Data_all,falsif,file_name,options);
% figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)



%% 12a. Checking CEX against SLX
fprintf('\n\n------------\n\n');
fprintf('\nHere we check if there are any problems with the way we store the data.\n');
fprintf('The number of resulting CEX is %i.\n',numel(idx_cluster));

data_test=data_cex_cluster;
% data_test=Data_all{2,2};
% data_test=data_backup;
no_points=1000;
no_cex=size(data_test.REF,1)/no_points;REF=[];
for i=1:no_cex
%     figure;plot(linspace(0,10,no_points),data_test.REF(1+(i-1)*no_points:i*no_points),'r',linspace(0,10,no_points),data_test.Y(1+(i-1)*no_points:i*no_points),'b-.')
%     title(sprintf('CEX %i.',i))
%     legend('ref','breach/data\_cex')
    ref_falsif=unique(data_test.REF(1+(i-1)*no_points:i*no_points),'stable');
    REF=[REF,ref_falsif];
end
REF
options.input_choice=3;
options.sim_ref=8;
if numel(ref_falsif)==2
    options.ref_Ts=options.T_train/2;
elseif numel(ref_falsif)==1
    options.ref_Ts=options.T_train;
else
    error('Checking can be done for signals with 2 pieces')
end
for i=1:no_cex
    options.sim_cov=REF(:,i);
    options.workspace = simset('SrcWorkspace','current');
    sim(SLX_model,[],options.workspace);
%     figure; plot(ref.time(1:(end-1)),ref.signals.values(1:(end-1)),'r',y.time(1:(end-1)),y.signals.values(1:(end-1)),'b-.')
%     title(sprintf('CEX %i.',i))
%     legend('ref','SLX')

    figure;plot(ref.time(1:(end-1)),ref.signals.values(1:(end-1)),'r',y.time(1:(end-1)),y.signals.values(1:(end-1)),'b-.',linspace(0,10,no_points),data_test.Y(1+(i-1)*no_points:i*no_points),'m-.')
    legend('ref','SLX sim','breach')
    title(sprintf('CEX %i.',i))
end
%%
disp('-----------')
disp('     The last counterexamples:')
REF
disp('      The previous counterexamples:')
REF_previous_temp=unique(Data_all{1,2}.REF,'stable');
REF_previous=reshape(REF_previous_temp,[2,numel(REF_previous_temp)/2])
plot_coverage_boxes(options,1)
hold on
plot(REF_previous(1,:),REF_previous(2,:),'ms')
plot(REF(1,:),REF(2,:),'bx')

%% 12b. Check NN-cex on original training data

[all_rob_stabilization,In_Original,In_Cex] = check_cex_all_data(Data_all,falsif,file_name,options);
figure;falsif_pb{i_f}.BrSet_Logged.PlotRobustSat(phi_3)

%%
% [specific_rob] = check_cex_all_data([],falsif_settlingTime,file_name,options,XXX);
% idx_nominal=find(specific_rob.orig_nom<0)
% XXX(:,idx_nominal)
%% 12c. Check NN/Original/Trained NN on different STL property
options.input_choice=4
disp(' Overshoot')
disp(' -------===============================-----------')
falsif_overshoot=falsif;
falsif_overshoot.property_file='specs_watertank_overshoot.stl';
[~,falsif_overshoot.property_all]=STL_ReadFile(falsif_overshoot.property_file);
falsif_overshoot.property=falsif_overshoot.property_all{2};%// TO-DO automatically specify the file
falsif_overshoot.property_cex=falsif_overshoot.property_all{3};
falsif_overshoot.property_nom=falsif_overshoot.property_all{4};
[all_rob_overshoot,In_Original,In_Cex] = check_cex_all_data(Data_all,falsif,file_name,options);

%%
XXX=In_Cex(:,15:16)
options.input_choice=4
falsif_settlingTime=falsif;
falsif_settlingTime.property_file='specs_watertank_overshoot.stl';
[~,falsif_settlingTime.property_all]=STL_ReadFile(falsif_settlingTime.property_file);
falsif_settlingTime.property=falsif_settlingTime.property_all{2};%// TO-DO automatically specify the file
falsif_settlingTime.property_cex=falsif_settlingTime.property_all{3};
falsif_settlingTime.property_nom=falsif_settlingTime.property_all{4};
[all_rob_settling] = check_cex_all_data(Data_all,falsif_settlingTime,file_name,options,XXX);
idx_nominal=find(all_rob_settling.orig_nom<0)
XXX(:,idx_nominal)