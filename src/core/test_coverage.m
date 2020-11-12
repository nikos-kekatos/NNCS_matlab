function [testing,options] = test_coverage(options,model_name)
%test_coverage We test multiple simulations based on coverage
%   Detailed explanation goes here

if isempty(model_name)|| nargin==1
    % model_name = options.SLX_NN_model;
    model_name = options.SLX_model;
    
end
if options.testing.train_data==1 % test training points
    sim_cov_all=[];
    for i=1:length(options.coverage.cells)
        sim_cov_all=[sim_cov_all,options.coverage.cells{i}.random_value];
    end
elseif options.testing.train_data==0 % test centers
    sim_cov_all=options.coverage.cells_centers;
end

load_system(model_name);
options.input_choice=options.reference_type;

%{
%%% kept it for old models
block_name=strcat(model_name,'/Switch1');
set_param(block_name, 'sw', '1');
if options.reference_type==1
    block_name=strcat(model_name,'/Switch');
    set_param(block_name, 'sw', '0');
elseif options.reference_type==2
    block_name=strcat(model_name,'/Switch');
    set_param(block_name, 'sw', '1');
elseif options.reference_type==3
    block_name=strcat(model_name,'/Switch1');
    set_param(block_name, 'sw', '0');
end
%}

if options.save_sim
    
    % open file
    options.testing.filename=strcat('validate_testing_cover_',datestr(now,'dd-mm-yyyy_HH:MM'),'.txt');
    options.testing.filename=strcat('validate_testing_cover','.txt');
    
    fid = fopen(options.testing.filename,'wt');
    if (fid < 0)
        error('could not open file "myfile.txt"');
    end
    fprintf(fid,'No | x_min | x | x_max | y_min | y | y_max | x_test| y_test| mse_y | rmse_y| mae_y|\n');
    fprintf(fid,'-----------------------------------------------------------------------------------\n\n');
    warning off;
end
for i=1:options.no_traces
    %     warning('Add case for varying x0');
    fprintf(' Testing the NNCS -- %i iteration. \n\n', i);
    cc=0;
    % old models
    options.testing.sim_cov=sim_cov_all(:,i)';
    options.testing.ref_Ts=options.ref_Ts;
    options.sim_cov=options.testing.sim_cov;
    options.ref_Ts=options.testing.ref_Ts;
    options.workspace = simset('SrcWorkspace','current');
    if options.model==7
        Kp=0.0055;
        Ki=0.0131;
        Kd=3.3894e-004;
        N=9.9135;
    end
    sim(model_name,[],options.workspace);
    
