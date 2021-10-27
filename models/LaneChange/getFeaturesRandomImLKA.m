function [x0,u0,rho] = getFeaturesRandomImLKA
% Generates random intitial conditions for lane keep assist simulation.

% Copyright 2019 The MathWorks, Inc.

%% States [vy,r,e1,e2]

% vy range : (-2,2) m/s
% r range  : (-60,60) deg/s
% e1 range : (-1,1) m
% e2 range : (-45,45) deg
x0 = [4*(rand-0.5),2.08*(rand-0.5),2*(rand-0.5),1.6*(rand-0.5)]';
%  x0 = [12*(rand-0.5),8.08*(rand-0.5),8*(rand-0.5),1.6*(rand-0.5)]';

%%
% Steering angle: range (-60,60) deg
u0 = 2.08*(rand-0.5);

%%
% Curvature: range (-0.01,0.01), minimum road radius 100m.
rho = 0.02*(rand-0.5);

end