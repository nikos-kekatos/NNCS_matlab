%% testing NN
%clear;

% load('../../outputs/robotarm/array_sim_constant_ref_50_traces_50x1_time_16_10-02-2020_17:27.mat')
% 
% REF_array=REF;U_array=U;Y_array=Y;
% in=[REF_array-Y_array [0;REF_array(1:end-1)-Y_array(1:end-1)] [0;0;REF_array(1:end-2)-Y_array(1:end-2)]...
%                 [0;0;0;REF_array(1:end-3)-Y_array(1:end-3)] [0;U_array(1:end-1)] [0;0;U_array(1:end-2)]...
%                 [0;0;0;U_array(1:end-3)]]';

in=data.in;
uu=data.out;
size(in,1);
load_system('testing_NN_slx.slx');

for i=1:200%length(in)
    INPUTS=[0;in(:,i)];
    INPUTS=INPUTS';
    [out]=sim('testing_NN_slx.slx');
    OUT{i}=out.simout.signals.values;
    if mod(i,50)==0
    fprintf(' iteration %i.\n',i)
    end
end
%%
range=1:length(OUT);
u_net=sim(net,in);
figure;plot(range,cell2mat(OUT(range)),'bs',range,uu(range),'rx',range,u_net(range),'g*')
legend('original','gensim','sim-nn')
% figure;plot(range,cell2mat(OUT(range)),'.b',range,uu(range),'rx')
%%
%%
range=1:10;
u_net=sim(net,in);
figure;plot(range,cell2mat(OUT(range)),'bs',range,uu(range),'rx')
legend('sim-slx','original')
%%
range=1:length(OUT);
u_net=sim(net,in);
figure;plot(range,cell2mat(OUT(range)),'bs',range,u_net(range),'g*')
legend('sim-slx','sim-matlab')

%%
figure;
% subfigure(1,2,1);
% plot(range,cell2mat(OUT(range));