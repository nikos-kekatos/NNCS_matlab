function result = getRandomInputImFlyingRobot(b,existingData)
% Generates random data that is not in 'existingData' within given limits.
%
% Copyright 2019 The MathWorks, Inc.

% Calculate size of input observations
num = size(b,1);
x = rand(num,1);     % [0,1]
y = x*2.*b - b;      % [-b,b]
result = round(y,2); % format a.bc

% Check if the random input is a member of the input data. If it is
% recursively run.
if ~isempty(existingData)
    index = 1:size(b,1);
    if (size(b,1)) == 2
        index = 7:8;
    end
    % Check if the random input is a member of the input data. If it is
    % recursively run.
    if ismember(result',existingData(:,index),'rows')
        result = getRandomInputImFlyingRobot(b,existingData);
    end
end

end