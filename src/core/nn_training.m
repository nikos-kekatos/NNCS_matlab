function [net,data] = nn_training(data,training_options,options)
%nn_training This is for the NN training.
%   Detailed explanation goes here

if options.preprocessing_bool==1
    REF_array=data.REF_new;
    U_array=data.U_new;
    Y_array=data.Y_new;
else
    REF_array=data.REF;
    U_array=data.U;
    Y_array=data.Y;
end


if training_options.use_error_dyn
    if training_options.use_previous_y
        if training_options.use_previous_u
            in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                [0;0;0;U_array(1:end-3)]]';
        else
            in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)]]';
        end
    else
        in=[REF_array-Y_array]';
    end
else
    if training_options.use_previous_y
        if training_options.use_previous_ref
            if training_options.use_previous_u
                in=[[REF_array] [0;REF_array(1:end-1)] [0;0;REF_array(1:end-2)] [0;0;0;REF_array(1:end-3)]...
                    [Y_array] [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)] [0;0;0;Y_array(1:end-3)]...
                    [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                    ]';
            else
                in=[[REF_array] [0;REF_array(1:end-1)] [0;0;REF_array(1:end-2)] [0;0;0;REF_array(1:end-3)]...
                    [Y_array] [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)] [0;0;0;Y_array(1:end-3)]...
                    ]';
            end
        else
            if training_options.use_previous_u
                in=[REF_array Y_array [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)]...
                    [0;0;0;Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                    ]';
            else
                in=[[REF_array] ...
                    [Y_array] [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)] [0;0;0;Y_array(1:end-3)]...
                    ]';
            end
        end
    else
        if training_options.use_previous_u
            in=[REF_array Y_array...
                [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                ]';
        else
            in=[[REF_array] ...
                [Y_array] ...
                ]';
        end
    end
end

% Output
out=U_array';

% Input normalization
if training_options.input_normalization==1
in=mapminmax(in);
end

% net=feedforwardnet([64 64 ]);
net=feedforwardnet(training_options.neurons);
%net.numLayers=3;
net = configure(net,in,out);
activationFcn='tansig' % 'tansig' 'logisg' 'purelin' 'poslin'
net.layers{1}.transferFcn=activationFcn;
net.layers{2}.transferFcn=activationFcn;

% net.trainParam.epochs = 100;
% net.trainParam.goal = 1e-6;
% net.trainFcn= trainlm %'traingdx' 'trainscg' 'crossentropy'
% net.divideFcn='divideint'
net = init(net);
[net,tr] = train(net, in, out);
weights = getwb(net);
weight=net.IW{1};
weight1=net.LW{2};
b1=net.b{1};
b2=net.b{2};

p = [in];
uu = sim(net,p);
perf = perform(net,in,out)

% load('random_reference_random_x0_multiple_simulations_153traces_robotic_arm_time_06-02-2020_11:25.mat')
% load('random_reference_random_x0_multiple_simulations_81traces_robotic_arm_time_05-02-2020_19:17.mat')
% load('random_reference_multiple_simulations_40traces_robotic_arm_time_05-02-2020_16:00.mat')
% load('random_reference_random_x0_multiple_simulations_289traces_robotic_arm_time_06-02-2020_22:46.mat')

data.in=in;
data.out=out;
end

