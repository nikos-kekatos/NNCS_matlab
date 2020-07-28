%% Small Script for simulating and plotting NN with memory.

% Usage: (i) run by section, or (ii) run entire file

%% initialization (comment if not needed)

clear;clc;close all;

%% loading the NN in memory (saved as an object/structure)

load('net_for_hadi_memory.mat')
 
view(net)

%% selection of points for simulating the NN

% point selection 
m=10000; 

% input 1 is constant
p1=0.5*ones(1,m);
% input 2 is inside [-0.2,0.2]
p2=0.4*rand(1,m)-0.2;
% input 3 is inside [-4,4]
p3=8*rand(1,m)-4;

% you can replace the values and the ranges, e.g. p3=1*rand(1,m)-0.5;
% p3=20*rand(1,m)-10;

% Out(k)=NN(in1(k),in1(k-1),in1(k-2),in1(k-3),in2(k),in3(k),in2(k-1),in3(k-1),in2(k-2),in3(k-2),in2(k-3),in3(k-3))

% replace by zeros the missing samples for p2 and p3. p1 is constant all
% the time.

        p_all_1=[p1;[0,p1(1:(end-1))];[0,0,p1(1:(end-2))];[0,0,0,p1(1:(end-3))]];
%         p_all_1=[p1;p1;p1;p1];
        p_all_2=[p2;p3];
        p_all_3=[[0,p2(1:(end-1))];[0,p3(1:(end-1))]];
        p_all_4=[[0,0,p2(1:(end-2))];[0,0,p3(1:(end-2))]];
        p_all_5=[[0,0,0,p3(1:(end-3))];[0,0,0,p3(1:(end-3))]];

p_all=[p_all_1;p_all_2;p_all_3;p_all_4;p_all_5];

%%

y_out=sim(net,p_all)

%% plotting in 3D

figure;
plot3(p2,p3,y_out,'x')
% plotting in 3D
