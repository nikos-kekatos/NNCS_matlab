function [completed,const_ref] = call_SLX_and_plot
%call_SLX_and_plot  This is a function for plotting and calling Simulink from MATLAB
%   We do the following: (i) set the reference, (ii) call/run Simulink and
% (iii) plot the results.

close all;
clc;

persistent ref u y tout u_nn y_nn;
warning off

model_name='robotarm_generalization_error';

% Note that options.dt and const_ref are preloaded in the SLX file.
options.dt=0.02;

%% 1st trace

const_ref=-0.1;
ix=1;
% Necessary to change the base workspace so that the SLX gets the correct
% values.
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);

fprintf('Simulation began -- trace %i.\n\n', ix);
plot_traces;
fprintf('Simulation ended.\n\n');
%% 2nd

const_ref=-0.2;
ix=2;
options.workspace = simset('SrcWorkspace','current');
sim(model_name,[],options.workspace);

fprintf('Simulation began -- trace %i.\n\n', ix);
plot_traces;
fprintf('Simulation ended.\n\n');
%%
    function plot_traces
        % The results are saved as ref, u, y structures.
        
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
        legend('nominal-PID','NN','FontSize',14)
        title('Simulating NNCS both with PID and NN','FontSize',18,'FontWeight','bold');
        
        % print out final values
        fprintf(' The nominal value is %.5f. \n\n',y.signals.values(end));     
        fprintf(' The final NN value is %.5f. \n\n',y_nn.signals.values(end));      
    end

completed=1;

end
