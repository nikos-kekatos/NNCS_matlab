function [options] = create_NN_diagram(options,net)
%create_NN_diagram Create and save SLX file with NN
%   Move to the correct directory and save the SLX file there. Then return
%   back.
load_system(options.SLX_model);
model_path = get_param(bdroot, 'FileName');
folder_path=fileparts(model_path); % goes up one directory
original_path=pwd;
% cd(folder_path);
% options.SLX_NN_model=strcat(options.SLX_model,'_NN');
gensim(net,'InputMode','none','OutputMode','none')
% save_system('untitled','nn_gensim','ErrorIfShadowed',true)
options.NN_model='nn_gensim';
if options.debug
if exist(options.NN_model,'file')
    disp('Please note that we have not deleted the NN model.')
    close_system(options.NN_model);
end
% else % no debug
%     disp('We have deleted the temporary Simulink file which contained the NN');
%     close_system(options.NN_model);
%     delete(strcat(options.NN_model,'.slx'))    
end
save_system('untitled',options.NN_model);
% cd(original_path);

end

