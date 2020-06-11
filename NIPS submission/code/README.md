# Counter-Example Guided Training of Neural Network Controllers

This folder contains the implementation of the paper *Counter-Example Guided Training of Neural Network Controllers* with a paper ID *9059* which has been submitted to *NeurIPS 2020*. 

Insutructions on how to install, run and obtain the experimental results reported in the submission are provided.


- [Context](#Context)
- [Requirements](#Requirements)
- [Installation](#Installation)
- [Files](#Files)
- [Usage](#Usage)
- [Remarks](#Remarks)
- [Reproducability](#Reproducability)


## Context <a name="Context"></a>
In this work, we propose an approach to design neural network controllers which satisfy given specifications, formally defined as Signal Temporal Logic (STL) properties. We make use of coverage, counterexamples and clustering. The fundamental inputs to our algorithm are 1) a closed-loop system, defined as a Simulink model, 2) a set of STL properties written as a text file (saved with an .stl ending), and 3) configuration parameters, which involve training options, trace generation options, resolutions, error metrics, falsification options, etc. The steps that are undertaken involve trace generation, NN training based on a matching error, new closed-loop system construction in Simulink, testing (e.g. data matching in closed loop), falsification, counterexample generation and selection, clustering via k-means (using the Silhouette evaluation), retraining and retesting, e.g. to verify the counterexample elimination. Our code is entirely written in MATLAB&trade;. We use Simulink&reg; for the closed-loop system modeling and for testing. We use the *proprietary* Deep Learning toolbox for neural network training and an *open-source* falsification tool named [Breach](https://github.com/decyphir/breach).

## Requirements <a name="Requirements"></a>

Running the accompanied files requires the installation of MATLAB&trade; in your machine. The [Simulink toolbox](https://www.mathworks.com/products/simulink.html) and the [Deep Learning toolbox](https://www.mathworks.com/products/deep-learning.html) should also be installed. No other toolboxes or add-ons are required.

> Note that there seems to be a dependency on the [Image Processing Toolbox](https://www.mathworks.com/products/image.html). In fact, we only use one function, i.e. [`mink`](https://www.mathworks.com/help/matlab/ref/mink.html) and we provide an alternative code which is activated via `try` and `catch` statements. 

We use the latest [Breach](https://github.com/decyphir/breach) version (1.7.0). For simplicity, we have downloaded and included the corresponding Breach code in the zip folder. Note that a C/C++ compiler is required to use Breach and the interfacing is done via MEX files (more information on Installation). 

## Installation <a name="Installation"></a>

1. The user has to check that Breach is correctly setup. This requires two main steps, 
 
	* installing a C/C++ compiler via `$ mex -setup`. Information about different operating systems can be found [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html).
	* Installing Breach via the function `InstallBreach`. You should navigate to the `breach` folder and run `$ InstallBreach` in the MATLAB command window. Note that this should be done only once and the Breach path and files will be automatically added to the search path.
	
	<!--
	 Adding the Breach folder to the MATLAB path. This can be done (i) manually by right-clicking on the root folder of the Breach folder and opting `Add to Path` and `Selected Folders and Subfolders`, (ii) write in the command window `$ addpath(genpath(breach_tool))`, (iii) run `$ InstallBreach` (it will perform other actions as well)
	 -->

	> You might get warnings during the installation, e.g. due to different GCC versions or receive the message that `Install mostly successful`. This is acceptable as most features of Breach will work nonetheless.

2. Everything else will be automatically handled for each experiment.

## Files <a name="Files"></a>

In the `code` folder, there exist three subfolders:

1. `breach`: contains all the code for ***Breach*** toolbox
2. `src_code`: contains our code for the synthesis of neural network control systems and is divided into the `core` and the `utilities` subfolders. Here, you can find all the code regarding training, retraining, falsification, etc.
3. `experiments`: contains 7 subfolders with all the experimental results. There is a correspondence between the name of each folder and the name ID of the reported results of the submitted paper (Table 1, page 7).  Each folder contains 
	* a Simulink model (model\_<*ModelName*>\_<*ID*>.slx) with the nominal closed-loop system, one closed-loop system which will be filled with the neural network (without counterexamples) and one closed-loop system which will be filled with the neural network (after eliminating the counterexamples) 
	* a configuration file (config\_<*ModelName*>\_<*ID*>.m) which specifies the options for the trace generation among other things
	* a text file (specs\_<*ModelName*>\_<*ID*>.stl) which defines the formal specifications that the closed-loop system should satisfy in the form of STL properties
	* a 'main' file (main\_<*ModelName*>\_<*ID*>.m) which runs the entire algorithm for each experiment.
	* a Simulink model (model\_<*ModelName*>\_<*ID*>\_pretrained.slx) with pretrained neural network controller which could directly be simulated.

> The \<ModelName\> might be *robot-arm* or *water-tank*. The \<IDs\> for the robot-arm are $A_{1,1}$, $A_{1,2}$, $A_{2}$ and for the water-tank are $W_{1,1}$, $W_{1,2}$, $W_{1,3}$, and $W_2$.
 
## Usage <a name="Usage"></a>

To run each experiment, you simply need to navigate to the `experiments` directory and choose the corresponding folder. Then, you should open the `main.m` file and run it. You can run it by writing its name in the command window, i.e. `$ main` or use the `Run` button on the top of the MATLAB interface (it is located on the `Editor` tab).  The code will return several figures, display the results, and store in a TXT file (`output_modelName_experiment.txt`) the key results.

## Remarks <a name="Remarks"></a>

Please note that there is a typo (error) in the Table 1 regarding the experiment A<sub>1,2</sub>. In the last row with ID=3, the $n_c$ should be equal to 0 and not equal to 20. 

## Reproducability - Disclaimer <a name="Reproducability"></a>

Running the experiments might lead to results that do not exactly replicate the reported results in the paper. That is the case as there are several random factors in our code. In particular, 1) the trace generation uses a random seed, 2) the training is not deterministic, the initial weights are randomly chosen accroding to the [Nguyen-Widrow initialization method](https://fr.mathworks.com/help/deeplearning/ref/init.html) and the [splitting of the data](https://fr.mathworks.com/help/deeplearning/ref/dividerand.html) into training, testing and validation data is again done randomly via the `nntraintool` functionalites, 3) the falsification techniques use random, quasi random and optimization based search algorithms with randomly chosen seeds, 4) the clustering is non deterministic due to the nature of the `k-means` algorithm and the use of 'replicates' might not resolve this matter, and 5) retraining also involves random splitting of the data. However, despite the randomness introduced the generated results still qualitatively match the reported results and most importantly the counterexample elimination is succesful.
