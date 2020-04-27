function plot_trace_testing_coverage(testing,index)
%plot_trace_testing_coverage It is used to visualize specific traces
%   This function is used for visualizing traces in case we do testing
%   based on coverage.

trace=testing.data;
for i=1:numel(index)
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(trace.time{index(i)}(1:end-1),trace.REF_test{index(i)}(1:end-1),'r',trace.time{index(i)}(1:end-1),trace.Y_test{index(i)}(1:end-1),'g--',trace.time{index(i)}(1:end-1),trace.Y_NN_test{index(i)}(1:end-1),'b-.','Linewidth',0.75);
legend('reference','nominal','NN','FontSize',14)
title(sprintf('Simulating NNCS both with PID and NN - cell %i',index(i)));

% u_NN vs u_PID
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ u(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(trace.time{index(i)}(1:end-1),trace.U_test{index(i)}(1:end-1),'g--',trace.time{index(i)}(1:end-1),trace.U_NN_test{index(i)}(1:end-1),'b-.','Linewidth',0.75);

% plot(u.time(1:end),[u.signals.values(1:end-1);u.signals.values(end-1)],'g--',u_nn.time(1:end-1),u_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
legend('nominal-PID','NN','FontSize',14)
% title(sprintf("'Simulating NNCS both with PID and NN - cell %i','FontSize',18,'FontWeight','bold'",i));
title(sprintf('Simulating NNCS both with PID and NN - cell %i',index(i)));

end
end

