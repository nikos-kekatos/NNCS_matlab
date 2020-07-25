function [ref,y,u] = sim_SLX(model,options)
% sim_SLX simulate once the Simulink model
%   This is to resolve problems with references between base and local
%   workspaces.
if options.model==4
    load  PIDGainSchedExample
elseif options.model==5
    run('quad_variables.m')
elseif options.model==7
    Kp=0.0055;
    Ki=0.0131;
    Kd=3.3894e-004;
    N=9.9135;
end
options.workspace = simset('SrcWorkspace','current');
sim(model,[],options.workspace);
end

