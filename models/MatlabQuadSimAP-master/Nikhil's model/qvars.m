% Wil Selby
% Washington, DC
% May 30, 2015

% This script defines and initializes the variables for the quadrotor simulator.                                  %


%% Initialize Variables

% Simulation Parameters
init = 0;     % used in initilization 
Ts = .01;     % Sampling time (100 Hz)
sim_time = 10; % Simulation time (seconds)
counter = 1;                      % the counter that holds the time value

% Plotting Variables
t_plot = [0:Ts:sim_time-Ts];       % the time values
Xtemp = 0;     % Temp variables used rotating and plotting quadrotor
Ytemp = 0;     % Temp variables used rotating and plotting quadrotor
Ztemp = 0;     % Temp variables used rotating and plotting quadrotor

% Environmental Parametes
g = 9.81;     % Gravity (m/s^2)

% Quadrotor Physical Parameters
m = 1.4;      % Quadrotor mass (kg)
l = .56;     % Distance from the center of mass to the each motor (m)
t = .02;   %Thickness of the quadrotor's arms for drawing purposes (m)
rot_rad = .1;   %Radius of the propellor (m)
Kd = 1.3858e-6;    % Drag torque coeffecient (kg-m^2)

Kdx = 0.16481;    % Translational drag force coeffecient (kg/s)
Kdy = 0.31892;    % Translational drag force coeffecient (kg/s)
Kdz = 1.1E-6;    % Translational drag force coeffecient (kg/s)

Jx = .05;     % Moment of inertia about X axis (kg-m^2)
Jy = .05;     % Moment of inertia about Y axis (kg-m^2)
Jz = .24;    % Moment of inertia about Z axis (kg-m^2)

% Quadrotor Sensor Paramaters
GPS_freq = (1/Ts)/1;  
X_error = .01;  %+/- m
Y_error = .01;  %+/- m
Z_error = .02;  %+/- m

x_acc_bias = 0.16594;  % m/s^2
x_acc_sd = 0.0093907;
y_acc_bias = 0.31691;  % m/s^2
y_acc_sd = 0.011045;
z_acc_bias = -8.6759;  % m/s^2
z_acc_sd = 0.016189;

x_gyro_bias = 0.00053417;  % rad/s
x_gyro_sd = 0.00066675;
y_gyro_bias = -0.0011035;  % rad/s
y_gyro_sd = 0.00053642;
z_gyro_bias = 0.00020838;  % rad/s
z_gyro_sd = 0.0004403;

ground_truth = 1;  % Use perfect sensor measurements
sensor_unfiltered = 0; % Use sensor errors, no filter
sensor_kf = 0;     % Use sensor error, Kalman Filter

