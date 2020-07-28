function y=call_sim(u)

load('/Users/kekatos/Files/Projects/Gitlab/Matlab_Python_Interfacing/NNCS_matlab/modules/src/testing/sim_NN_timing/nn_2layers.mat');
y=sim(net,u);
end