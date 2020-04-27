
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);
%

y_nn_cex=y_nn_cex_m5;


FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex.time,y_nn_cex.signals.values,'m.-.','Linewidth',0.75);
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
plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time,y.signals.values,'g--',y_nn.time,y_nn.signals.values,'b-.',y_nn_cex.time,y_nn_cex.signals.values,'m.-.','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference', 'PID', 'NN original','NN with cex','FontSize',14)
title('Simulating NNCS -- PID vs original NN vs refined NN','FontSize',18,'FontWeight','bold');