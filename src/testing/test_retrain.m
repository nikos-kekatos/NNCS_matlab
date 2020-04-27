[x,t] = simplefit_dataset;
net4 = feedforwardnet(10);
net4 = train(net4,x,t);
view(net4)
y = net4(x);
figure;plot(x,y,'r',x,t,':g');
legend('net','original')
perf = perform(net4,y,t)
net4=train(net4,x(1:10),t(1:10))
figure;plot(x,y,'r',x,t,':g',x,net4(x),'m-.');
legend('net','original','retraining')
perf = perform(net4,y,t)
title('Training with all data and retrain with first 10')
net5 = feedforwardnet(10);
net5 = train(net5,x,t);
yy=net5(x);
net5=train(net5,x,t)
figure;plot(x,yy,'r',x,t,':g',x,net5(x),'m-.');
legend('net','original','retraining')
title('Training with all data and retrain with all')

net6 = feedforwardnet(10);

net6 = train(net6,x,t);
yyy=net6(x);
net6=train(net6,x(20:end),t(20:end))
figure;plot(x,yyy,'r',x,t,':g',x,net6(x),'m-.');
legend('net','original','retraining')
title('Training with all data and retrain with all excluding first 20')

net7= feedforwardnet(10);
net7=train(net7,x(20:end),t(20:end));
yyyy=net7(x);
figure;plot(x,yyyy,'r',x,t,':k','linewidth',1.4);
legend('net','original')
title('Training with all data excluding first 10')


%%

[x,t] = simplefit_dataset;
Net = feedforwardnet(10);
Net = configure(Net,x, t);
Net2 = init(Net);
%
Net = train(Net,x,t);

%%
[x, t] = bodyfat_dataset;
net = feedforwardnet(10, 'trainlm');
net = train(net, x, t);
y = net(x);