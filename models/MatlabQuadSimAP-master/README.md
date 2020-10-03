Quadrotor Model based on ArduPilot 
---

The MATLAB files were taken from Wilseby [GitHub repo](https://github.com/wilselby/MatlabQuadSimAP). It is used for simulating a 3DRobotics ArduPilot based quadrotor.

#### Files
---------

This folder contains several Simulink models. The [`utilities`](https://github.com/nikos-kekatos/NNCS_matlab/tree/nikos_comb/models/MatlabQuadSimAP-master/utilities) contains various function provided by the author; only the [`quad_variables.m`](https://github.com/nikos-kekatos/NNCS_matlab/blob/nikos_comb/models/MatlabQuadSimAP-master/utilities/quad_variables.m). 

The model is numerically unstable and it can be observed by changing the desired values for example `x_des=1`. Our first goal has been to find a range that the model can be simulated without errors. This is done via exhaustive testing. The code for identifying and testing these ranges is  the 

