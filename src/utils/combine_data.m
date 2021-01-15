function [data] = combine_data(varargin)
%combine_data Combine multiple datasets
%   It supports variable number of inputs given as data.REF, data.U, data.Y

data.REF=[];data.U=[];data.Y=[];
data_new=varargin;
for no=1:numel(varargin)
    data.REF=[data.REF;data_new{no}.REF];
    data.U=[data.U;data_new{no}.U];
    data.Y=[data.Y;data_new{no}.Y];
end
end

