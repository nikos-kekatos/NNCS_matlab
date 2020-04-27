function plot_trace(data)
%plot_trace Plot an individual simulation trace

if nargin<1
 figure;plot(ref.time,ref.signals.values,'--r',y.time,y.signals.values)
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
else
    n=options.points_per_sim;
    t=0:options.dt:options.T_train;
     figure;plot(t(1:end-2),data.REF(n+1:2*n-2),'--r',t(1:end-2),data.Y(n+1:2*n-2));
        xlabel('time (sec)')
        ylabel ('angle (rad)')
        legend('ref','y')
        title('Random Simulation Trace')
end
end
