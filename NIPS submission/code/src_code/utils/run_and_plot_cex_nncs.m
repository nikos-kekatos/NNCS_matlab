function [completed] = run_and_plot_cex_nncs(options,model_name,inputs_cex,num_cex)
%run_and_plot_cex_nncs For the CEX from Breach, compute simulations with
%nominal, NN and retrained.
%   This function requires the model_name (Simulink file), the
%   falsification problem (to get the CEX values) and a user defined number
%   of CEX, i.e. get the first 5. The default is all.


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

if isempty(model_name)
    model_name = options.SLX_model;
end


if nargin<=3 || isempty(num_cex) || (num_cex>=size(inputs_cex,2))
    num_cex=size(inputs_cex,2);
end

if ~options.plotting_sim % if somebody has notrequested plotted, we will just show a few.
    num_cex=min(2,size(inputs_cex,2))
end
for i=1:num_cex
    options.input_choice=3;
    %options.sim_ref=8;
    %options.ref_min=8.5;
    %options.ref_max=11.5;
    %options.sim_cov=[12;8];
    if options.breach_segments==2
        if size(inputs_cex,1)==2
            options.sim_cov=[inputs_cex(1,i);inputs_cex(2,i)];
        elseif size(inputs_cex,1)==3
            options.sim_cov=[inputs_cex(1,i);inputs_cex(3,i)];
        end
    elseif options.breach_segments==1
        options.sim_cov=[inputs_cex(1,i)];
    else
        if size(inputs_cex,1)>options.breach_segments %then time steps exist
            options.sim_cov=[inputs_cex(1:2:end,i)];
        else % no time steps
            options.sim_cov=[inputs_cex(1:end,i)];
        end
    end
    options.workspace = simset('SrcWorkspace','current');
    sim(model_name,[],options.workspace);
    
    if options.plotting_sim
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
        title(sprintf('Simulating NNCS -- trained NN and refined NN - CEX %i',i),'FontSize',18,'FontWeight','bold');
        
        %title('Simulating NNCS --  trained NN vs refined NNs','FontSize',18,'FontWeight','bold');
    end
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
    title(sprintf('Simulating NNCS -- Nominal vs trained NN and refined NN - CEX %i',i),'FontSize',18,'FontWeight','bold');
    
end
completed=1;
close_system(options.SLX_model,0)

end

