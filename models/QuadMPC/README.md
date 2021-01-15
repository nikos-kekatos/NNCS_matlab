Quadorotor model with MPC Controller
---

This folder contains our efforts towards replacing an MPC controller by an NN. The original model is designed by [Mathworks](https://www.mathworks.com/help/mpc/ug/control-of-quadrotor-using-nonlinear-model-predictive-control.html).

#### Introduction
According to the description, 
"this example shows how to design a nonlinear model predictive controller for trajectory tracking of a quadrotor. The dynamics and Jacobians of the quadrotor are derived using `Symbolic Math Toolbox` software. The quadrotor tracks the reference trajectory closely."

Note that the `getQuadrotorDynamicsAndJacobian` script generates the following files:

1. QuadrotorStateFcn.m — State function

2. QuadrotorStateJacobianFcn.m — State Jacobian function

####Status

>Goal: Convert this model into an equivalent Simulink model

That means that the plant, controller and reference previewing have to be replaced by equivalent Simulink blocks. The *plant* is defined as an ODE function. In order to use the existing function inside Simulink, we used the Interpreted Matlab function following this [link](https://www.youtube.com/watch?v=QKhy1JsdiUo). The MPC was replaced by the NMPC block and the references by simple input "source signals". The interconnections were added accordingly.

Remark: the Simulink and the Matlab control systems are not matching each other.

####Files

1. `config_quad_mpc`: runs the original MPC in Matlab and plots the trajectories
2. `quad_mpc.slx` : attempt to build the nominal control in Simulink
3. `QuadrotorFcn.m`: modified function to define the *plant* for Simulink

###Testing

Run the `quad_mpc.slx` model in Simulink and inspect the scopes. The reference (x, y,z) and the actual values of x, y, z states are not matching. Especially, for sinusoidal-like references the mismatch is large.