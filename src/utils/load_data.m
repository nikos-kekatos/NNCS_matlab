function [data,options] = load_data(filename,options)
%load_data Here we load. process and add previous computed simulation traces
%   Detailed explanation goes here

load(filename{1},'data')
if ~exist('data','var')
data.REF=[];data.U=[];data.Y=[];
for no=1:numel(filename)
    load(filename{no},'REF','Y','U');    
    data.REF=[data.REF;REF];
    data.U=[data.U;U];
    data.Y=[data.Y;Y];
end
else
    load(filename{1},'data','options');
end

