function construct_SLX_with_NN(options,file_name,block_name)
%construct_SLX_with_NN Constucting SLX with NN block
%   We start from the original options.SLX_model. The default file should
%   be named (originalName_NN.slx) and the default block should be NN.

NN_model=options.NN_model;
load_system(file_name);
model_path = get_param(bdroot, 'FileName');
folder_path=fileparts(model_path); % goes up one directory
original_path=pwd;
cd(folder_path);
% if nargin>=2
%     options.SLX_NN_model=file_name;
% elseif nargin==1
%     options.SLX_NN_model=strcat(options.SLX_model,'_NN');
% end
% if ~exist(options.SLX_NN_model,'file')
%     save_system(options.SLX_model,options.SLX_NN_model);
% end
% load_system(options.SLX_NN_model);
load_system(NN_model);
% default name for NN in Simulink is ``NN``
if nargin<=2
    default_block_name='NN';
else
    default_block_name=block_name;
end
% delete NN block to closed loop SLX model
Simulink.SubSystem.deleteContents(strcat([file_name filesep default_block_name]));

% Simulink.SubSystem.deleteContents(strcat(options.SLX_NN_model,'/',default_block_name));
% from gensim model, create a new temp file with the subsystem elements
temp_filename='temp_gensim_NN';
% create an empty SLX model file
if exist(temp_filename,'file')
    disp('Filename already exists.');
end
new_system(temp_filename);
load_system(temp_filename);
Simulink.SubSystem.copyContentsToBlockDiagram(strcat(NN_model,'/Feed-Forward Neural Network'),temp_filename);

% Simulink.BlockDiagram.copyContentsToSubsystem...
%     (temp_filename, strcat(options.SLX_NN_model,'/',default_block_name))
Simulink.BlockDiagram.copyContentsToSubsystem...
    (temp_filename, strcat(file_name,'/',default_block_name));
close_system(temp_filename,0);
close_system(NN_model,0);

%pc=get_param(strcat(options.SLX_NN_model,'/',default_block_name),'portconnectivity')

pc=get_param(strcat(file_name,'/',default_block_name),'portconnectivity');
[pos_in,pos_out]=pc.Position;


% add_line(options.SLX_NN_model,[pos_in(1)-5 pos_in(2); pos_in(1)+5 pos_in(2)])
% add_line(options.SLX_NN_model,[pos_out(1)-5 pos_out(2); pos_out(1)+5 pos_out(2)])

add_line(file_name,[pos_in(1)-5 pos_in(2); pos_in(1)+5 pos_in(2)]);
add_line(file_name,[pos_out(1)-5 pos_out(2); pos_out(1)+5 pos_out(2)]);

close_system(file_name,1);
% close_system(options.SLX_NN_model,1)
delete(strcat(NN_model,'.slx'));
cd(original_path);
end

