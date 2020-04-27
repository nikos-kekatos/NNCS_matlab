% open f14
open_system('f14');

% create a new model
newbd = new_system('test_slx_new');
open_system(newbd);

% copy the subsystem
Simulink.SubSystem.copyContentsToBlockDiagram('f14/Controller', newbd);

% close f14 and the new model
close_system('f14', 0);
close_system(newbd, 1);


%%
open_system('vdp');
new_system('new_model_with_vdp')
open_system('new_model_with_vdp');
add_block('built-in/Subsystem', 'new_model_with_vdp/vdp_subsystem')
Simulink.BlockDiagram.copyContentsToSubsystem...
('vdp', 'new_model_with_vdp/vdp_subsystem')
close_system('new_model_with_vdp',1)
%%
mdl_gensim='example_gensim';
new_mdl='quad_test_auto';
open_system(mdl_gensim)
open_system('new_model_with_vdp')
disp('Using find_system')
find_system(mdl_gensim)
disp('Using get_param')
get_param(mdl_gensim);
open_bd = find_system(mdl_gensim,'type','block')
fcnblockhandle = getSimulinkBlockHandle(strcat(mdl_gensim,'/Feed-Forward Neural Network'),true);

new_system('new_test_model')
open_system('new_test_model')
add_block('example_gensim/Feed-Forward Neural Network','new_test_model/asd')
close_system('new_test_model',1)

new_mdl='quad_test_auto';
open_system(new_mdl)
add_block('example_gensim/Feed-Forward Neural Network',strcat(new_mdl,'/FFNN'))
close_system(new_mdl,1);
open_system(new_mdl);
replace_block(new_mdl,'quad_test_auto/nn_4','Integrator')
open_system('f14')

Simulink.SubSystem.copyContentsToBlockDiagram('f14/Controller', 'new_test_model');

%%
% Simulink.SubSystem.deleteContents('new_test_model/asd')
close_system('new_test_model',0)
close_system('quad_test_auto',0)
load_system('new_test_model')
load_system('quad_test_auto')
Simulink.BlockDiagram.deleteContents('new_test_model')

% replace_block('new_test_model','asd','Integrator')
Simulink.SubSystem.deleteContents('quad_test_auto/nn_4')
open_system('quad_test_auto')

%%
Simulink.SubSystem.copyContentsToBlockDiagram('example_gensim/Feed-Forward Neural Network','new_test_model')
Simulink.BlockDiagram.copyContentsToSubsystem...
('new_test_model', 'quad_test_auto/nn_4')
% close_system('new_test_model',0)
pc=get_param('quad_test_auto/nn_4','portconnectivity')
[pos_in,pos_out]=pc.Position;
%%
add_line('quad_test_auto',[pos_in(1)-5 pos_in(2); pos_in(1)+5 pos_in(2)])
add_line('quad_test_auto',[pos_out(1)-5 pos_out(2); pos_out(1)+5 pos_out(2)])

%%
% connecting inport and outport of a block
h1 = get_param('quad_test_auto/nn_4','PortHandles');
h2=get_param('quad_test_auto/Mux5','PortHandles');
add_line('quad_test_auto',h2.Outport,h1.Inport)


mu=get_param('quad_test_auto/Mux5','PortConnectivity')
[~,~,mu_out]=mu.Position
% delete_line('quad_test_auto',{'Mux5/1'})
delete_line('quad_test_auto',mu_out)
add_line('quad_test_auto',{'Mux5/1'},{'nn_4/1'})
mu_2=get_param('quad_test_auto/Mux4','PortConnectivity')
[~,mu_2_out,~]=mu2.Position

% delete_line('quad_test_auto',mu_2_out)
% add_line('quad_test_auto',{'nn_4/1'},{'Mux4/2'})
    
%%
get_param('quad_test_auto/nn_4','position')
% 665 632 725 698  [X Y Width Height]
% [x0 y0 x0+x_width y0+y_width]
% x0,y0: point - top left of the block
% and bottom right 
open_system('quad_test_auto')
%% returns handles
Simulink.findBlocks('quad_test_auto')
%% returns blocknames
getfullname(Simulink.findBlocks('quad_test_auto'))

getfullname(Simulink.findBlocksOfType('quad_test_auto','SubSystem'))

f = Simulink.FindOptions('SearchDepth',1);

%% test with vdp
% note that 0,0 is top left corner
open_system('vdp')
s = get_param('vdp/Sum','PortConnectivity');
s.Position
% inport x is 250
% outport is 285
b=get_param('vdp/Sum','position');
b
% block x is 255
% block x+width is 280

%%% Again the distance between the port and the block is 5 both for input
%%% and output.

%% use Search Depth for top level
% To have it replace only blocks in the top level, use the 'SearchDepth' argument as follows:
% replace_block('vdp', 'SearchDepth', 1, 'BlockType', 'Gain', 'Integrator')