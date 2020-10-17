function  [ref,y,u,options]=run_simulation_nncs_comb(options,model_name,plot_cex)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if isempty(model_name)|| nargin==1
    model_name = options.SLX_model;
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


if options.model==4
    load PIDGainSchedExample
elseif options.model==5
    run('quad_variables.m')
elseif options.model==7
    Kp=0.0055;
    Ki=0.0131;
    Kd=3.3894e-004;
    N=9.9135;
end
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);
if plot_cex=='rob'
    load_system(options.SLX_model)
    if options.combination~=1
        warning('options.combination is not set correctly!')
        options.combination=1;
    end
    [ref_comb,y_comb,u_comb,options,~,~,J]=sim_SLX(options.SLX_model,options);
%     [J,options]=compute_robustness(ref,u,y,options)
    fprintf('\nThe robustness of trace i is %.5f.\n\n',J)
elseif plot_cex==0 %plot only nominal
    
elseif plot_cex==1
    load_system(options.SLX_model)
    if options.combination~=1
        warning('options.combination is not set correctly!')
        options.combination=1;
    end
    [ref_comb,y_comb,u_comb]=sim_SLX(options.SLX_model,options);
     FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    hold on;
    plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',...
        y.time,y.signals.values(:,y_idx),'g--',...
        y2.time, y2.signals.values(:,y_idx),'c.-.', ...
        y_comb.time, y_comb.signals.values(:,y_idx),'k:',...
        'Linewidth',0.75);
    legend('reference', ' PID 1', 'PID 2','combined PID','FontSize',14)
    title('Simulating NNCS -- PID  vs combined PID','FontSize',18,'FontWeight','bold');
    
elseif plot_cex==2
    
elseif plot_cex==3
    
elseif plot_cex==4
    % we have already ran the combined/falsif which has the combined NN and
    % the combined NN with cex
    
    %{
    load_system(options.SLX_model)
    ref_all=ref;
    y_all=y;
    u_all=u;
    if options.combination~=1
        warning('options.combination is not set correctly!')
        options.combination=1;
    end
    [ref_comb,y_comb,u_comb]=sim_SLX(options.SLX_model,options);
    %}
    
    FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',...
        y.time,y.signals.values(:,y_idx),'g--',...
        y2.time, y2.signals.values(:,y_idx),'c.-.', ...
        y_nn.time, y_nn.signals.values(:,y_idx),'m-.',...
        'Linewidth',0.75);
    % xlabel('time (s)')
    % ylabel('plant output')
    legend('reference', ' PID 1', 'PID 2','combined NN ','FontSize',14)
    title('Simulating NNCS -- PID  vs combined NN','FontSize',18,'FontWeight','bold');
    %{
    FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    plot(ref_all.time(1:end-1),ref_all.signals.values(1:end-1,ref_idx),'r',y_all.time,y_all.signals.values(:,y_idx),'g--',ref_comb.time(1:end-1),ref_comb.signals.values(1:end-1,ref_idx),'c', y_comb.time,y_comb.signals.values(:,y_idx),'k:',y_nn.time,y_nn.signals.values(:,y_idx),'b-.',y_nn_cex_1.time,y_nn_cex_1.signals.values(:,y_idx),'m.-.','Linewidth',0.75);
    % xlabel('time (s)')
    % ylabel('plant output')
    legend('reference', 'single PID', 'combined ref','combined PID','single NN','combined NN ','FontSize',14)
    title('Simulating NNCS -- PID vs singe NN vs combined NN','FontSize',18,'FontWeight','bold');
    %}
elseif plot_cex==5
    FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',...
        y.time,y.signals.values(:,y_idx),'g--',...
        y2.time, y2.signals.values(:,y_idx),'c.-.', ...
        y_nn.time, y_nn.signals.values(:,y_idx),'m-.',...
        'Linewidth',0.75);
    legend('reference', ' PID 1', 'PID 2','combined NN','FontSize',14)
    title('Simulating NNCS -- PID  vs combined NN','FontSize',18,'FontWeight','bold');
    load_system(options.SLX_model)
    if options.combination~=1
        warning('options.combination is not set correctly!')
        options.combination=1;
    end
    [ref_comb,y_comb,u_comb]=sim_SLX(options.SLX_model,options);
    figure
    plot(ref_comb.time(1:end-1),ref_comb.signals.values(1:end-1,ref_idx),'c',y_comb.time,y_comb.signals.values(:,y_idx),'k:')
    legend('reference','combined sim')
    % xlabel('time (s)')
    % ylabel('plant output')
    FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    hold on;
    plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',...
        y.time,y.signals.values(:,y_idx),'g--',...
        y2.time, y2.signals.values(:,y_idx),'c.-.', ...
        y_comb.time, y_comb.signals.values(:,y_idx),'k:',...
        'Linewidth',0.75);
    legend('reference', ' PID 1', 'PID 2','combined PID','FontSize',14)
    title('Simulating NNCS -- PID  vs combined PID','FontSize',18,'FontWeight','bold');
    
    FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
    AX = axes('NextPlot', 'add');
    set(AX, 'YScale', 'linear');
    axis(AX, 'tight');
    grid(AX);
    set(AX, 'FontSize', 12);
    xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
    hold on;
    plot(ref.time(1:end-1),ref.signals.values(1:end-1,ref_idx),'r',...
        y_nn.time,y_nn.signals.values(:,y_idx),'m-.',...
        y_comb.time, y_comb.signals.values(:,y_idx),'k:',...
        'Linewidth',0.75);
    legend('reference', 'comb. NN','comb. PID','FontSize',14)
    title('Simulating NNCS --  combined NN vs  PID','FontSize',18,'FontWeight','bold');
end
close_system(model_name,1);
end