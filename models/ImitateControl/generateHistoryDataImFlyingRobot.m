function histInfoStruct = generateHistoryDataImFlyingRobot(imitateMPCNetObj, nlmpcStruct, existingData)
% Generates state and control histories for the flying robot with both
% nonlinear MPC and DNN.
% 
% Copyright 2019 The MathWorks, Inc.

% Assign DAgger network object.
DNN = imitateMPCNetObj;

% Assign nlmpc variables.
Tf = nlmpcStruct.Tf;
bx = nlmpcStruct.bx;
bu = nlmpcStruct.bu;
nlobj = nlmpcStruct.nlobj;

% Generate new data
x0 = getRandomInputImFlyingRobot(bx,existingData);
u0 = getRandomInputImFlyingRobot(bu,existingData);    

% Capture the xHistoryMPC, uHistoryMPC, xHistoryDNN, uHistoryDNN into a
% structure.
[histInfoStruct.xHistoryMPC, histInfoStruct.uHistoryMPC] = simModelMPCImFlyingRobot(x0,u0,nlobj,Tf);
[histInfoStruct.xHistoryDNN, histInfoStruct.uHistoryDNN] = simModelDAggerImFlyingRobot(x0,u0,DNN,nlobj.Ts,Tf);
histInfoStruct.u0HistoryDNN = [u0'; histInfoStruct.uHistoryDNN];

end
