 n=size(Time);

for i=1:n
    
    th1=PV_1(i);
    th2=PV_2(i);
    th3=PV_3(i);
    th4=PV_4(i);
    th5=PV_5(i);
    th6=PV_6(i);
    th7=PV_7(i);
    
    d1=0.36; d2=0.418; d3=0.4; d4=0.081; %arm architecture (m)

R1z=[cos(th1) -sin(th1) 0 0; sin(th1) cos(th1) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T1z=[1 0 0 0;0 1 0 0;0 0 1 d1;0 0 0 1]; %Translation in z axis
R1x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_0to1=R1z*T1z*R1x;
R2z=[cos(th2) -sin(th2) 0 0; sin(th2) cos(th2) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R2x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_1to2=R2z*R2x;
R3z=[cos(th3) -sin(th3) 0 0; sin(th3) cos(th3) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T3z=[1 0 0 0;0 1 0 0;0 0 1 d2;0 0 0 1]; %Translation in z axis
R3x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_2to3=R3z*T3z*R3x;
R4z=[cos(th4) -sin(th4) 0 0; sin(th4) cos(th4) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R4x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_3to4=R4z*R4x;
R5z=[cos(th5) -sin(th5) 0 0; sin(th5) cos(th5) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T5z=[1 0 0 0;0 1 0 0;0 0 1 d3;0 0 0 1]; %Translation in z axis
R5x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_4to5=R5z*T5z*R5x;
R6z=[cos(th6) -sin(th6) 0 0; sin(th6) cos(th6) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R6x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_5to6=R6z*R6x;
R7z=[cos(th7) -sin(th7) 0 0; sin(th7) cos(th7) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T7z=[1 0 0 0;0 1 0 0;0 0 1 d4;0 0 0 1]; %Translation in z axis
A_6to7=R7z*T7z;

%A_0to7=A_0to1*A_1to2*A_2to3+A_3to4*A_4to5*A_5to6*A_6to7;

%%Dynamic model Kuka LWR robotic arm

A_0to2=A_0to1*A_1to2;
A_0to3=A_0to2*A_2to3;
A_0to4=A_0to3*A_3to4;
A_0to5=A_0to4*A_4to5;
A_0to6=A_0to5*A_5to6;
A_0to7=A_0to6*A_6to7;
    



Xval(i)=A_0to7(1,4);
Yval(i)=A_0to7(2,4);
Zval(i)=A_0to7(3,4);

end

for i=1:n
    
    th1=SP_1(i);
    th2=SP_2(i);
    th3=SP_3(i);
    th4=SP_4(i);
    th5=SP_5(i);
    th6=SP_6(i);
    th7=SP_7(i);
    
R1z=[cos(th1) -sin(th1) 0 0; sin(th1) cos(th1) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T1z=[1 0 0 0;0 1 0 0;0 0 1 d1;0 0 0 1]; %Translation in z axis
R1x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_0to1=R1z*T1z*R1x;
R2z=[cos(th2) -sin(th2) 0 0; sin(th2) cos(th2) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R2x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_1to2=R2z*R2x;
R3z=[cos(th3) -sin(th3) 0 0; sin(th3) cos(th3) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T3z=[1 0 0 0;0 1 0 0;0 0 1 d2;0 0 0 1]; %Translation in z axis
R3x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_2to3=R3z*T3z*R3x;
R4z=[cos(th4) -sin(th4) 0 0; sin(th4) cos(th4) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R4x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_3to4=R4z*R4x;
R5z=[cos(th5) -sin(th5) 0 0; sin(th5) cos(th5) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T5z=[1 0 0 0;0 1 0 0;0 0 1 d3;0 0 0 1]; %Translation in z axis
R5x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_4to5=R5z*T5z*R5x;
R6z=[cos(th6) -sin(th6) 0 0; sin(th6) cos(th6) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R6x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_5to6=R6z*R6x;
R7z=[cos(th7) -sin(th7) 0 0; sin(th7) cos(th7) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T7z=[1 0 0 0;0 1 0 0;0 0 1 d4;0 0 0 1]; %Translation in z axis
A_6to7=R7z*T7z;

%A_0to7=A_0to1*A_1to2*A_2to3+A_3to4*A_4to5*A_5to6*A_6to7;

%%Dynamic model Kuka LWR robotic arm

A_0to2=A_0to1*A_1to2;
A_0to3=A_0to2*A_2to3;
A_0to4=A_0to3*A_3to4;
A_0to5=A_0to4*A_4to5;
A_0to6=A_0to5*A_5to6;
A_0to7=A_0to6*A_6to7;
   

X(i)=A_0to7(1,4);
Y(i)=A_0to7(2,4);
Z(i)=A_0to7(3,4);

end

figure(15)
plot(Time,X,Time,Xval);
title('Position X axis SP-PV');
xlabel('Time (s)');
ylabel('Position (m)');
legend('SP','PV','Location','southeast');
figure(16)
plot(Time,Y,Time,Yval);
title('Position Y axis SP-PV');
xlabel('Time (s)');
ylabel('Position (m)');
legend('SP','PV','Location','southeast');
figure(17)
plot(Time,Z,Time,Zval);
title('Position Z axis SP-PV');
xlabel('Time (s)');
ylabel('Position (m)');
legend('SP','PV','Location','southeast');
figure(18);
plot3(X,Y,Z);
title('End-effector trajectory'); title('End-effector trajectory');
xlabel('Position (m)');
ylabel('Position (m)');
zlabel('Position (m)');

Xerr=X-Xval;
Yerr=Y-Yval;
Zerr=Z-Zval;

figure(19)
plot(Time,Xerr);
title('Error X axis');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Error','Location','southeast');
figure(20)
plot(Time,Yerr);
title('Error Y axis');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Error','Location','southeast');
figure(21)
plot(Time,Zerr);
title('Error Z axis');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Error','Location','southeast');

for i=1:n
Q=Xerr(i)^2+Yerr(i)^2+Zerr(i)^2;    
E(i)=nthroot(Q,3); 
end

figure(22)
plot(Time,E);
title('Absolute error');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Error','Location','southeast')