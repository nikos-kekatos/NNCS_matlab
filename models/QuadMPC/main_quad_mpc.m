%% SETUP
clear;close all;clc;

addpath(genpath('../../'))

% mpc code/initialization and definition
quad_mpc_init;

% configuration options
config_quad_mpc;
options.pretrained=0;

%% TRACE GENERATION
% Specify the initial conditions
x0 = [7;-10;0;0;0;0;0;0;0;0;0;0];
if ~options.pretrained
    
    timer_trace_gen=tic; % clock for trace generation
    
    % Closed-Loop Simulation
    % Simulate the system for 20 seconds with a target trajectory to follow.
    
    % Nominal control that keeps the quadrotor floating
    nloptions = nlmpcmoveopt;
    nloptions.MVTarget = [4.9 4.9 4.9 4.9];
    % nloptions.MVTarget = [6 6 6 6];
    
    mv = nloptions.MVTarget;
    % Simulate the closed-loop system using the nlmpcmove function, specifying simulation options using an nlmpcmove object.
    Duration = options.T_train;
    
    data.REF=[];
    data.U=[];
    data.Y=[];
    
    %%% Running for a single reference takes around 40-50 seconds
    
    % to run all reference traces, uncomment the next line (it takes longer)
    for i=1:options.no_traces
        
        % run only 8 reference trace (out of 27), use next command
        % for i=1:8%options.no_traces
        
        clearvars  uk xk uHistory lastMV xHistory TOUT YOUT
        rx=options.cells{i}.random_value(1);
        ry=options.cells{i}.random_value(2);
        rz=options.cells{i}.random_value(3);
        fprintf('\n\n Iteration %i.\n\n',i);
        hbar = waitbar(0,'Simulation Progress');
        xHistory = x0';
        lastMV = mv;
        % lastMV=[4.9 4.9 4.9 4.9];
        uHistory = lastMV;
        
        
        for k = 1:(Duration/Ts)
            % Set references for previewing
            t = linspace(k*Ts, (k+p-1)*Ts,p);
            %     yref = QuadrotorReferenceTrajectory(t);
            yref = QuadrotorReferenceTrajectory_param(t,rx,ry,rz);
            
            % Compute the control moves with reference previewing.
            xk = xHistory(k,:);
            [uk,nloptions,info] = nlmpcmove(nlobj,xk,lastMV,yref',[],nloptions);
            uHistory(k+1,:) = uk';
            lastMV = uk;
            % Update states.
            ODEFUN = @(t,xk) QuadrotorStateFcn(xk,uk);
            [TOUT,YOUT] = ode45(ODEFUN,[0 Ts], xHistory(k,:)');
            xHistory(k+1,:) = YOUT(end,:);
            waitbar(k*Ts/Duration,hbar);
        end
        close(hbar)
        % Visualization and Results
        % Plot the results, and compare the planned and actual closed-loop trajectories.
        
        
        % Plot the closed-loop response.
        time = 0:Ts:Duration;
        yreftot = QuadrotorReferenceTrajectory(time)';
        
        options.plotting_sim=0;
        if options.plotting_sim
            plotQuadrotorTrajectory;
        end
        % Because the number of MVs is smaller than the number of reference output trajectories, there are not enough degrees of freedom to track the desired trajectories for all OVs.
        % As shown in the figure for states  and control inputs,
        % The states  match the reference trajectory very closely within 7 seconds.
        % The states  are driven to the neighborhood of zeros within 9 seconds.
        % The control inputs are driven to the target value of 4.9 around 10 seconds.
        % You can animate the trajectory of the quadrotor. The quadrotor moves close to the "target" quadrotor which travels along the reference trajectory within 7 seconds. After that, the quadrotor follows closely the reference trajectory. The animation terminates at 20 seconds.
        
        % animateQuadrotorTrajectory;
        ref_simu=yreftot(:,1:6);
        u_simu=uHistory;
        y_simu=xHistory;
        data.REF=[data.REF;ref_simu];
        data.U=[data.U;u_simu];
        data.Y=[data.Y;y_simu];
        
    end
    timer.trace_gen=toc(timer_trace_gen)
    % data.REF=data.REF'
    % data.U=data.U'
    % data.Y=data.Y'
elseif options.pretrained
    load('27_traces_3x6.mat')
end
%% TRAINING

display_ranges(data);

% You can select references. In total there are six.
% The first three (x,y,z) are sinusoids,
% The last three: all zeros.

% xyz references
data.REF=data.REF(:,1:3); % comment if you want all references

data.REF=data.REF(:,:); % comment if you want all references

% You can select plant outputs. In total there are 12.
% The first six are states while the last 6 are state derivatives.
% no_y=12;
no_y=6;
data.Y=data.Y(:,1:no_y);

options.trimming_steady_state=0;
timer_train=tic;
training_options.retraining=0;
training_options.use_error_dyn=0;      % answer: 0 or 1, use error dynamics or not
training_options.use_previous_u=0;     % answer: integer, number of previous u values
training_options.use_previous_ref=2;   % answer: integer, number of previous references
training_options.use_previous_y=2;     % answer: integer, number of previous outputs
options.extra_y=0;
training_options.use_time=0;
training_options.use_future_ref=1;

% training_options.neurons=[30 16 8];
training_options.neurons=[30  15]; % 2 layers, 1st layer: 30 neurons, 2nd layer: 15 neurons
training_options.input_normalization=0;
training_options.loss='mse';
% training_options.loss='custom_v1';
% training_options.loss='wmse';
training_options.div='dividerand';
% training_options.div='dividetrain';
training_options.error=1e-5;
training_options.max_fail=50; % Validation performance has increased more than max_fail times since the last time it decreased (when using validation).
training_options.regularization=0; %0-1
training_options.param_ratio=0.5;
training_options.algo= 'trainlm'%'trainlm'; % trainscg % trainrp
%add option for saved mat files
training_options.iter_max_fail=1; % maximum number of iterations
iter=1;reached=0;
training_options.replace_by_zeros=1;
while true && iter<=training_options.iter_max_fail
    fprintf('\n Iteration %i.\n',iter);
    [net,data,tr]=nn_training(data,training_options,options);
    net_all{iter}=net;
    tr_all{iter}=tr;
    if tr_all{iter}.best_perf<training_options.error*10 && tr_all{iter}.best_vperf<training_options.error*100
        reached=1;
        break;
    else
        if iter<training_options.iter_max_fail
            iter=iter+1;
        else
            break;
        end
    end
end
fprintf('\n The requested training error was %f.\n',training_options.error);
if reached
    fprintf('The obtained training error is %f reached after %i random initializations.\n',tr_all{iter}.best_perf,iter);
    fprintf('The validation error is %f.\n',tr_all{iter}.best_vperf);
    net=net_all{iter};
    tr=tr_all{iter};
else
    fprintf('\n We ran %i training attempts with random initializations.\n',iter);
    for ii=1:iter
        training_perf(ii)=tr_all{ii}.best_perf;
    end
    iter_best=find(training_perf==min(training_perf));
    fprintf('\n The smallest training error was %f.\n',tr_all{iter_best}.best_vperf);
    fprintf('\n The smallest validation error was %f.\n',tr_all{iter_best}.best_vperf);
    net=net_all{iter_best};
    tr=tr_all{iter_best};
end
timer.train=toc(timer_train)
options.plotting_sim=1

if options.plotting_sim
    %     figure;plotperform(tr)
    plot_NN_sim(data,options);
end
%% NN Model/ Simulink

options.SLX_model='quad_mpc_nn';

% gensim(net)
[options]=create_NN_diagram(options,net);

% Integrate NN block in the Simulink model
construct_SLX_with_NN(options,options.SLX_model);

% Simulate the closed-loop
sim(options.SLX_model)
figure;
subplot(3,1,1)
plot(out.Ref_1(:,1),out.Ref_1(:,2),'r--',out.Ref_1(:,1),out.Ref_1(:,3),'b-x')
xlabel('time [s]')
ylabel(' values [m]')
legend('reference','y')
title('Reference 1')
subplot(3,1,2)
plot(out.Ref_2(:,1),out.Ref_2(:,2),'r--',out.Ref_2(:,1),out.Ref_2(:,3),'b-x')
xlabel('time [s]')
ylabel(' values [m]')
legend('reference','y')
title('Reference 2')
subplot(3,1,3)
plot(out.Ref_3(:,1),out.Ref_3(:,2),'r--',out.Ref_3(:,1),out.Ref_3(:,3),'b-x')
xlabel('time [s]')
ylabel(' values [m]')
legend('reference','y')
title('Reference 3')