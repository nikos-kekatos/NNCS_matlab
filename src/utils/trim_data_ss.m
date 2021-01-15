function [data] = trim_data_ss(data,options)
%trim_data Trimming part of the data
%   We create fileds REF_trim, U_trim, Y_trim in the data structure by
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
    no_points_per_trace=no_points/options.no_traces;
    t_Start=options.trim_ss_time;
    index_start=t_Start/options.dt;
    index_end=options.T_train/options.dt; % no_points_per_trace
    % we delete the points that correspond to every $k$
    
    index_to_be_deleted=[];
    for i=1:options.no_traces
        index_to_be_deleted_per_trace=(index_start+(i-1)*no_points_per_trace):k:(index_end+(i-1)*no_points_per_trace);
        index_to_be_deleted=[index_to_be_deleted,index_to_be_deleted_per_trace];
    end
    %     index_to_be_deleted=index_to_be_deleted(2:end)';
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
    no_points=length(data.REF);
    no_points_per_trace=no_points/options.no_traces;
    t_Start=options.trim_ss_time;
    index_start=t_Start/options.dt;
    index_end=options.T_train/options.dt; % no_points_per_trace
    
    index_to_be_kept=[];
    for i=1:options.no_traces
        index_transient=(1:(index_start-1))+(i-1)*no_points_per_trace;
        index_to_be_kept_per_trace=(index_start+(i-1)*no_points_per_trace):m:(index_end+(i-1)*no_points_per_trace);
        index_to_be_kept=[index_to_be_kept,index_transient,index_to_be_kept_per_trace];
    end
    data.REF_trim=data.REF_trim(index_to_be_kept,:);
    data.Y_trim=data.Y_trim(index_to_be_kept,:);
    data.U_trim=data.U_trim(index_to_be_kept,:);
    fprintf('Original number of points per variable: %i.\n\n',length(data.REF));
    fprintf('Trimmed number of points per variable: %i.\n\n',length(data.REF_trim));
end

if options.plotting_sim
    if strcmp(options.SLX_model,'Quadrotor_stable')
        try
            nn=1:1000;
            figure;
            subplot(2,1,1);
            plot(nn,data.REF(nn,1),'b--',nn,data.Y(nn,2),'rx')
            xlabel('number of points')
            ylabel('variable 1')
            legend('ref','y')
            title('Simulation without trimming (first 1000 points)');
            subplot(2,1,2);
            plot(nn,data.REF_trim(nn,1),'b--',nn,data.Y_trim(nn,2),'rx');
            xlabel('number of points')
            ylabel('variable 1')
            legend('ref','y')
            title(sprintf('Simulation with a trimming factor %i (first 1000 points)'));
            figure;
            subplot(2,1,1);
            plot(nn,data.REF(nn,2),'b--',nn,data.Y(nn,3),'rx')
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title('Simulation without trimming (first 1000 points)');
            subplot(2,1,2);
            plot(nn,data.REF_trim(nn,2),'b--',nn,data.Y_trim(nn,3),'rx');
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title(sprintf('Simulation with a trimming factor %i (first 1000 points)'));
        end
    elseif contains(options.SLX_model,'Quadrotor_two_blocks')
        try     
            nn=1:10000;
            figure;
            subplot(2,1,1);
            plot(nn,data.REF(nn,1),'b--',nn,data.Y(nn,5),'rx')
            xlabel('number of points')
            ylabel('variable 1')
            legend('ref','y')
            title('Simulation without trimming (first 1000 points)');
            subplot(2,1,2);
            plot(nn,data.REF_trim(nn,1),'b--',nn,data.Y_trim(nn,5),'rx');
            xlabel('number of points')
            ylabel('variable 1')
            legend('ref','y')
            title(sprintf('Simulation with a trimming factor %i (first 1000 points)'));
            figure;
            subplot(2,1,1);
            plot(nn,data.REF(nn,2),'b--',nn,data.Y(nn,6),'rx')
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title('Simulation without trimming (first 1000 points)');
            subplot(2,1,2);
            plot(nn,data.REF_trim(nn,2),'b--',nn,data.Y_trim(nn,6),'rx');
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title(sprintf('Simulation with a trimming factor %i (first 1000 points)'));
            figure;
            subplot(2,1,1);
            plot(nn,data.REF(nn,3),'b--',nn,data.Y(nn,1),'rx')
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title('Simulation without trimming (first 1000 points)');
            subplot(2,1,2);
            plot(nn,data.REF_trim(nn,3),'b--',nn,data.Y_trim(nn,1),'rx');
            xlabel('number of points')
            ylabel('variable 2')
            legend('ref','y')
            title(sprintf('Simulation with a trimming factor %i (first 1000 points)'));
        end
    else
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
end
