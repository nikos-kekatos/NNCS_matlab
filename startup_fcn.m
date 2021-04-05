function  startup_fcn
%STARTUP_FCN Summary of this function goes here
%   Detailed explanation goes here
current_file = matlab.desktop.editor.getActiveFilename;
current_path=fileparts(current_file);
% current_file=which('main_nncs_combination.m');
% current_path=fileparts(current_file);
idcs   = strfind(current_path,filesep);
module_dir = current_path(1:idcs(end)-1); % 2 steps back
cd(current_path);
addpath(genpath(module_dir));
%rmpath(genpath([module_dir filesep 'NIPS_submission']));
end

