
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);
%
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex_m1.time,y_nn_cex_m1.signals.values,'m.-.',y_nn_cex_m3.time,y_nn_cex_m3.signals.values,'y:',y_nn_cex_m4.time,y_nn_cex_m4.signals.values,'k--','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
% legend('reference',' NN original','NN with cex','FontSize',14)
legend('reference',' NN w/o cex','NN w/ cex v1','NN w/ cex v3','NN w/ cex v4','FontSize',14)

title('Simulating NNCS --  trained NN vs refined NNs','FontSize',18,'FontWeight','bold');

FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex_m1.time,y_nn_cex_m1.signals.values,'m.-.',y_nn_cex_m2.time,y_nn_cex_m2.signals.values,'-y',y_nn_cex_m3.time,y_nn_cex_m3.signals.values,'k:',y_nn_cex_m4.time,y_nn_cex_m4.signals.values,'c--','Linewidth',1);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference', 'PID', 'NN original','NN cex v1','NN cex v2','NN cex v3','NN cex v4','FontSize',14)
title('Simulating NNCS -- PID vs original NN vs refined NN','FontSize',18,'FontWeight','bold');