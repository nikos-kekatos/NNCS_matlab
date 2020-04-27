function [net,data] = nn_training(data,training_options,options)
%nn_training This function is used for the NN training.
%   Detailed explanation goes here

if options.preprocessing_bool==1
    REF_array=data.REF_new;
    U_array=data.U_new;
    Y_array=data.Y_new;
else
    if options.trimming
        REF_array=data.REF_trim;
        U_array=data.U_trim;
        Y_array=data.Y_trim;
    else
        REF_array=data.REF;
        U_array=data.U;
        Y_array=data.Y;
    end
end
if training_options.retraining
    REF_array=data.REF_combined;
    U_array=data.U_combined;
    Y_array=data.Y_combined;
end
no_REF_array=size(REF_array,2);
no_U_array=size(U_array,2);
no_Y_array=size(Y_array,2);
if training_options.use_error_dyn
    if training_options.use_previous_y
        if training_options.use_previous_u
            in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                ]';
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
%                 in_REF=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)] [zeros(2,no_REF_array);REF_array(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)]];
%                 in_Y=[[Y_array] [zeros(1,no_Y_array);Y_array(1:end-1,:)] [zeros(2,no_Y_array);Y_array(1:end-2,:)] [zeros(3,no_Y_array);Y_array(1:end-3,:)]];
%                 in_U=[[zeros(1,no_U_array);U_array(1:end-1,:)] [zeros(2,no_U_array);U_array(1:end-2,:)]];
%                 in=[in_REF in_Y in_U]';
                in=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)] [zeros(2,no_REF_array);REF_array(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)]...
                    [Y_array] [zeros(1,no_Y_array);Y_array(1:end-1,:)] [zeros(2,no_Y_array);Y_array(1:end-2,:)] [zeros(3,no_Y_array);Y_array(1:end-3,:)]...
                    [zeros(1,no_U_array);U_array(1:end-1,:)] [zeros(2,no_U_array);U_array(1:end-2,:)]...
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

disp('')
disp('Training started')
% net=feedforwardnet([64 64 ]);
net=feedforwardnet(training_options.neurons);
%net.numLayers=3;
net = configure(net,in,out);
activationFcn='tansig'; % 'tansig' 'logisg' 'purelin' 'poslin'
net.layers{1}.transferFcn=activationFcn;
net.layers{2}.transferFcn=activationFcn;
% net.layers{2}.transferFcn='custom_v1';
net.performFcn=training_options.loss;
% net.performFcn='custom_v1';
net.trainFcn=training_options.algo;
net.trainParam.max_fail = 8;
net.performParam.ratio=0.5;
net.performParam.regularization = 0.1;   %needed for crossentropy
net.performParam.normalization = 'none';%'standard'; %needed for crossentropy

% net.trainParam.epochs = 100;
net.trainParam.goal = 1e-6;
% net.trainFcn= trainrp %trainlm %'traingdx' 'trainscg' 'crossentropy'
% net.divideFcn='divideint'
net.divideFcn=training_options.div;

net = init(net);
[net,tr] = train(net, in, out);
weights = getwb(net);
weight=net.IW{1};
weight1=net.LW{2};
b1=net.b{1};
b2=net.b{2};

p = [in];
uu = sim(net,p);
% perf = perform(net,in,out)

% load('random_reference_random_x0_multiple_simulations_153traces_robotic_arm_time_06-02-2020_11:25.mat')
% load('random_reference_random_x0_multiple_simulations_81traces_robotic_arm_time_05-02-2020_19:17.mat')
% load('random_reference_multiple_simulations_40traces_robotic_arm_time_05-02-2020_16:00.mat')
% load('random_reference_random_x0_multiple_simulations_289traces_robotic_arm_time_06-02-2020_22:46.mat')

data.in=in;
data.out=out;
data.out_NN=uu;
disp('')
disp('Training finished')
end

