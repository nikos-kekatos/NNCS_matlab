%% Simulating a standalone NN in Matlab vs Simulink (timing)

% This script aims to report the computational times for the simulation of
% a NN in Simulink and Matlab. The first option is to use Matlab object (network)
% and the second is to use a Simulink block (constructed via gensim).

% Usage: run the entire file
%% Initialization

clear
close
clc

%% Select example net

example=2;
if example==1
    mat_file='nn_2layers.mat';
    model_name='testing_time_net_2layers'
elseif example==2
    mat_file='nn_3layers.mat'
    model_name='testing_time_net_3layers'
end

load(mat_file)
% create net
% gensim(net)


%% find info

view(net)
num_input_layers=net.numInputs;
if num_input_layers==1
    num_inputs=net.inputs{num_input_layers}.size;
else
    for i=1:num_input_layers
        num_inputs=net.inputs{i}.size;
    end
end
fprintf('The num of inputs is %i.\n\n',num_inputs);

%% Timing analysis

no_iterations=20;
for i=1:no_iterations
    tic
    if i==1 && example==1
        in1=[0.59;0.47;0.29;0.28;0.17;0.58];
    elseif i>1 && example==1
        in1=rand(1,6)'*10;
    elseif i==1 && example==2
        in1=[0.04;0.048;0.46;0.82;0.7;0.55;0.2;0.64;0.045;0.72];
    elseif i>1 && example==2
        in1=rand(1,10)'*10;   
    end
    out1=sim(net,in1);
    t1{i}=toc;
    
    tic;
    sim(model_name);
    t2{i}=toc;
    
    fprintf('Iteration %i -- Matlab: %.5f sec vs. Simulink %.5f sec.\n\n',i,t1{i},t2{i})
end

fprintf('After %i iterations, the average values are Matlab: %.5f sec vs. Simulink %.5f sec.\n\n',no_iterations,sum(t1)/length(t1),sum(t2)/length(t2))

