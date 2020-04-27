function [net_struct,net]=finding_weights(file_name,block_name)
%finding_weights Finds the structure of a NN Simulink block.
%   We consider a block generated via gensim. This function is able to find
%   the weights, biases, normalization factors and recreate the 'net' object.
%   A new Simulink block is generated which is exactly the same with the
%   original neural net block.
%
%  This code has been tested on the robot-arm Simulink model.
%
% Syntax:
%    finding_weights(file_name,block_name)
%    finding_weights() % then, the default model and block will be used.
%
% Inputs:
%    file_name: name of the Simulink model which contains the NN block
%    block_name: name of the Simulink block which is constructed via gensim
%
% Outputs:
%    net_struct: The weights, structure, etc. of the neural network
%    net:  the network object
%    A new Simulink file is created automatically.
%
% Example:
%       [net_struct,net]=finding_weights(file_name,block_name)
%       finding_weights
%       [net_struct,net]=finding_weights('robotarm_generalization_error','pre_0.00003')

%
% Author:       Nikos Kekatos
% Written:      27-April-2020
% Last update:  ---
% Last revision:---


if nargin<1
    file_name='robotarm_generalization_error';
    block_name='pre_0.00003';
elseif nargin<2
    block_name='pre_0.00003';
else
    fprintf('\n A new NN will be constructed for the "%s" block of the "%s" Simulink file.\n\n',file_name,block_name);
end

load_system(file_name);

% checking if block exists
find_system(sprintf('%s/%s/Layer 1/IW{1,1}',file_name,block_name));

% create new variable to describe the path
block_path=strcat(file_name,'/',block_name);

% finding number of inputs
temp_1=get_param(sprintf('%s/Process Input 1/mapminmax',block_path),'Handle');
temp_2=get(temp_1);
no_inputs=length(str2num(temp_2.xmin));
fprintf('The number of inputs equals %i.\n\n',no_inputs);
% no_inputs=10;

% finding number of outputs
temp_3=get_param(sprintf('%s/Process Output 1/mapminmax_reverse',block_path),'Handle');
temp_4=get(temp_3);
no_outputs=length(str2num(temp_4.xmin)); %no_outputs=1;
fprintf('The number of outputs equals %i.\n\n',no_outputs);

% finding number of layers (hidden layers +1)
all_block_names=find_system(block_path,'LookUnderMasks','on','SearchDepth',1);
string_blocks=strfind(all_block_names,'Layer');
layers=length(find(~cellfun(@isempty,string_blocks))); %layers=3;
hidden_layers=layers-1;

% the type of activation functions (for now) is given by the user.
activation_functions={'tansig','tansig','purelin'};

%finding the number of neurons (selected by the user)
no_neurons=[]; % 30x30

B_cell=cell(layers,1);
for l=1:layers
    fprintf(' Layer %i.\n\n',l)
    
    b_block_name=strcat(block_path,"/Layer ",num2str(l),"/b{",num2str(l),"}");
    b_temp_str=get_param(b_block_name,'value');
    B_cell{l}=str2num(b_temp_str);
    
    if l<layers
        no_neurons=[no_neurons, size(B_cell{l},1)];
        for i=1:no_neurons(l)
            if l==1 % notice the different definition of the weights for the first layer
                w_block_name=strcat(block_path,"/Layer 1/IW{1,1}/IW{1,1}(",num2str(i),",:)'");
            elseif l>1 && l<=hidden_layers
                w_block_name=sprintf("%s/Layer %i/LW{%i,%i}/IW{%i,1}(%i,:)'",block_path,l,l,l-1,l,i);
            end
            w_temp_str=get_param(w_block_name,'value');
            w_cell{i}=str2num(w_temp_str);
        end
        
    elseif l==layers % output layers
        clear w_cell
        for i=1:no_outputs
            w_block_name=sprintf("%s/Layer %i/LW{%i,%i}/IW{%i,%i}(%i,:)'",block_path,l,l,l-1,l,l-1,i);
            w_temp_str=get_param(w_block_name,'value');
            w_cell{i}=str2num(w_temp_str);
        end
    end
    W_cell{l}=cell2mat(w_cell)';
    
end
fprintf('Weight computation completed.\n\n');
net_struct.name='Structure of the generated FF Neural Network';
net_struct.no_neurons=no_neurons;
net_struct.Weight_Matrix=W_cell;
net_struct.Bias_Matrix=B_cell;
net_struct.no_inputs=no_inputs;
net_struct.numLayers=layers;
net_struct.no_outputs=no_outputs;
net_struct.IW=cell(layers,1);
net_struct.IW{1}=W_cell{1};
net_struct.LW=cell(layers);
net_struct.LW{2,1}=W_cell{2};
net_struct.LW{3,2}=W_cell{3};
net_struct.b=B_cell;
net_struct.layers{1}.transferFcn='tansig';
net_struct.layers{2}.transferFcn='tansig';
net_struct.layers{3}.transferFcn='purelin';
net_struct.processFcns={'mapminmax'};
% find preprocessing values and saving in typical nntraintool format
input_scaling_handle=get_param(strcat(block_path,'/Process Input 1/mapminmax'),'Handle');
input_scaling_block=get(input_scaling_handle);
input_xmin_all=str2num(input_scaling_block.xmin);
input_xmax_all=str2num(input_scaling_block.xmax);
net_struct.input.range=[input_xmin_all, input_xmax_all];


%find scaling values for output
output_scaling_handle=get_param('robotarm_generalization_error/pre_0.00003/Process Output 1/mapminmax_reverse','Handle');
output_scaling_block=get(output_scaling_handle);
output_xmin_all=str2num(output_scaling_block.xmin);
output_xmax_all=str2num(output_scaling_block.xmax);
net_struct.output.range=[output_xmin_all, output_xmax_all];


fprintf("The resulting structure is saved as 'net_struct'.\n");

net=call_net_creation(net_struct);

    function net=call_net_creation(net_struct)
        % Creating a new neural net with specific weights
        
        % It is impossible to assign weights to the networks unless the NN is
        % already configured.
        
        net=feedforwardnet(net_struct.no_neurons);
        net.inputs{1}.processFcns=net_struct.processFcns;
        net.outputs{1,3}.processFcns=net_struct.processFcns;
        net=configure(net,rand(net_struct.no_inputs,20),rand(net_struct.no_outputs,20));
        view(net);
        
        net.IW{1,1}=net_struct.IW{1};
        net.LW{2,1}=net_struct.LW{2,1};
        net.LW{3,2}=net_struct.LW{3,2};
        net.b=net_struct.b;
        net.layers{1}.transferFcn='tansig';
        net.layers{2}.transferFcn='tansig';
        net.layers{3}.transferFcn='purelin';
        
        net.inputs{1}.range=net_struct.input.range;
        net.outputs{1,3}.range=net_struct.output.range;
        fprintf("\n The network object (net) is constructed.\n\n");

        gensim(net);
        
        fprintf('A new Simulink block with the generated NN has been constructed.\n\n');
        fprintf('The new file is named "untitled" and can be used for comparison against the original.\n\n');
    end
end
