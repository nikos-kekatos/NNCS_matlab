function plot_single_trace(ref,y,u,options)
%plot_trace Plotting a simulation trace
%   This requires the simulation to be run and the inputs are the ref,y and
%   u.

if  ~isfield(options,'ref_index_plot') || isempty(options.ref_index_plot)
    ref_idx=1;
else
    ref_idx=options.ref_index_plot;
end
if  ~isfield(options,'y_index_plot') || isempty(options.y_index_plot)  
    y_idx=1;
else
    y_idx=options.y_index_plot;
end
if  ~isfield(options,'u_index_plot') || isempty(options.u_index_plot)
    u_idx=1;
else
    u_idx=options.u_index_plot;
end
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',y.time(1:end),y.signals.values(1:end,y_idx),'g--','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('reference','nominal','FontSize',14)
title('Simulating NNCS -- nominal','FontSize',18,'FontWeight','bold');

% u_NN vs u_PID
FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
AX = axes('NextPlot', 'add');
set(AX, 'YScale', 'linear');
axis(AX, 'tight');
grid(AX);
set(AX, 'FontSize', 12);
xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(AX, '$\ u(k)$', 'Interpreter', 'latex', 'FontSize', 20);
plot(u.time(1:end),[u.signals.values(1:end-1,u_idx);u.signals.values(end-1,u_idx)],'g--','Linewidth',0.75);
% xlabel('time (s)')
% ylabel('plant output')
legend('nominal-PID','FontSize',14)
title('Simulating NNCS - nominal','FontSize',18,'FontWeight','bold');

end

