%% Small Script for simulating and plotting NN with linear operating ranges.

% Usage: (i) run by section, or (ii) run entire file

%% initialization (comment if not needed)

clear;clc;close all;

%% loading the NN in memory (saved as an object/structure)

load('nets_for_hadi.mat')
 
view(net_hadi_1_layer) % 1 layer
view(net_hadi_2_layers) % 2 layers

%% selection of points for simulating the NN

% point selection 
m=10000; 

% input 1 is constant
p1=0.5*ones(1,m);
% input 2 is inside [-0.2,0.2]
p2=0.4*rand(1,m)-0.2;
% input 3 is inside [-5,5]
p3=8*rand(1,m)-4;

% you can replace the values and the ranges, e.g. p3=1*rand(1,m)-0.5;
% p3=20*rand(1,m)-10;

p_all=[p1;p2;p3];

%%

y_out_1_layer=sim(net_hadi_1_layer,p_all)
y_out_2_layer=sim(net_hadi_2_layers,p_all)

%% plotting in 3D

figure;
plot3(p2,p3,y_out_1_layer,'x')
title('2 layers')
% plotting in 3D

figure;
plot3(p2,p3,y_out_2_layer,'x')
title('1 layer')
