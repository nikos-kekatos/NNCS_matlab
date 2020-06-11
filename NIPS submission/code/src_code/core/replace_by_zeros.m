function [in_new,out_new] = replace_by_zeros(in,out,training_options,options)
%replace_by_zeros Replace by zeros the first values of each trace
%   We use u[k-1],u[k-2],etc.


 in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
                [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
                ]';
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

