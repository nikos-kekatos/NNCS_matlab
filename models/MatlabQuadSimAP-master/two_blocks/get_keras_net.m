%%

clear nnet  keras
% nnet=net;
nnet=feedforwardnet([50 30 ])
%nnet.outputs{3}.processFcns(2) = [];
%nnet.inputs{1}.processFcns(2) = [];
% data.in=rand(15,1000)
% data.out=rand(2,1000)
nnet = configure(nnet,data.in,data.out);

% keras_file='keras_nn_hespanha_v1.h5';
keras_file='keras_nn_akshay_no_norm_v1.h5';

keras_=importKerasNetwork(keras_file)
keras_layers=importKerasLayers(keras_file,'OutputLayerType','regression','importweight',true,'ImageInputSize',[15,1])
keras.IW{1,1}=keras_layers(2).Weights
keras.b{1}=keras_layers(2).Bias
keras.LW{2,1}=keras_layers(4).Weights
keras.b{2}=keras_layers(4).Bias
keras.LW{3,2}=keras_layers(6).Weights
keras.b{3}=keras_layers(6).Bias
nnet.IW{1,1}=double(keras.IW{1,1})
nnet.LW{2,1}=double(keras.LW{2,1})
nnet.LW{3,2}=double(keras.LW{3,2})
nnet.b{1}=double(keras.b{1})
nnet.b{2}=double(keras.b{2})
nnet.b{3}=double(keras.b{3})
%%
% nnet.outputs{2}.processFcns(2) = [];
% nnet.inputs{1}.processFcns(2) = [];
% gensim(net)
[options]=create_NN_diagram(options,nnet);

file_name='Quadrotor_two_blocks_v3';
file_name='QuadrotorSimulink_w_memory'
% file='hespanha_comb_NN';

construct_SLX_with_NN(options,file_name);

%% min /max
%{
minX=[0.200011437481734499765906321045;0.000287032703115897046882570853299;0;0;0;0;-1.30256813748516061353052708505e-05;0;-0.00594070155344859386625788744141;-1.30256813748516061353052708505e-05;0;-0.00594070155344859386625788744141;-1.30256813748516061353052708505e-05;0;-0.00594070155344859386625788744141]
maxX=[0.296826157571939752699563541682;0.0997322850451480558131578391112;0.296826157571939752699563541682;0.0997322850451480558131578391112;0.296826157571939752699563541682;0.0997322850451480558131578391112;4.06657724816437399066072766463e-05;0.347464951626831164421815856258;0.111692188623430582739004535142;4.06657724816437399066072766463e-05;0.347464951626831164421815856258;0.111692188623430582739004535142;4.06657724816437399066072766463e-05;0.347464951626831164421815856258;0.111692188623430582739004535142]
minmaxX=[minX,maxX]

minmaxIN=[min(data.in,[],2),max(data.in,[],2)]
minmaxOUT=[min(data.out,[],2),max(data.out,[],2)]
minY=[-0.0296826157571939766577351349497;-0.00751743477949804762838770244571]
maxY=[0.0103453473502258478516901973876;0.00997322850451480558131578391112]
minmaxY=[minY,maxY]
%}
%%
options.input_choice=3;
% model=2;
options.error_mean=0;%0.0001;
options.error_sd=0;%0.001;

    options.ref_Ts=25;             %tank_reactor
    options.sim_ref=3;
    options.ref_min=2;
    options.ref_max=5;
    options.sim_cov=[0.1;0.2];%[data.REF(end,1)];
    options.u_index_plot=1;
    options.y_index_plot=2;
    options.ref_index_plot=1;
    options.T_train=50;
run_simulation_nncs(options,file_name,1);
% options.input_choice=4