This serves as a guide for the generation of cex-guided neural network 
controllers.

**Running Example**
The running example is a Mathworks case study. It is a closed-loop system
with a switched controller and a linear plant. The controller can switch
between three locations: (i) inactive, (ii) P controller, (iii) PID controller.
The plant is 1-D and is given by a transfer function. Note that the nominal 
closed loop is written in Simulink.

**Inputs**
1) A Simulink model which contains the closed-loop model with the nominal 
controller. Typically, the nominal plant and controller would be known, i.e.
modelled and designed by someone else. Our task would be to either implement
the model in Simulink or modify an existing Simulink model. In the tutorial, 
the model file is named as *tutorial_switched*.

2) The specification file which contains the temporal logic properties. The 
properties are defined as STL formulas, follow Breach syntax, and mainly
describe control objectives. The specification files is called *specs_tutorial.stl*.

In the tutorial, we define a stabilization property

phi_1:= alw_[0,sim_time]((abs(In1[t+dt]-In1[t])>d or [t]==0) => (ev_[0,17] alw_[0,3] (abs(y[t]-In1[t])<e)))

This property can be seen as a "reach and stay" specification where trajectories
enter the target set Z in finite time and
remain within Z thereafter.

3) A configuration file which contains various options for training, simulating,
analysis of the closed-loop. This is *config_tutorial.m*.

