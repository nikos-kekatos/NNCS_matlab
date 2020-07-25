function plot_trace(data,options)
%plot_trace Plot an individual simulation trace

if nargin<1
 figure;plot(ref.time,ref.signals.values,'--r',y.time,y.signals.values)
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
else
%     n=options.points_per_sim;
n=options.T_train/options.dt;
    t=0:options.dt:options.T_train;
     figure;plot(t(1:(end-1)),data.REF(1:n),'--r',t(1:(end-1)),data.Y(1:n));
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
end
end
