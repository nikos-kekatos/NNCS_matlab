function [ xdesired ] = QuadrotorReferenceTrajectory_param( t,rx,ry,rz )
% This function generates reference signal for nonlinear MPC controller
% used in the quadrotor path following example.

% Copyright 2019 The MathWorks, Inc.

%#codegen
% x =6*sin(t/3);
% y = -6*sin(t/3).*cos(t/3);
% z = 6*cos(t/3);

% PWC
% x=[];y=[];z=[];
% for i=1:length(t)
%     if t(i)<10
%         x=[x,6];
%         y=[y,-6];
%         z=[z,6];
%     elseif t(i)>=10
%         x=[x,-6];
%         y=[y,6];
%         z=[z,-6];
%     end
% end
 x =rx*sin(t/3);
 y = ry*sin(t/3).*cos(t/3);
 z = rz*cos(t/3);
phi = zeros(1,length(t));
theta = zeros(1,length(t));
psi = zeros(1,length(t));
xdot = zeros(1,length(t));
ydot = zeros(1,length(t));
zdot = zeros(1,length(t));
phidot = zeros(1,length(t));
thetadot = zeros(1,length(t));
psidot = zeros(1,length(t));

xdesired = [x;y;z;phi;theta;psi;xdot;ydot;zdot;phidot;thetadot;psidot];
end

