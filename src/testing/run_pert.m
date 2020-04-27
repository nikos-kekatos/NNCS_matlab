clc;
cc_all=-0.4:0.05:0.4;
cc_all=cc_all(cc_all~=0);
warning off;
m=length(cc_all);
for i=1:m
model_name='mrefrobotarm_modified_previous_y_previous_u_previous_ref_prepro';
cc=cc_all(i);
sim(model_name);

%{
% ref vs y
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time(1:end),y.signals.values(1:end),'g--',y_nn.time(1:end-1),y_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
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
plot(u.time(1:end),[u.signals.values(1:end-1);u.signals.values(end-1)],'g--',u_nn.time(1:end-1),u_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('nominal-PID','NN','FontSize',14)
title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');
%}
fprintf(' The nominal value is %.5f. \n\n',y.signals.values(end))

fprintf(' The NN value is %.5f. \n\n',y_nn.signals.values(end))

ss_abs(i)=y_nn.signals.values(end)-y.signals.values(end);
fprintf(' The absolute ss error is %.5f. \n\n',ss_abs(i))
ss_rel(i)=(y_nn.signals.values(end)-y.signals.values(end))/y.signals.values(end)*100;
fprintf(' The relative ss error is %.5f (perc). \n\n',ss_rel(i))
end
fprintf('The average rel. ss error over %i simulations is %.5f.\n\n',m,sum(abs(ss_rel))/m);
fprintf('The maximum rel. ss error over %i simulations is %.5f.\n\n',m,max(abs(ss_rel)));
