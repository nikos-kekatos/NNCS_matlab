function [in,out] = format_nn_structure(training_options,data,type)
%format_nn_structure Get inputs and outputs of NN from simualtion traces
%   Detailed explanation goes here

%type 1 choose original (.REF,.U,.Y)
if type==1
    REF_in=data.REF;
    Y_in=data.Y;
    U_in=data.U;
elseif type==2
    REF_in=data.REF_cex;
    Y_in=data.Y_cex;
    U_in=data.U_cex;
end
if training_options.use_error_dyn
    if training_options.use_previous_y
        if training_options.use_previous_u
            in=[REF_in-Y_in [0;REF_in(1:end-1)-Y_in(1:end-1)] [0;0;REF_in(1:end-2)-Y_in(1:end-2)]...
                [0;0;0;REF_in(1:end-3)-Y_in(1:end-3)] [0;U_in(1:end-1)] [0;0;U_in(1:end-2)]...
                ]';
        else
            in=[REF_in-Y_in [0;REF_in(1:end-1)-Y_in(1:end-1)] [0;0;REF_in(1:end-2)-Y_in(1:end-2)]...
                [0;0;0;REF_in(1:end-3)-Y_in(1:end-3)]]';
        end
    else
        in=[REF_in-Y_in]';
    end
else
    if training_options.use_previous_y
        if training_options.use_previous_ref
            if training_options.use_previous_u
                in=[[REF_in] [0;REF_in(1:end-1)] [0;0;REF_in(1:end-2)] [0;0;0;REF_in(1:end-3)]...
                    [Y_in] [0;Y_in(1:end-1)] [0;0;Y_in(1:end-2)] [0;0;0;Y_in(1:end-3)]...
                    [0;U_in(1:end-1)] [0;0;U_in(1:end-2)]...
                    ]';
            else
                in=[[REF_in] [0;REF_in(1:end-1)] [0;0;REF_in(1:end-2)] [0;0;0;REF_in(1:end-3)]...
                    [Y_in] [0;Y_in(1:end-1)] [0;0;Y_in(1:end-2)] [0;0;0;Y_in(1:end-3)]...
                    ]';
            end
        else
            if training_options.use_previous_u
                in=[REF_in Y_in [0;Y_in(1:end-1)] [0;0;Y_in(1:end-2)]...
                    [0;0;0;Y_in(1:end-3)] [0;U_in(1:end-1)] [0;0;U_in(1:end-2)]...
                    ]';
            else
                in=[[REF_in] ...
                    [Y_in] [0;Y_in(1:end-1)] [0;0;Y_in(1:end-2)] [0;0;0;Y_in(1:end-3)]...
                    ]';
            end
        end
    else
        if training_options.use_previous_u
            in=[REF_in Y_in...
                [0;U_in(1:end-1)] [0;0;U_in(1:end-2)]...
                ]';
        else
            in=[[REF_in] ...
                [Y_in] ...
                ]';
        end
    end
end
% Output
out=U_in';
end

