function [Nnet] = keras2net(csv_file)
%keras2net Construct the network object from the keras model file
%   Detailed explanation goes here

nn_layers=importKerasLayers(csv_file,'OutputLayerType','regression','importweight',true)
% nn=importKerasNetwork(csv_file','OutputLayerType','regression')

training_options.neurons
end

