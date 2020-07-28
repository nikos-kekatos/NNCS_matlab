%%Rigid body tree model
%%Denavit-Hatenberg Parameters
% i  thi  di  ai    alphai
% 1  th1  d1   0     -pi/2  
% 2  th2  0   0     pi/2 
% 3  th3  d2  0     pi/2
% 4  th4  0   0     -pi/2
% 5  th5  d3  0     -pi/2
% 6  th6  0   0     pi/2
% 7  th7  d4   0     0

%Rigig body tree definition

robot = robotics.RigidBodyTree("MaxNumBodies",8,"DataFormat","row");

body0 = robotics.RigidBody('body0');
jnt0 = robotics.Joint('jnt0','fixed');
body1 = robotics.RigidBody('body1');
jnt1 = robotics.Joint('jnt1','revolute');
body2 = robotics.RigidBody('body2');
jnt2 = robotics.Joint('jnt2','revolute');
body3 = robotics.RigidBody('body3');
jnt3 = robotics.Joint('jnt3','revolute');
body4 = robotics.RigidBody('body4');
jnt4 = robotics.Joint('jnt4','revolute');
body5 = robotics.RigidBody('body5');
jnt5 = robotics.Joint('jnt5','revolute');
body6 = robotics.RigidBody('body6');
jnt6 = robotics.Joint('jnt6','revolute');
body7 = robotics.RigidBody('body7');
jnt7 = robotics.Joint('jnt7','revolute');

%Joint limits definition

jnt1.PositionLimits=[-170*((2*pi)/360) 170*((2*pi)/360)];
jnt2.PositionLimits=[-120*((2*pi)/360) 120*((2*pi)/360)];
jnt3.PositionLimits=[-170*((2*pi)/360) 170*((2*pi)/360)];
jnt4.PositionLimits=[-120*((2*pi)/360) 120*((2*pi)/360)];
jnt5.PositionLimits=[-170*((2*pi)/360) 170*((2*pi)/360)];
jnt6.PositionLimits=[-120*((2*pi)/360) 120*((2*pi)/360)];
jnt7.PositionLimits=[-175*((2*pi)/360) 175*((2*pi)/360)];

%Frames transformations

setFixedTransform(jnt1,[1 0 0 0; 0 1 0 0; 0 0 1 0.1575; 0 0 0 1]);
setFixedTransform(jnt2,[-1 0 0 0;0 0 1 0;0 1 0 0.2025;0 0 0 1]);
setFixedTransform(jnt3,[-1 0 0 0; 0 0 1 0.2045;0 1 0 0;0 0 0 1]);
setFixedTransform(jnt4,[1 0 0 0; 0 0 -1 0; 0 1 0 0.2155; 0 0 0 1]);
setFixedTransform(jnt5,[-1 0 0 0; 0 0 1 0.1845; 0 1 0 0;0 0 0 1]);
setFixedTransform(jnt6,[1 0 0 0; 0 0 -1 0; 0 1 0 0.2155; 0 0 0 1]);
setFixedTransform(jnt7,[-1 0 0 0; 0 0 1 0.081;0 1 0 0;0 0 0 1]);

body0.Joint = jnt0;
body1.Joint = jnt1;
body2.Joint = jnt2;
body3.Joint = jnt3;
body4.Joint = jnt4;
body5.Joint = jnt5;
body6.Joint = jnt6;
body7.Joint = jnt7;

%Links mass specifications

body0.Mass = 5;
body0.CenterOfMass = [-0.1000 0 0.0700];
body0.Inertia = [0.0745 0.1345 0.0800 0 0.0350 0];

body1.Mass = 3.4525;
body1.CenterOfMass = [0 -0.03 0.12];
body1.Inertia = [0.0747 0.0574 0.0239 0.0085 0 0];

body2.Mass = 3.4821;
body2.CenterOfMass = [3.0000e-04 0.0590 0.0420];
body2.Inertia = [0.0390 0.0279 0.0199 -0.0086 -0.0037 -6.1633e-05];

body3.Mass = 4.0562;
body3.CenterOfMass = [0 0.0300 0.1300];
body3.Inertia = [0.1042 0.0783 0.0341 -0.0096 0 0];

body4.Mass = 3.4822;
body4.CenterOfMass = [0 0.0670 0.0340];
body4.Inertia = [0.0414 0.0248 0.0234 -0.0116 0 0];

body5.Mass = 2.1633;
body5.CenterOfMass = [1.0000e-04 0.0210 0.0760];
body5.Inertia = [0.0263 0.0182 0.0121 -0.0074 -1.6441e-05 -4.5429e-06];

body6.Mass = 2.3466;
body6.CenterOfMass = [0 6.0000e-04 4.0000e-04];
body6.Inertia = [0.0065 0.0063 0.0045 3.1835e-04 0 0];

body7.Mass = 0.31290;
body7.CenterOfMass = [0 0 0.0200];
body7.Inertia = [0.0159 0.0159 0.0029 0 0 5.9120e-04];

%Total mass

Mass=body0.Mass+body1.Mass+body2.Mass+body3.Mass+body4.Mass+body5.Mass+body6.Mass+body7.Mass;

%Robot arm construction

addBody(robot,body0,'base')
addBody(robot,body1,'body0');
addBody(robot,body2,'body1')
addBody(robot,body3,'body2')
addBody(robot,body4,'body3')
addBody(robot,body5,'body4')
addBody(robot,body6,'body5')
addBody(robot,body7,'body6')
robot.Gravity = [0 0 -9.81];

%useful commands

%randConfig=robot.randomConfiguration;
%showdetails(robot);
%show(robot,randConfig);
show(robot);
axis([-1,1.5,-1,1.5,0,1.5])
%axis off
%initialguess = robot.homeConfiguration;
%randConfig = robot.randomConfiguration;
%tform = getTransform(robot,randConfig,'body7','base');

%ik = robotics.InverseKinematics('RigidBodyTree',robot);
%weights = [0.25 0.25 0.25 1 1 1];
%initialguess = robot.homeConfiguration;
%[configSoln,solnInfo] = ik('body7',tform,weights,initialguess)