%clc;clear;


%Physical Parameters:
g = 9.81;
m = 1.4; %Weight Kg
l = 0.56; %Distance from CM to BLDC (m)
Kd = 1.3858e-6; %Drag Torque (kg-m^2)

Kdx = 0.16481;
Kdy = 0.31892;   %Translational Drag coeffficient (kg/s)
Kdz = 1.1e-6;

Jx = 0.05;
Jy = 0.05;     %Moment of inertia (kg-m^2)
Jz = 0.24;

%BLDC Parameters:
KT = 1.3328e-5; %Thrust force coefficient (kg-m)
Jr = 0.044;     %Moment of Inertia of rotor (kg-m^2)
max_motor_speed = 925;    %(rad/s)
min_motor_speed = 0;

%Control Limits
U1_max = 43.5;
U1_min = 0;
U2_max = 6.25;
U2_min = -6.25;
U3_max = 6.25;
U3_min = -6.25;
U4_max = 2.25;
U4_min = -2.25;

%PID parameters
% Kp_x = 0.1;
% Ki_x = 0;
% Kd_x = -0.16;
% 
% Kp_y = 0.1;
% Ki_y = 0;
% Kd_y = -0.16;
% 
% Kp_z = 4;
% Ki_z = 0;
% Kd_z = -4;
% 
% Kp_phi = 4.5;
% Ki_phi = 0;
% Kd_phi = 0;
phi_max = pi/4;

% Kp_theta = 4.5;
% Ki_theta = 0;
% Kd_theta = 0;
theta_max = pi/4;

% Kp_psi = 10;
% Ki_psi = 0;
% Kd_psi = 0;

Kp_p = 2.7;
%Ki_p = 1;
Ki_p=0;
Kd_p = -0.01;
p_max = 50*(2*pi/360);

Kp_q = 2.7;
%Ki_q = 1;
Ki_q=0;
Kd_q = -0.01;
q_max = 50*(2*pi/360);

Kp_r = 2.7;
Ki_r = 1;
Ki_r=0;
Kd_r = -0.01;
r_max = 50*(2*pi/360);

