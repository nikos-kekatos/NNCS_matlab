function [options] = create_NN_diagram(options,net)
%create_NN_diagram Create and save SLX file with NN
%   Move to the correct directory and save the SLX file there. Then return
%   back.
load_system(options.SLX_model);
model_path = get_param(bdroot, 'FileName');
folder_path=fileparts(model_path); % goes up one directory
original_path=pwd;
%cd(folder_path)
% options.SLX_NN_model=strcat(options.SLX_model,'_NN');
gensim(net,'InputMode','none','OutputMode','none')
% save_system('untitled','nn_gensim','ErrorIfShadowed',true)
options.NN_model='nn_gensim';
close_system(options.NN_model);
save_system('untitled',options.NN_model);
cd(original_path)

end

