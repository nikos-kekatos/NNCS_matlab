%===================================================

% Syntax:
%    >> run('main_tutorial.m') or main_tutorial or run(main_tutorial)
%
% Inputs:
%    i) Simulink model with nominal controller and plant, and
%   ii) Configuration file 
%
% Outputs:
%    i) Traces concatenated and saved as 'Data' structure. You can access
%    them via Data.ref, Data.U, Data.Y
%
% Example:
%
%
% Author:       Nikos Kekatos
% Written:      
% Last update:  ---
% Last revision:---

% ATTENTION:

% 1) The user should specify the variables/signals that they are interested
% in, via ref, u, y blocks (to workspace)

% 2) The user should disable the "single simulation output" option in the
% Simulink configuration. This is in Simulation/Model Settings/Data
% Import-Export.

%%------------- BEGIN CODE --------------

%% Add files to MATLAB path

% The user can either manually add the files e.g. right click on the roor
% directory and choose "add to path/Select folders and subfolder' or simply 
% run the following command.
% the startup script.

addpath(genpath("../../"))
% startup_fcn


%% Initialization

clear;close all;clc; 

% bdclose all; % close all Simulink models
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                   MODEL                       %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1: Specify the inputs (models, config)

% The models are saved in ./models/

SLX_model='tutorial_weicheng';
load_system(SLX_model)

% Uncomment next line if you want to open the model
% open(SLX_model)


% Specify config file
run('config_tutorial_weicheng.m')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%               TRACE GENERATION                %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2: Generate simulation data
%overwrite simulation choices
timer_trace_gen=tic; % clock for trace generation

options.plotting_sim=0;
options.save_sim=0;

% coverage approach
options.reference_type=1; 

[data,options]=trace_generation_nncs(SLX_model,options);
timer.trace_gen=toc(timer_trace_gen)
