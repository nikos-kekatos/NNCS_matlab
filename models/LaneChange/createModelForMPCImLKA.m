function [sys,Vx] = createModelForMPCImLKA
% Create a discrete time model for the MPC design in a manner similar to
% the method used by the Lane Keeping Assist Simulink block.

% Copyright 2019 The MathWorks, Inc.

% Vehicle parameters.
m = 1575;
Iz = 2875;
lf = 1.2;
lr = 1.6;
Cf = 19000;
Cr = 33000;
Vx = 15;

% Specify vehicle state-space model with state varaibles [vy,phidot].
[Ag,Bg,Cg] = adasblocks_utilGetLatVehModelFromParam(m,Iz,lf,lr,Cf,Cr,Vx);

% Get the discrete-time model for MPC design.
Ts = 0.1;

% States are: [vy,phidot,e1,e2]
[A,B] = lkablock_utilGetDTModelNoLagForMPC(Ts,Vx,Ag,Bg,Cg);
C = eye(4);
D = zeros(4,2);
sys = ss(A,B,C,D,Ts);
end
