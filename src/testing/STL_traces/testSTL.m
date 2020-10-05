clear 
addpath(genpath('/Users/kekatos/Files/Projects/Github/breach'))
addpath(genpath('/Users/kekatos/Files/Projects/Gitlab/Matlab_Python_Interfacing/NNCS_matlab/modules'))

InitBreach
all=load('data_STLevalThom.mat');

STL_property_file='specs_watertank_comb_ctrl_1.stl';
STL_ReadFile(STL_property_file)
clear phi_6 phi_7 phi_5_nom STL_property_file taus

% for i_pt=1:ipts  
% [props_values(i_pt).val, props_values(i_pt).tau] = STL_Eval(Sys, phi, Ptmp, traj_tmp, taus{np}, method);
% ende
% [props_values.val, props_values.tau] = STL_Eval(Sys, phi, Ptmp, traj_tmp, taus{np}, method);
Sys2.DimX=all.Sys.DimX;
% Sys2.DimU=all.Sys.DimU;
Sys2.DimP=all.Sys.DimP;
Sys2.ParamList=all.Sys.ParamList;

try
    P2=all.Ptmp;
catch
    P2=all.P;
end

traj2=P2.traj;
traj3=rmfield(traj2{1},{'status','param'})
P2.pts=zeros(length(P2.ParamList),1)
P2.pts=all.P.pts
% taus={[0]};
% method='thom';

% [rob.val, rob_values.tau] = STL_Eval(Sys2, phi, P2, traj2, 0, 'thom');
try
    phi_test=phi
catch
    phi_test=phi_5
end
P2=rmfield(P2,{'Xf','epsi','dim','DimP','DimX','traj_to_compute','selected','traj_ref','traj','props','props_names'});
%%

[val, tau] = STL_EvalThom(Sys2, phi_test, P2, traj3, 0)

%P.pts
% P.paramlist