% Motor Parameters
KT = 1.3328e-5;    % Thrust force coeffecient (kg-m)
Jp = 0.044;     % Moment of Intertia of the rotor (kg-m^2)
max_motor_speed = 925; % motors upper limit (rad/s)
min_motor_speed = 0; %-1*((400)^2); % motors lower limit (can't spin in reverse)

Obar = 0;     % sum of motor speeds (O1-O2+O3-O4, N-m) 
O1 = 0;       % Front motor speed (raidans/s)
O2 = 0;       % Right motor speed (raidans/s)
O3 = 0;       % Rear motor speed (raidans/s)
O4 = 0;       % Left motor speed (raidans/s)

%Translational Positions
X = 0;        % Initial position in X direction GF (m)
Y = 0;        % Initial position in Y direction GF (m)
Z = 0;        % Initial position in Z direction GF (m)
X_BF = 0;     % Initial position in X direction BF (m)
Y_BF = 0;     % Initial position in Y direction BF (m)
Z_BF = 0;     % Initial position in the Z direction BF (m)

%Translational Velocities
X_dot = 0;    % Initial velocity in X direction GF (m/s)
Y_dot = 0;    % Initial velocity in Y direction GF (m/s)
Z_dot = 0;    % Initial velocity in Z direction GF (m/s)
X_dot_BF = 0;    % Initial velocity in X direction BF (m/s)
Y_dot_BF = 0;    % Initial velocity in Y direction BF (m/s)
Z_dot_BF = 0;    % Initial velocity in Y direction BF (m/s)

%Angular Positions
phi = 0;      % Initial phi value (rotation about X GF, roll,  radians)
theta = 0;    % Initial theta value (rotation about Y GF, pitch, radians)
psi = 0;      % Initial psi value (rotation about Z GF, yaw, radians)

%Angular Velocities
p = 0;        % Initial p value (angular rate rotation about X BF, radians/s)
q = 0;        % Initial q value (angular rate rotation about Y BF, radians/s)
r = 0;        % Initial r value (angular rate rotation about Z BF, radians/s)

% Desired variables
X_des_GF = 1;         % desired value of X in Global frame
Y_des_GF = 1;         % desired value of Y in Global frame
Z_des_GF = 1;         % desired value of Z in Global frame
X_des = 0;            % desired value of X in Body frame
Y_des = 0;            % desired value of Y in Body frame
Z_des = 0;            % desired value of Z in Body frame

phi_des = 0;          % desired value of phi (radians)
theta_des = 0;        % desired value of theta (radians)
psi_des = pi/6;          % desired value of psi (radians)

% Measured variables
X_meas = 0;
Y_meas = 0;
Z_meas = 0;
phi_meas = 0;
theta_meas = 0;
psi_meas = 0;

% Disturbance Variables
Z_dis = 0;            % Disturbance in Z direction
X_dis = 0;            % Disturbance in X direction
Y_dis = 0;            % Ddisturbance in Y direction
phi_dis = 0;            % Disturbance in Yaw direction
theta_dis = 0;            % Disturbance in Pitch direction
psi_dis = 0;            % Disturbance in Roll direction

% Control Inputs
U1 = 0;       % Total thrust (N)
U2 = 0;       % Torque about X axis BF (N-m)
U3 = 0;       % Torque about Y axis BF (N-m)
U4 = 0;       % Torque about Z axis BF (N-m)

% Control Limits (update values)
U1_max = 43.5;   % KT*4*max_motor_speed^2
U1_min = 0;      % 
U2_max = 6.25;  % KT*l*max_motor_speed^2
U2_min = -6.25; % KT*l*max_motor_speed^2
U3_max = 6.25;  % KT*l*max_motor_speed^2
U3_min = -6.25; % KT*l*max_motor_speed^2
U4_max = 2.25; % Kd*2*max_motor_speed^2
U4_min = -2.25;% Kd*2*max_motor_speed^2

% PID parameters
X_KP = .1;          % KP value in X position control
X_KI = 0;            % KI value in X position control
X_KD = -0.1;         % KD value in X position control
X_KI_lim = .25;         % Error to start calculating integral term

Y_KP = .1;          % KP value in Y position control
Y_KI = 0;            % KI value in Y position control
Y_KD = -0.1;         % KD value in Y position control
Y_KI_lim = .25;         % Error to start calculating integral term

Z_KP = 4;    % KP value in altitude control
Z_KI = 0;    % KI value in altitude control
Z_KD = -4;  % KD value in altitude control
Z_KI_lim = .25;         % Error to start calculating integral term

phi_KP = 4.5;      % KP value in roll control 2
phi_KI = 0;       % KI value in roll control   1        
phi_KD = 0;     % KD value in roll control  -.5
phi_max = pi/4;   % Maximum roll angle commanded
phi_KI_lim = 2*(2*pi/360);  % Error to start calculating integral 

theta_KP = 4.5;    % KP value in pitch control 2
theta_KI = 0;     % KI value in pitch control 1
theta_KD = 0;   % KD value in pitch control -.5
theta_max = pi/4; % Maximum pitch angle commanded
theta_KI_lim = 2*(2*pi/360);  % Error to start calculating integral 

psi_KP = 10;     % KP value in yaw control
psi_KI = 0;     % KI value in yaw control .75
psi_KD = 0;     % KD value in yaw control -.5
psi_KI_lim = 8*(2*pi/360);  % Error to start calculating integral 

p_KP = 2.7;    % KP value in pitch control 2
p_KI = 1;     % KI value in pitch control
p_KD = -.01;   % KD value in pitch control -.5
p_max = 50*(2*pi/360); % Maximum pitch angle commanded
p_KI_lim = 10*(2*pi/360);  % Error to start calculating integral 

q_KP = 2.7;    % KP value in pitch control
q_KI = 1;     % KI value in pitch control
q_KD = -.01;   % KD value in pitch control -.5
q_max = 50*(2*pi/360); % Maximum pitch angle commanded
q_KI_lim = 10*(2*pi/360);  % Error to start calculating integral 

r_KP = 2.7;    % KP value in pitch control
r_KI = 1;     % KI value in pitch control
r_KD = -.01;   % KD value in pitch control
r_max = 50*(2*pi/360); % Maximum pitch angle commanded
r_KI_lim = 10*(2*pi/360);  % Error to start calculating integral 


Jr=Jp;
% pval=[Q.Kp_x,Q.Ki_x,Q.Kd_x,Q.Kp_y,Q.Ki_y,Q.Kd_y,Q.Kp_z,Q.Ki_z,Q.Kd_z,Q.Kp_phi,Q.Ki_phi,Q.Kd_phi,Q.Kp_theta,Q.Ki_theta,Q.Kd_theta,Q.Kp_psi,Q.Ki_psi,Q.Kd_psi];       
% pval=[.1,0,-.1,.1,0,-.1,4,0,-4,4.5,0,0,4.5,0,0,10,0,0];
init_quadrotor_full('Quad_sim',2,1)