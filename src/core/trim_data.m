function [data] = trim_data(data,options)
%trim_data Trimming part of the data
%   We create fileds RERF_trim, U_trim, Y_trim in the data structure by
%   keeping one every $m$ points.
if isfield(options,'keepData_factor')
    m=options.keepData_factor;
else
    m=1;
end
if isempty(options.keepData_factor)
    m=1;
end
if m==1
    data.REF_trim=data.REF;
    data.Y_trim=data.Y;
    data.U_trim=data.U;
else
    data.REF_trim=data.REF(1:m:end,:);
    data.Y_trim=data.Y(1:m:end,:);
    data.U_trim=data.U(1:m:end,:);
    fprintf('Original number of points per variable: %i.\n\n',length(data.REF));
    fprintf('Trimmed number of points per variable: %i.\n\n',length(data.REF_trim));
end
if options.plotting_sim
    nn=1:1000;
    figure;
    subplot(2,1,1);
    plot(nn,data.REF(nn),'b--',nn,data.Y(nn),'rx')
    xlabel('number of points')
    ylabel('angle (rad)')
    legend('ref','y')
    title('Simulation without trimming (first 1000 points)');
    subplot(2,1,2);
    plot(nn,data.REF_trim(nn),'b--',nn,data.Y_trim(nn),'rx');
    xlabel('number of points')
    ylabel('angle (rad)')
    legend('ref','y')
    title(sprintf('Simulation with a trimming factor %i (first 1000 points)',m));
end
