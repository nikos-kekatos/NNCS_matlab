function c = mycombvec(varargin)
%column vectors
% copyright (c) 2018 Michael Tesch, tesch1@gmail.com
% released under the Apache 2.0 Open Source license.

if isempty(varargin)
    c = [];
    warning('The input vectors are empty')
    return
end

c = varargin{1};
for i=2:length(varargin)
    % make sure varargin{i} isn't more than 2d matrix
    if length(size(varargin{i}))>2
        error('parameters must be 2d matrices (check arg %d)', i);
    end
    c = mtextend(c, varargin{i});
end
function cc = mtextend(old, new)
mm = size(old,2);
nn = size(new,2);
cc = repmat(old, 1, nn);
cc = [cc ; repmat(new, 1, mm)];