%     [ref,y,u,options,y_nn,u_nn]=sim_SLX(model_name,options)
    
    if options.combination
        clear u y ref
        test_model=options.SLX_model;
        [ref,y,u]=sim_SLX(test_model,options);
    end
    testing.data.time{i}=ref.time;
    testing.data.REF_test{i}=ref.signals.values;
    testing.data.U_test{i}=u.signals.values;
    testing.data.U_NN_test{i}=u_nn.signals.values;
    testing.data.Y_test{i}=y.signals.values;
    testing.data.Y_NN_test{i}=y_nn.signals.values;
    
    %     [ref,y,u] = sim_SLX(model_name,options)
    if options.testing.plotting==1
        FIG = figure('rend', 'painters', 'pos', [200,200,1069,356], 'Color', 'w');
        AX = axes('NextPlot', 'add');
        set(AX, 'YScale', 'linear');
        axis(AX, 'tight');
        grid(AX);
        set(AX, 'FontSize', 12);
        xlabel(AX, '$t$', 'Interpreter', 'latex', 'FontSize', 20);
        ylabel(AX, '$\ y(k)$', 'Interpreter', 'latex', 'FontSize', 20);
        plot(ref.time(1:end-1),ref.signals.values(1:end-1),'r',y.time(1:end),y.signals.values(1:end),'g--',y_nn.time(1:end-1),y_nn.signals.values(1:end-1),'b-.','Linewidth',0.75);
        % xlabel('time (s)')
        % ylabel('plant output')
        legend('reference','nominal','NN','FontSize',14)
        title_name=sprintf('Simulating NNCS both with PID and NN -- Trace %i',i);
        title(title_name,'FontSize',18,'FontWeight','bold');
        
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
        % xlabel('time (s)')
        % ylabel('plant output')
        legend('nominal-PID','NN','FontSize',14)
        title_name=sprintf('Simulating NNCS both with PID and NN -- Trace %i',i);
        title(title_name,'FontSize',18,'FontWeight','bold');
    end
    
    options.testing.metric_method='mse';
    options.testing.metric_y=1;
    options.testing.metric_u=1;
    if options.testing.metric_method=='mse'
        if options.testing.metric_y==1
            %             mse_cover_box{i}.y=immse(y.signals.values,y_nn.signals.values);
            mse_cover_box{i}.y=(sum(y.signals.values(:)-y_nn.signals.values(:))^2)/numel(y.signals.values);
            fprintf(' The MSE error (y vs y_nn) in the %i box is  %.5f. \n\n',i,mse_cover_box{i}.y)
        end
        if options.testing.metric_u==1
            mse_cover_box{i}.u=(sum(y.signals.values(:)-y_nn.signals.values(:))^2)/numel(y.signals.values);
            fprintf(' The MSE error (u vs u_nn) in the %i box is  %.5f. \n\n',i,mse_cover_box{i}.u)
        end
    end
    testing.errors_coverage{i}.mse.y=(sum(y.signals.values(:)-y_nn.signals.values(:))^2)/numel(y.signals.values);
    testing.errors_coverage{i}.rmse.y=sqrt(testing.errors_coverage{i}.mse.y);
    
    testing.errors_coverage{i}.mae.y=sum(abs(y.signals.values(:)-y_nn.signals.values(:)))/numel(y.signals.values);
    fprintf(' The MAE error (y vs y_nn) in the %i box is  %.5f. \n\n',i,testing.errors_coverage{i}.mae.y)
    if options.save_sim
        fprintf(fid,'%i | %.4f  | x | %.4f  | %.4f  | y | %0.4f  | %.4f | %.4f | %.6f | %.6f | %.6f  |\n',i, options.coverage.cells{i}.min(1),options.coverage.cells{i}.max(1),options.coverage.cells{i}.min(2),options.coverage.cells{i}.max(2),options.coverage.cells{i}.centers(1),options.coverage.cells{i}.centers(2),testing.errors_coverage{i}.mse.y,testing.errors_coverage{i}.rmse.y,testing.errors_coverage{i}.mae.y);
    end
    % close the file
end
%{
    fprintf(' The nominal value is %.5f. \n\n',y.signals.values(end))
    
    fprintf(' The NN value is %.5f. \n\n',y_nn.signals.values(end))
    
    ss_abs(i)=y_nn.signals.values(end)-y.signals.values(end);
    fprintf(' The absolute ss error is %.5f. \n\n',ss_abs(i))
    ss_rel(i)=(y_nn.signals.values(end)-y.signals.values(end))/y.signals.values(end)*100;
    fprintf(' The relative ss error is %.5f (perc). \n\n',ss_rel(i))
%}
all_mse=[];
for i=1:length(testing.errors_coverage)
    all_mse=[all_mse;testing.errors_coverage{i}.mse.y];
end
fprintf('The average MSE error over %i simulations is %.5f.\n\n',options.no_traces,sum(all_mse)/options.no_traces);
fprintf('The maximum MSE error over %i simulations is %.5f.\n\n',options.no_traces,max(all_mse));
if options.save_sim
    % close the file
    fclose(fid);
end

% plot_coverage_boxes(testing,options,0)
close_system(model_name)
end

