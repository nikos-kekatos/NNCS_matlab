function [ref,y,u] = sim_SLX(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.
options.workspace = simset('SrcWorkspace','current');
sim(model,[],options.workspace);
end

