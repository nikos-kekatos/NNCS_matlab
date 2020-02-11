function [data,options] = load_data(filename,options)
%load_data Here we load. process and add previous computed simulation traces
%   Detailed explanation goes here
load(filename,'REF','Y','U')
data.REF=REF;
data.U=U;
data.Y=Y;
end

