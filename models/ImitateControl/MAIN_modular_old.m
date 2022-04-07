%% INITIALIZATION
addpath(genpath('../../'))
clear;clc;close all;
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach/')) %modified
InitBreach;

%% MODELING (plant + control)

run('nlmpc_modeling.m')

%% Evaluate STL nominal control

no_attempts=2000; % 1 traces, 1 sec. Tested 2000 traces.

% run('evaluate_nominal_stl.m')

%% DATA GENERATION (not traces but 1-step computations)

% CHOOSE Input methods
% 1: Pre-generated Data (mathworks),
% 2: generation with random inputs (Mathworks)
% 3: corner cases as an input (Mathworks script),
% 4: coverage (our code -- Inzemam)

input_choice=4;

switch input_choice
    case 1
        DAggerData = load('DAggerInputDataFileImFlyingRobot.mat'); 
        data = DAggerData.data;
        existingData = data;
        numCol = size(data, 2);
    case 2
        no_points=1e5;
        data=random_points_generation(no_points);
    case 3
        data=corner_case_generation;
    case 4
%         ref_min=[-4;-4;-3.2;-2;-2;-1; -umax; -umax];
%         ref_max=[4;4;3.2;2;2;1; umax; umax];
        delta_resolution=[4;4;3;2;2;2;2;2];

        %         delta_resolution=[0.25;0.72;0.25;0.2;0.26;0.15];
        if exist('delta_resolution','var')
            data=coverage_generation(delta_resolution);
        else
            data=coverage_generation();
        end

end

%% DATA SPLITTING
% divide into training, testing data

run('data_splitting.m')

%% GENERATE NEURAL NETWORK

% this code uses the "new" training tool from mathworks.
run('create_neural_network.m')