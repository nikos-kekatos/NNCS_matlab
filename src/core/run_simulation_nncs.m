function  run_simulation_nncs(options,model_name,plot_cex)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if isempty(model_name)|| nargin==1
model_name = options.SLX_NN_model;
end

if nargin<=2
    plot_cex=0;
end
if isempty(options.ref_index_plot)
    ref_idx=1;
else
    ref_idx=options.ref_index_plot;
end
if isempty(options.y_index_plot)
    y_idx=1;
else
    y_idx=options.y_index_plot;
end
if isempty(options.u_index_plot)
    u_idx=1;
else
    u_idx=options.u_index_plot;
end
% Previously, this part was done manually. The user had to copy the block
% created in the previous step with 'gensim' and insert it in the SLX_model
% with the NN.

%{
% Used to keep track of working and tested models
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_pert';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_pert_2';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_prepro';
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_cover';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test_2';
model_name='mrefrobotarm_previous_y_previous_u_previous_ref_cover_test_3';
model_name='quad_1_ref_NN';
model_name='helicopter_NN';
model_name='quad_3_ref_NN';
model_name='quad_3_ref_6_y_NN';
model_name='watertank_comp_design_mod_NN';
%}
% options.testing.sim_cov=[12,11];
% cc=-0.1;
% options.sim_cov=0;
% options.sim_ref=2.93;
% options.testing.ref_Ts=5;
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);
%{
figure;
temp.ref_time=ref.time([1, end]);
temp.ref_time_new=temp.ref_time(1):options.dt:temp.ref_time(2);
temp.ref_time_new=temp.ref_time_new(1:end-1);
temp.ref_values=[];
% find set_points
str_block=get_param('mrefrobotarm_modified_previous_y_previous_u_previous_ref/Random Reference','SampleTime');
no_setpoints_sim=ref.time(end)/str2double(str_block);
for i=1:no_setpoints_sim
    temp.ref_values=[temp.ref_values,repmat(ref.signals.values(i),[1,length(temp.ref_time_new)/no_setpoints_sim])];
end
figure;plot(temp.ref_time_new,temp.ref_values,'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.','Linewidth',0.75);
xlabel('time (s)')
ylabel('plant output')
legend('reference','nominal','NN')
title('Simulating NNCS both with PID and NN')
% plot([x(3); x(3)], ylim, '-r')      % Plot the vertical line in red
%}

if plot_cex~=1
% ref vs y
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',y.time(1:end),y.signals.values(1:end,y_idx),'g--',y_nn.time(1:end-1),y_nn.signals.values(1:end-1,y_idx),'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference','nominal','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');

% u_NN vs u_PID
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ u(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(u.time(1:end),[u.signals.values(1:end-1,u_idx);u.signals.values(end-1,u_idx)],'g--',u_nn.time(1:end-1,u_idx),u_nn.signals.values(1:end-1,u_idx),'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('nominal-PID','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');

fprintf(' The nominal value is %.5f. \n\n',y.signals.values(end))

fprintf(' The NN value is %.5f. \n\n',y_nn.signals.values(end))

ss_abs=abs(y_nn.signals.values(end)-y.signals.values(end));
fprintf(' The absolute ss error is %.5f. \n\n',ss_abs)
ss_rel=(y_nn.signals.values(end)-y.signals.values(end))/y.signals.values(end)*100;
fprintf(' The relative ss error is %.5f%%. \n\n',ss_rel)

elseif plot_cex==1

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',y_nn.time,y_nn.signals.values(:,y_idx),'b-.',y_nn_cex_1.time,y_nn_cex_1.signals.values(:,y_idx),'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
% legend('reference',' NN original','NN with cex','FontSize',14)
legend('reference',' NN -- no cex','NN -- cex v1','FontSize',14)

title('Simulating NNCS --  trained NN vs refined NNs','FontSize',18,'FontWeight','bold');

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',y.time,y.signals.values(:,y_idx),'g--',y_nn.time,y_nn.signals.values(:,y_idx),'b-.',y_nn_cex_1.time,y_nn_cex_1.signals.values(:,y_idx),'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference', 'PID', 'NN original','NN with cex','FontSize',14)
title('Simulating NNCS -- PID vs original NN vs refined NN','FontSize',18,'FontWeight','bold');
end