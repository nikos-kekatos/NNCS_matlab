function [x0,u0,rho] = generateRandomDataImLKA(data)
% Generates random input data that is not a member of the input dataset.

% Copyright 2019 The MathWorks, Inc.

% Generate input data
[x0,u0,rho] = getFeaturesRandomImLKA;

% Create a random input matrix
randomInput = [x0',u0,rho];

% Check if the random input is a member of the input data. If it is
% recursively run.
if ismember(randomInput,data(:,1:6),'rows')
    [x0,u0,rho] = generateRandomDataImLKA(data);
end
end