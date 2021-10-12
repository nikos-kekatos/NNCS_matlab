function mv = neuralnetLKAmove(neuralnetmpcobj,x,lastmv,rho)
% NEURALNETLKAMOVE imitate mpc controller.
%
%   mv = NEURALNETLKAMOVE(neuralnetobj, x, u, rho)
%
%   Required inputs:
%          neuralnetmpcmove: Trained deep neural network object
%                         x: current states of the prediction model,
%                            specified as a vector of nx values.
%                   lastmv : last steering angle
%                       rho: curvature range (-0.01,0.01), minimum road
%                            radius 100m
%
%   Outputs:
%                        mv: column vector of optimal control actions

% Copyright 2019 The MathWorks, Inc.

% Input creation
input = [x',lastmv,rho];

% Number of observations
numObservations = length(input);

% Imitating MPC
mv = predict(neuralnetmpcobj, reshape(input',[numObservations 1 1 1]));

end