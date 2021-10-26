1. Initialization
   ----------------------
   cleaning the workspace and command window
   adding required folders to the path
   initializing breach (update the path accordingly in the code)

2. Design MPC Controller
   ---------------------
   copied code from Mathworks to create a plant and controller object
   >>run('lane_change_modeling.m')

3. Data Generation
   ------------------
   4 ways to get the data from MPC controller
    i.   directly using Mathworks data which is already available in the file InputDataFileImLKA.mat
    ii.  generate data points randomly using Mathworks code
    iii. use corners of the grid using Mathworks code
    iv.  use coverage - our code
    
   'input_choice' variable can be used to select the choice

4. Data splitting
   --------------
   Dividing data in training and testing data.
   Copied the code from Mathworks
   >>run('data_splitting.m')
 
5. Generate Neural Network
   -----------------------
   Creation and first iteration of training of neural network.
   Code from Mathworks
   Currently using 3 layers, 45 neurons each
   >>run('create_neural_network.m')

6. Closed-Loop Analysis
   --------------------
   comparing the MPC and NN on a trace generated from random initial parameters.
   Comparison is visual comparison.
   plot the state and output for both MPC and NN.
   code copied from Mathworks
   >>run('closed_loop_analysis.m')

7. Falsification-Retraining Loop
   -----------------------------
   This part contains the STL property (DNN & MPC), the falsification with random inputs via property 	
   evaluation, the retraining and the rechecking to evaluate if the CEX are eliminated
    
    Options provided to the user:
    i. Retraining choice (captured by the variable 'choice_retrain')
           After falsification, retraining has to be done only on a single point or the whole trace
           if a single point has to be used for retraining, then choice_retrain = 2
           if the whole trace has to be used for retraining, then choice_retrain = 1
    ii. Max No. of iterations of retraining (captured by 'falsif.iterations_max')
    iii. No. of random traces to be used for one iteration of falsification (captured by 	'falsif.no_iterations')
    iv. Choose if the CEX will be plotted (captured by choice_plot_cex): true or  false
     v. The STL property defined as a BreachRequirement,         
	r_dnn = BreachRequirement('alw_[2,3](x_dnn[t]>-0.5 and x_dnn[t]<0.5 and v_dnn[t]>-0.6 and
					v_dnn[t]<0.6)');