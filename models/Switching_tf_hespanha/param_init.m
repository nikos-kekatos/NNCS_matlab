%% Initialization

s=tf('s');
plant=-1000/(s*(s+.875)*(s+50))


K1=(-6.694*(s+0.9446)*(s+50.01))/((s^2+13.23*s+9.453^2)*(s+50.05))
[num1,den1]=tfdata(K1);
K2=(-2187^2*(s+0.9977)*(s+66.28))/((s^2+467.2*s+486.2^2)*(s+507))
[num2,den2]=tfdata(K2);

[num1,den1,num2,den2]=deal(num1{1},den1{1},num2{1},den2{1});
T=50;
t0=0;
t1=18;
t2=40;
tend=T;
dt=0.001;
t_noise=(t2-t1)/dt;
variance = 10^-1; %10^(-snr/10);
noise_part = sqrt(variance)*randn(size(1:(t_noise)));
noise_var=[0*(t0:dt:(t1-dt)),noise_part,0*(t2:dt:(tend))];
noise.time=t0:dt:tend;
noise.signals.values=noise_var';
% noise.signals.dimensions=