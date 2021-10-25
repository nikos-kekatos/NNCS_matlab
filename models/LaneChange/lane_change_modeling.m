% Design an MPC controller for lane keeping assist. To do so, first create a dynamic model for the vehicle.

global sys Vx mpcobj initialState

[sys,Vx] = createModelForMPCImLKA;
% Create and design the MPC controller object mpcobj. Also, create an mpcstate object for setting the initial controller state. For details on the controller design, type edit createMPCobjImLKA.
[mpcobj,initialState] = createMPCobjImLKA(sys);
% For more information on designing model predictive controllers for lane keeping assist applications, see Lane Keeping Assist System Using Model Predictive Control and Lane Keeping Assist with Lane Detection.
