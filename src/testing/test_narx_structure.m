%  close all, clear all, clc, 
plt=0;
 [X,T] = simplenarx_dataset;
     net3 = narxnet(1,1:2,10);
     view(net3)
     [Xs,Xi,Ai,Ts] = preparets(net3,X,{},T);
     whos
     rng(0)
     [net3 tr Ys Es Xf Yf] = train(net3,Xs,Ts,Xi,Ai);
     view(net3)
     whos
     ts = cell2mat(Ts);
     MSE00 = var(ts,1)           % 0.099154
     ys = cell2mat(Ys);
     es = cell2mat(Es);
     R2 = 1-mse(es)/MSE00         % 1
     plt=plt+1,figure(plt)
     hold on
     plot(ts,'o','LineWidth',2)
    plot(ys,'r--','LineWidth',2)
    
    gensim(net3)
    
    %%
    net4=feedforwardnet([30,30]);
    % Cannot write on net4.numInputDelays (read-only)
    net4.numInputs=2; % so that we add separate delay blocks automatically
    
    net4.InputWeights
    net4.InputWeights{1,1}.delays
    
    net4.InputWeights{1,1}.delays=2
    net4.InputWeights{1,2}.delays=4
    net4.outputs{1,3}.feedbackDelay=3 % time units
    net4.outputs{1,3}.feedbackInput=1 % time units
    net4.InputWeights{1,2}.delays=4

    net4.LayerWeights{2,1}.delays
    net4.LayerWeights{3,2}.delays=2

    
    view(net4)