%% training using a custom loss function


function elliottime
clear, clc
tic; for i = 1:1e4
y1 = tansig(1); % 0.7616
end; t1 = toc % 1.2259
tic; for i = 1:1e4
y2 = elliotsig(4*1); % 0.8000
end; t2= toc % 0.0029
tic; for i = 1:1e4
y3 = elliotsig4(1); % 0.8000
end; t3 = toc % 0.0027
tic; for i = 1:1e4
y4 = tanh(1); % 0.7616
end; t4 = toc % 5.94e-4
[ [ t1 t2 t3 t4 ]' [y1 y2 y3 y4 ]' ]
function y = elliotsig(x)
y = x./(1+abs(x));
end
function y = elliotsig4(x)
y = x./(0.25+abs(x));
end
end

%% asd
%{
x = -6:0.1:6;
y1 = x./(0.25+abs(x));
y2 = x.*(1 - (0.52*abs(x/2.6))) % (for -2.5<x<2.5).
figure
hold on
plot(x,y1)
plot(x,y2,'r')
legend('tansig','modified')
%}
