%%  Train NN Controller
%the assignments could go a function/file
% load('trained_net_for_cex.mat')
training_options.retraining=0;
training_options.use_error_dyn=0;
training_options.use_previous_u=1;      % default=2
training_options.use_previous_ref=1;    % default=3
training_options.use_previous_y=1;      % default=3
% training_options.neurons=[20 10 10];
training_options.neurons=[30 30];
% training_options.neurons=[100 ];
training_options.input_normalization=0;
% training_options.loss='mse';
% training_options.loss='custom_v1';
training_options.loss='wmse';
global w
size_n=length((data.Y));

w=zeros(size_n,1);
w(1:floor(size_n/2))=0.1;
w(1+floor(size_n/2):size_n)=950;
training_options.algo= 'trainrp'%'trainlm'; % trainscg % trainrp
training_options.div='dividetrain';

%add option for saved mat files
[net_wmse,data]=nn_training(data,training_options,options);

%% Evaluate NN
plot_NN_sim(data,options)
%%
%the assignments could go a function/file
% load('trained_net_for_cex.mat')
training_options.retraining=0;
training_options.use_error_dyn=0;
training_options.use_previous_u=1;      % default=2
training_options.use_previous_ref=1;    % default=3
training_options.use_previous_y=1;      % default=3
% training_options.neurons=[20 10 10];
training_options.neurons=[30 30];
% training_options.neurons=[100 ];
training_options.input_normalization=0;
% training_options.loss='mse';
% training_options.loss='custom_v1';
training_options.loss='mse';
% global w
% size_n=length((data.Y));
% 
% w=zeros(size_n,1);
% w(1:floor(size_n/2))=0.1;
% w(1+floor(size_n/2):size_n)=0.95;
training_options.algo= 'trainrp'%'trainlm'; % trainscg % trainrp
%add option for saved mat files
[net_mse,data]=nn_training(data,training_options,options);
%% Evaluate NN
plot_NN_sim(data,options)