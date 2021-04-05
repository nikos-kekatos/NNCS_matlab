%% Simulink Example

% Specify damping coefficient.
c = 5;   
% Specify stiffness.
k = 300; 
% Specify load command.
u = 1:10;
% Specify mass.
m = 10*u + 0.1*u.^2;
% Compute linear system at a given mass value.
for i = 1:length(u)
   A = [0 1; -k/m(i), -c/m(i)];
   B = [0; 1/m(i)];
   C = [1 0];
   sys(:,:,i) = ss(A,B,C,0); 
end
%%
% clear 
options.dt=0.01;
options.noise_T1= 18;
options.noise_T2= 40;
try
s=tf('s');
end
P=-1000/(s*(s+.875)*(s+50))


K1=(-6.694*(s+0.9446)*(s+50.01))/((s^2+13.23*s+9.453^2)*(s+50.05));
K2=(-2187^2*(s+0.9977)*(s+66.28))/((s^2+467.2*s+486.2^2)*(s+507));

ss1=ss(K1);
ss2=ss(K2);
sysP=ss(P);
sys(:,:,1)=ss1;
sys(:,:,2)=ss2;
t=0:22:42
sys.SamplingGrid = struct('LoadCommand',t);
