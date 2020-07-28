%% Matlab  SIMULINK and STATEFLOW is used to show sliding mode controller demo  
% find feedback needed to achieve hyperbolic and unstable oscilating behaviour

clear, clc, close all % clear screen and memory
global ic Tfinal options ;
disp('wait for graphic window with menu and axis')

sysgenOscStab_;  % state space model of movement of platform mobile carying welding robot
 
    %% Modify object to have unstable oscilations   % wwosc=input('a+bi= '), 
    wwosc=5+10j 
    kOsc=acker(A,B,[wwosc  wwosc']);  kOsc1=kOsc(1);kOsc2=kOsc(2);
    Aosc=A-B*kOsc;     
    sysOsc=ss(Aosc,B,C,D); % see output   %step(sysOsc,1)

    %% Modify object to have unstable saddle point and hyperbolic trajectory 
    %disp('podaj   dwa a+/-bi   dla punktu siodlowego, np   9+0j,   -16+0j ')
    wwhip1=9;   wwhip2=-16; %input('a+bi= ')
    kHip=place(A,B,[wwhip1  wwhip2]),       kHip1=kHip(1); kHip2=kHip(2);
    Ahip=A-B*kHip
    sysHip=ss(Ahip,B,C,D);  % see output   %   step(sysHip,1)
    %figure,   initial(sysHip,[.1,.1]), 
    
txt='to STOP press right mouse button and than close the window';
ic=[0,0];%
disp('wait for graphic window with menu and axis')
%% Show simulink model and window used to draw unstable trajectories of platform 
slid_tst_       % 
phase00_        % draw graphic window 
disp('wait for graphic window with menu and axis It may take 5 minutes or more')
phaseH_   
disp('unstable hyperbolic trajectories (saddle) are drown in background')
pause(2)
phaseO_
disp('unstable oscilations are drown in background')
pause(2)
phaseSS_
disp('slant switching line is drown in background')
disp('sliding mode controller is ready')
disp('object state will move along unstable trajectory to swithing line')
disp('and then will slide near switching line to get quickly to [0,0] point')
pause(2)
phaseSLI_
hold off