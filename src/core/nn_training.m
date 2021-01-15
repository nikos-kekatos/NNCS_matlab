function [net,data,tr] = nn_training(data,training_options,options)
%nn_training This function is used for the NN training.
%   Detailed explanation goes here

if options.preprocessing_bool==1
    REF_array=data.REF_new;
    U_array=data.U_new;
    Y_array=data.Y_new;
else
    if options.trimming || options.trimming_steady_state
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

[in,out]=prepare_NN_structure(REF_array,Y_array,U_array,training_options,options,data);

% [in,out]=replace_zeros(in,out,training_options,options);

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
net.trainParam.max_fail = training_options.max_fail;
net.performParam.ratio=training_options.param_ratio;
net.performParam.regularization = training_options.regularization;   %needed for crossentropy
net.performParam.normalization = 'none';%'standard'; %needed for crossentropy

% net.trainParam.epochs = 100;
net.trainParam.goal = training_options.error; %1e-6;
% net.trainFcn= trainrp %trainlm %'traingdx' 'trainscg' 'crossentropy'
% net.divideFcn='divideint'
net.divideFcn=training_options.div;
net.initFcn='initlay';
%net.layers{1}.initFcn='initnw';
%net.layers{2}.initFcn='initnw';
%net.layers{3}.initFcn='initnw';
net = init(net);
% net.trainParam.showWindow=false;
% net.trainParam.showCommandLine=true;
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

