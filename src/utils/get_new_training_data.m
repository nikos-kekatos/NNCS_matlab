function [data_new] = get_new_training_data(data1,data2,training_options)
%get_new_training_data Combining old training data and cex for retraining
%   1: combine old and new-> keep all of them

if training_options.combining_old_and_cex==1
    data_new.REF=[data1.REF;data2.REF];
    data_new.U=[data1.U;data2.U];
    data_new.Y=[data1.Y;data2.Y];
end
end

