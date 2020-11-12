function [in,out] = prepare_NN_structure(REF_array,Y_array,U_array,training_options,options)
%prepare_NN_structure Given traces and memory blocks, find NN inputs and
%outputs.
%   The number of memory blocks is user defined. The options include past
%   errors, inputs, references and outputs. 


no_REF_array=size(REF_array,2);
no_U_array=size(U_array,2);
no_Y_array=size(Y_array,2);


% Output
out=U_array';


old_u=training_options.use_previous_u;
old_y=training_options.use_previous_y;
old_ref=training_options.use_previous_ref;
old_error=training_options.use_error_dyn*old_ref;

% in=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)]...
%[zeros(2,no_REF_array);REF_array(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)]...
REF_=REF_array;REF_past=[];
for ii=1:old_ref
    REF_past=[REF_past,[zeros(ii,no_REF_array);REF_array(1:end-ii,:)]];
end

Y_=Y_array;Y_past=[];
for ii=1:old_y
    Y_past=[Y_past,[zeros(ii,no_Y_array);Y_array(1:end-ii,:)]];
end

U_=U_array; U_past=[];
for ii=1:old_u
    U_past=[U_past,[zeros(ii,no_U_array);U_array(1:end-ii,:)]];
end
% 
try
    E=REF_array-Y_array;
catch
    try
        options.y_index_track=[2,3];
        E=REF_array-Y_array(:,options.y_index_track);
    catch
        E=0;
    end
end
E_past=[];
% warning('error dynamics with different number of ref and y not supported')
for ii=1:old_error
    E_past=[E_past,[zeros(ii,no_REF_array);E(1:end-ii,:)]];
end
if training_options.use_error_dyn
    in=[E E_past U_past]';
else
    in=[REF_ REF_past Y_ Y_past U_past]';
end

%{
if training_options.use_error_dyn
    if training_options.use_previous_y
        if training_options.use_previous_u
%               e(k)               e(k-1)                           e(k-2)
            in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                ]';
            if options.model==4
                if options.extra_y
                    in=[in; Y_array'];
                    disp('Added y(k) as a separate input')
                end
                if options.extra_ref
                    in=[in;REF_array'];
                end
            end
            if training_options.replace_by_zeros==1
                no_points=size(in,2)/options.coverage.no_traces_ref;
                in(2,1:no_points:end)=0;
                in(3,1:no_points:end)=0;
                in(3,2:no_points:end)=0;
                in(4,1:no_points:end)=0;
                in(4,2:no_points:end)=0;
                in(4,3:no_points:end)=0;
                in(5,1:no_points:end)=0;
                in(6,1:no_points:end)=0;
                in(6,2:no_points:end)=0;
            elseif training_options.replace_by_zeros==2
                no_points=size(in,2)/options.coverage.no_traces_ref;
                index=1:no_points:(size(in,2)-no_points);
                for jj=index
                    in(2,jj)=in(1,jj);
                    in(3,jj)=in(1,jj);
                    in(3,jj+1)=in(1,jj);
                    in(4,jj)=in(1,jj);
                    in(4,jj+2)=in(1,jj);
                    in(4,3+jj)=in(1,jj);
                    in(5,jj)=out(1,jj);
                    in(6,jj)=out(1,jj);
                    in(6,jj+1)=out(1,jj);
                end
            end
        else
            in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)]]';
        end
    else
        in=[REF_array-Y_array]';
    end
