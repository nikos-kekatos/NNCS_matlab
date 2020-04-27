function [dX] = quad_ode(X)
x(1)=X(1);
x(2)=X(2);
x(3)=X(3);
x(4)=X(4);
x(5)=X(5);
x(6)=X(6);
x(7)=X(7);
x(8)=X(8);
x(9)=X(9);
x(10)=X(10);
x(11)=X(11);
x(12)=X(12);
F=X(13);
tau_phi=X(14);
tau_theta=X(15);
tau_psi=X(16);
% Randal Beard: Quadrotor Dynamics and Control Rev 0.1,

% x_1 = p_n
% x_2 = p_e
% x_3 = h

% x_4 = u
% x_5 = v
% x_6 = w

% x_7 = phi
% x_8 = theta
% x_9 = psi

% x_10 = p
% x_11 = q
% x_12 = r

% u_1 desired height

% paremeters
g = 9.81; %[m/s^2], gravity constant
R = 0.1;
l = 0.5;
M_rotor = 0.1;
M = 1;
m = M + 4*M_rotor;

% auxiliary parameters
J_x = 2*M*R^2/5 + 2*l^2*M_rotor;
J_y = J_x;
J_z = 2*M*R^2/5 + 4*l^2*M_rotor;

% % height control (PD)
% F = m*g - 10*(x(3) - u(1)) + 3*x(6);
% 
% % desired 
% 
% % roll control (PD)
% tau_phi = -(x(7) - u(2)) - x(10);
% 
% % pitch control (PD)
% tau_theta = -(x(8) - u(3)) - x(11);
% 
% % heading is uncontrolled:
% tau_psi = 0;

dX(1,1) = cos(x(8))*cos(x(9))*x(4) + (sin(x(7))*sin(x(8))*cos(x(9)) - cos(x(7))*sin(x(9)))*x(5) + (cos(x(7))*sin(x(8))*cos(x(9)) + sin(x(7))*sin(x(9)))*x(6);
dX(2,1) = cos(x(8))*sin(x(9))*x(4) + (sin(x(7))*sin(x(8))*sin(x(9)) + cos(x(7))*cos(x(9)))*x(5) + (cos(x(7))*sin(x(8))*sin(x(9)) - sin(x(7))*cos(x(9)))*x(6);
dX(3,1) = sin(x(8))*x(4) - sin(x(7))*cos(x(8))*x(5) - cos(x(7))*cos(x(8))*x(6);

dX(4,1) = x(12)*x(5) - x(11)*x(6) - g*sin(x(8));
dX(5,1) = x(10)*x(6) - x(12)*x(4) + g*cos(x(8))*sin(x(7));
dX(6,1) = x(11)*x(4) - x(10)*x(5) + g*cos(x(8))*cos(x(7)) - F/m;

dX(7,1) = x(10) + (sin(x(7))*tan(x(8)))*x(11) + (cos(x(7))*tan(x(8)))*x(12);
dX(8,1) = cos(x(7))*x(11) - sin(x(7))*x(12);
dX(9,1) = sin(x(7))/cos(x(8))*x(11) + cos(x(7))/cos(x(8))*x(12);

dX(10,1) = (J_y - J_z)/J_x*x(11)*x(12) + 1/J_x*tau_phi;
dX(11,1) = (J_z - J_x)/J_y*x(10)*x(12) + 1/J_y*tau_theta;
dX(12,1) = (J_x - J_y)/J_z*x(10)*x(11) + 1/J_z*tau_psi;
