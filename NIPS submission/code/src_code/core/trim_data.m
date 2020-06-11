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
if isfield(options,'deleteData_factor')
    k=options.deleteData_factor;
else
    k=0;
end
if isempty(options.deleteData_factor)
    k=0;
end
data.REF_trim=data.REF;
data.Y_trim=data.Y;
data.U_trim=data.U;
if k~=0
    no_points=length(data.REF);
    % we delete the points that correspond to every $k$
    index_to_be_deleted=0:k:no_points;
    index_to_be_deleted=index_to_be_deleted(2:end)';
    data.REF_trim=data.REF;
    data.Y_trim=data.Y;
    data.U_trim=data.U;
    data.REF_trim(index_to_be_deleted,:)=[];
    data.Y_trim(index_to_be_deleted,:)=[];
    data.U_trim(index_to_be_deleted,:)=[];
    fprintf('Original number of points per variable: %i.\n\n',length(data.REF));
    fprintf('Trimmed number of points per variable: %i.\n\n',length(data.REF_trim));
end

if m~=1
    data.REF_trim=data.REF_trim(1:m:end,:);
    data.Y_trim=data.Y_trim(1:m:end,:);
    data.U_trim=data.U_trim(1:m:end,:);
    fprintf('Original number of points per variable: %i.\n\n',length(data.REF));
    fprintf('Trimmed number of points per variable: %i.\n\n',length(data.REF_trim));
end

if options.plotting_sim
    try
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
end
