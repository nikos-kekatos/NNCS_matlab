Approximating nominal feedback controllers by neural networks
===
In this work, we intend to mimic the behavior of a nominal controller by a feedforward Neural Network. The nominal controller might be an individual controller or a set of multiple controllers.

Download
----

The files can be downloaded via *ssh/https* or as a *zip* file. 

To clone the repository, (i) open your terminal, (ii) navigate to your desired directory, and (iii) write:
``git clone git@github.com:nikos-kekatos/NNCS_matlab.git``

To test the latest updates, you can only download the ``nikos_comb`` branch.
``git clone -b nikos_comb --single-branch git@github.com:nikos-kekatos/NNCS_matlab.git``


Requirements 
----
 
>**Necessary**

- MATLAB
- Simulink (all models are designed in Simulink)
- [Deep Learning toolbox](https://www.mathworks.com/products/deep-learning.html) (for constructing and storing the neural networks).

>**Falsification/Breach**

- Symbolic Matlab Toolbox
- Global Optimization Toolbox
- Optimization Toolbox
- Parallel Computing Toolbox (optional)

>**Models**

- Control System Toolbox (models with PID control)
- Simulink Control Design Toolbox (mode with gain-scheduling)
- Image processing Toolbox (optional, previous dependency was avoided)
- Model Predictive Control toolbox (models with MPC control) 
- Fuzzy Logic Toolbox (model with fuzzy inference rules & look-up table)
- Symbolic Matlab Toolbox (QuadMPC)

Dependencies
----

Apart from the MATLAB toolboxes, we use the [Breach](https://github.com/decyphir/breach) toolbox. Breach is a Matlab tool for  simulation-based design of dynamical/CPS/Hybrid systems. According to the guidelines, 

- Download Breach files
- Setup a C/C++ compiler using mex -setup
- add path to Breach folder
- Run InstallBreach

Installation
----
No special installation is required. The user has to add `Breach` and this repo (default name: `NNCS_matlab`) to the path. This can be done by right-clicking on the root directory and selecting `Add to Path >> Select Folder and SubFolder`. For Breach, the use has to run in the command window of MATLAB`>> InitBreach`.

Branches
----

There are several branches but they are not all property maintained. 
The **`nikos_comb`** contains the latest version of the code and this is the branch that should be used.
The `master` contains the stable version of the code.
The `Akshay` branch was used to check the code in a Windows machine.
The `nikosk` branch initially contained the ode without Breach falsification but only with coverage. The `falsif_breach` contained the initial integration of Breach without the iterative process.
The `nikos_dev` contained the full procedure for a single nominal controllers.

Usage
----
Once the user has added the corresponding files to the MATLAB path and has initialized Breach, they are ready to run different models. For each model, there is a corresponding `main` file. 

> Well-functioning models

- The user can navigate to the `src` and run 
`main_nncs.m`. There we can choose between models 1, 2, 3 corresponding to instances of the watertank, robotarm, quadcopter (linear controls) models.
- The `main_nncs_combination.m` corresponds to the model where we combine two controllers based on robustness or a user-defined cost function. Choose `options.combination_matlab=2` to use robustness and `options.combination_matlab=1` for LQR-like costs.
- Navigate to `models/Stateflow_Switched` and run `main_switched.m`.
- Navigate to `models/tank_reactor` and run `main_tank_reactor.m`.
- Navigate to `models/LookupTable` and run `main_lookup_table.m`.
- Navigate to `models/Switching_tf_hespanha` and run `main_hespanha.m`.
- Navigate to `models/PID Control/PID Control` and run `main_engine.m`.
- Navigate to `models/MatlabQuadSimAP-master` and run `main_quad_ardu.m`.

> Model Inputs

- One Simulink model (.slx) which contains the closed loop system (containing the plant and the nominal controller)
- One configuration file (config_...) which contains the configurations, ranges, conditions, coverage metrics, Simulink options, etc.
- One main file (main...) which performs the entire process.
- At least one requirement file (specs_) which contains the STL formula illustrating the closed-loop system properties/objectives.

Note that each model might contain additional files or there might be small differences.

> Procedure

- Initialization
- Running/Loading the configurations.
- **Trace Generation** using coverage, simulations, or Breach falsification/simulation.
- Selection of Data, Neural Network structure and parametrization, Preprocessing, Trimming.
- **Neural Network Training**
- Open loop testing and Simulink block generation
- **Matchin error test** against STL properties.
- Falsification/retraining Loop 
	- Falsification with quasi random samples-- **Generalization Test**
	- If no cex, falsification with optimization-based techniques.
	- If cex, 
		- **Clustering** to evaluate the significance of the generated CEX. 		
		- Choose retraining options, method, etc.
		- **Retrain** using old (from trace generation or previous loop iterations) and new (cex) data.
		- Check CEX elimination
		- Plotting, additional tests, etc.

		
More information regarding the code structure will be added. There are several options, features in the code which might be unclear in the beginning. 

