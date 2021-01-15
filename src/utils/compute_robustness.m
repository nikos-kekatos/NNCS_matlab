function [J,options] = compute_robustness(ref,u,y,options)
%compute_cost_function It computes the robustness of a controller for a given
%time segment.
%   The inputs to this function are the traces ref,u, y (saved as
%   structures with time) and the options. The 'options' is a structure
%   which contains information regarding the controllers,
%   options.specs_file. The robustness of the trace is the output.

persistent counter
if isempty(counter)
  counter = 0;
end
counter=counter+1;
if counter==1
[~,property_all]=STL_ReadFile(options.specs_file);
if options.combination
    options.property=property_all{4};
else
    index=input('Which is the right STL property? (choose 1,2 or 3)');
    options.property=property_all{index};
end
%
options.req=BreachRequirement(options.property);
options.req_vars=options.req.get_signals_in;
end
req_vars=options.req_vars;
for i=1:length(req_vars)
    if options.debug
        fprintf('\n Searching variable name %i of the requirement.\n',i);
    end
    req_temp=req_vars{i};
    % assumptions: references are named as In1, In2, ... outputs: y, y_nn,
    % y_nn_cex or y1, y2, etc. Note in most examples they are
    % one-dimensional. controls: u or u_nn or u1, u2...
    if regexp(req_temp,'In')
        if length(regexp(req_temp,'\d'))==1 ||isempty(regexp(req_temp,'\d', 'once'))
            index_trace{i}=str2double(req_temp(regexp(req_temp,'\d')));
            var_trace{i}=ref.signals.values(:,(index_trace{i}));
        else
            fprintf('\nmore than 10 references, fix.\n\n')
        end
    elseif regexp(req_temp,'y')
        if length(regexp(req_temp,'\d'))==1 ||isempty(regexp(req_temp,'\d', 'once'))
            index_trace{i}=str2double(req_temp(regexp(req_temp,'\d')));
            if index_trace{i}==0 || isnan(index_trace{i})
                index_trace{i}=1;
            end
            var_trace{i}=y.signals.values(:,(index_trace{i}));
            
        else
            fprintf('\nmore than 10 y, fix.\n\n')
        end
    elseif regexp(req_temp,'u')
        if length(regexp(req_temp,'\d'))==1 ||isempty(regexp(req_temp,'\d', 'once'))
            index_trace{i}=str2double(req_temp(regexp(req_temp,'\d')));
            if index_trace{i}==0
                index_trace{i}=1;
            end
            var_trace{i}=u.signals.values(:,(index_trace{i}));
            
        else
            fprintf('\nmore than 10 outputs, fix.\n\n')
        end
    end
end
% index_trace equals zero means that we have an example like y and we
% should take the first element of Y.signals.values

t_traces=ref.time;
if t_traces(1)>0
    t_traces=t_traces-t_traces(1);
    fprintf('Changed starting time back to 0.\n')
end
X_traces=cell2mat(var_trace);
% original 
J=options.req.Eval(t_traces',X_traces');
% attempt 2-- delete last point
J=options.req.Eval(t_traces(1:end-1)',X_traces(1:end-1,:)');

if options.debug
    J
end
end