else
    if training_options.use_previous_y
        if training_options.use_previous_ref
            if training_options.use_previous_u
                %                 in_REF=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)] [zeros(2,no_REF_array);REF_array(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)]];
                %                 in_Y=[[Y_array] [zeros(1,no_Y_array);Y_array(1:end-1,:)] [zeros(2,no_Y_array);Y_array(1:end-2,:)] [zeros(3,no_Y_array);Y_array(1:end-3,:)]];
                %                 in_U=[[zeros(1,no_U_array);U_array(1:end-1,:)] [zeros(2,no_U_array);U_array(1:end-2,:)]];
                %                 in=[in_REF in_Y in_U]';
                in=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)] [zeros(2,no_REF_array);REF_array(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)]...
                    [Y_array] [zeros(1,no_Y_array);Y_array(1:end-1,:)] [zeros(2,no_Y_array);Y_array(1:end-2,:)] [zeros(3,no_Y_array);Y_array(1:end-3,:)]...
                    [zeros(1,no_U_array);U_array(1:end-1,:)] [zeros(2,no_U_array);U_array(1:end-2,:)]...
                    ]';
            else
                in=[[REF_array] [zeros(1,no_REF_array);REF_array(1:end-1,:)] [zeros(2,no_REF_array);REF_array(1:end-2,:)] ...
                    [zeros(3,no_REF_array);REF_array(1:end-3,:)]...
                    [Y_array] [zeros(1,no_Y_array);Y_array(1:end-1,:)] [zeros(2,no_Y_array);Y_array(1:end-2,:)]...
                    [zeros(3,no_Y_array);Y_array(1:end-3,:)]...
                    ]';
            end
        else
            if training_options.use_previous_u
                in=[REF_array Y_array [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)]...
                    [0;0;0;Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                    ]';
            else
                in=[[REF_array] ...
                    [Y_array] [0;Y_array(1:end-1)] [0;0;Y_array(1:end-2)] [0;0;0;Y_array(1:end-3)]...
                    ]';
            end
        end
    else
        if training_options.use_previous_u
            in=[REF_array Y_array...
                [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                ]';
        else
            in=[[REF_array] ...
                [Y_array] ...
                ]';
        end
    end
end

if isfield(training_options,'mixed')
    if training_options.mixed
        if training_options.use_previous_u
            Y_select=Y_array(:,[2,3]);
            in=[[REF_array] [Y_array(:,1:3)] [REF_array-Y_select] [zeros(1,no_REF_array);REF_array(1:end-1,:)-Y_select(1:end-1,:)] ...
                [zeros(2,no_REF_array);REF_array(1:end-2,:)-Y_select(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)-Y_select(1:end-3,:)]...
                [zeros(1,no_U_array);U_array(1:end-1,:)] [zeros(2,no_U_array);U_array(1:end-2,:)]...
                ]';
        else
            Y_select=Y_array(:,[2,3]);
            in=[[REF_array] [Y_array(:,1:3)] [REF_array-Y_select] [zeros(1,no_REF_array);REF_array(1:end-1,:)-Y_select(1:end-1,:)] ...
                [zeros(2,no_REF_array);REF_array(1:end-2,:)-Y_select(1:end-2,:)] [zeros(3,no_REF_array);REF_array(1:end-3,:)-Y_select(1:end-3,:)]...
                ]';
        end
    end
end
%}
%%% replace by zeros or same values
try
    no_traces=options.no_traces;
catch
    no_traces=options.coverage.no_traces_ref;
end
% problems in retraining
no_points=options.T_train/options.dt;
no_traces=size(in,2)/no_points;

fprintf('\nThere are %i traces and each trace contains %i points.\n\n',no_traces,no_points);




if isempty(old_error)||old_error==0
    index_ref=1:no_REF_array;
    index_ref_past=[no_REF_array+1:(no_REF_array+no_REF_array*old_ref)];
    if ~isempty(index_ref_past)
        index_y=max(index_ref_past)+1:max(index_ref_past)+no_Y_array;
    else
        index_y=max(index_ref)+1:max(index_ref)+no_Y_array;
    end
    index_y_past=[max(index_y)+1:(max(index_y)+no_Y_array*old_y)];
    index_u_past=[max(index_y_past)+1:(max(index_y_past)+no_U_array*old_u)];
    if training_options.replace_by_zeros==0
        
        disp('There is no special treatment for the time shift operations')
    elseif training_options.replace_by_zeros==1
        
        index_temp_ref=index_ref_past;
        
        for ik=1:old_ref
            in(index_temp_ref,ik:no_points:end)=0;
            index_temp_ref=index_temp_ref(1+no_REF_array:end);
        end
        
        index_temp_y=index_y_past;
        for ik=1:old_y
            in(index_temp_y,ik:no_points:end)=0;
            index_temp_y=index_temp_y(1+no_Y_array:end);
        end
        
        index_temp_u=index_u_past;
        for ik=1:old_u
            in(index_temp_u,ik:no_points:end)=0;
            index_temp_u=index_temp_u(1+no_U_array:end);
        end
    elseif training_options.replace_by_zeros==2
        disp('There is no support yet for this method.')
    end
else % error dynamics
    index_error=1:no_REF_array;
    index_error_past=[no_REF_array+1:(no_REF_array+no_REF_array*old_ref)];
    index_u_past=[max(index_error_past)+1:(max(index_error_past)+no_U_array*old_u)];

%     index_error_past=(index_error+1):(index_error*no_REF_array*old_error);
 %   index_u_past=(index_error_past+1):(index_error_past+no_U_array);
    if training_options.replace_by_zeros==0
        disp('There is no special treatment for the time shift operations')
    elseif training_options.replace_by_zeros==1
        
        index_temp_error=index_error_past;
        for ik=1:no_REF_array
            in(index_temp_error,ik:no_points:end)=0;
            index_temp_error=index_temp_error(1+no_REF_array:end);
        end
                
        index_temp_u=index_u_past;
        for ik=1:old_u
            in(index_temp_u,ik:no_points:end)=0;
            index_temp_u=index_temp_u(1+no_U_array:end);
        end
    elseif training_options.replace_by_zeros==2
        disp('There is no support yet for this method.')
    end
    
end

if training_options.use_time
    t=0:options.dt:(options.T_train-options.dt);
    t_array=repmat(t,1,no_traces);
    in=[in;t_array];
end

end