%% This file is to add the files/repository to MATLAB path
% It has to be run every time you open/start MATLAB.

addpath(genpath(pwd))
% main_dir=pwd;
user_name=char(java.lang.System.getProperty('user.name'));
if strcmp(user_name,'kekatos')
    addpath(genpath('/Users/kekatos/Files/Projects/Github/breach'))
elseif strcmp(user_name,'haque')
    addpath(genpath('C:\Users\haque\Documents\repos\breach\'))
else
    disp('Add your path using addpath and genpath')
end
fprintf('\nInitializing Breach and adding it to MATLAB path.\n')
InitBreach;