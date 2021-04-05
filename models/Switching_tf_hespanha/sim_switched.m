%% Initialization

s=tf('s');
P=-1000/(s*(s+.875)*(s+50))


K1=(-6.694*(s+0.9446)*(s+50.01))/((s^2+13.23*s+9.453^2)*(s+50.05))
[num1,den1]=tfdata(K1);
K2=(-2187^2*(s+0.9977)*(s+66.28))/((s^2+467.2*s+486.2^2)*(s+507))
[num2,den2]=tfdata(K2);

[num1,den1,num2,den2]=deal(num1{1},den1{1},num2{1},den2{1});
T=50;
t0=0;
t1=18;
t2=40;
tend=T;
dt=0.001;
t_noise=(t2-t1)/dt;
variance = 10^-3; %10^(-1);
noise_part = sqrt(variance)*randn(size(1:(t_noise)));
noise_var=[0*(t0:dt:(t1-dt)),noise_part,0*(t2:dt:(tend))];
noise.time=t0:dt:tend;
noise.signals.values=noise_var';
% noise.signals.dimensions=

%% Realizations

sys_ctrl_1=ss(K1)

A1=[-63 -23 -17 ; 32 0 0;0 8 0];
B1=[ 4 0 0]';
C1=[1.7 2.7 0.31];
D1=0;

sys_ctrl_2=ss(K2)
A2=[-974 -459 -229.2;1024 0 0;0 512 0];
B2=[8192 0 0]';
C2=[5859 38 0.074];
D2=0;
C2_all=[C2;eye(3)];
D2_all=zeros(4,1)
%% Simstate wih TF

model_name='switched_simstate'
% model_name='switched_simstate_hes'

load_system(model_name)

% controller gains as C{i}.Kp, .Ki, .Kd

K{1}.num=num1;
K{1}.den=den1;
K{2}.num=num2;
K{2}.den=den2;

contNb=length(K);


timeNb=50;
timeNb_step=22;
timeId_span=[0,22,50];
%{
    if mod(timeNb,timeNb_step)==0 % equal segment time steps
        timeId_span=0:timeNb_step:timeNb;
    else % not equal time segments
        % T=10, tau=3
        % solution: 0:3:9 and 10,
        % segments:[0,3], [3,6], [6,9], [9,10]
        timeId_span=0:timeNb_step:floor(timeNb/timeNb_step)*timeNb_step;
        timeId_span=[timeId_span, timeNb];
    end
%}

segment_Id=0;
for timeId = timeId_span(1:end-1)
    
    
    segment_Id=segment_Id+1;
    if segment_Id==1 || segment_Id==3
        contID=1;
    elseif segment_Id==2
        contID=2;
    end
    starttime=timeId;
    %         stoptime=timeId+timeNb_step;
    stoptime=timeId_span(segment_Id+1);
    if stoptime>timeNb % the case when the intervals are not equal
        stoptime=timeNb;
    end
    if segment_Id==1 %first time horizon
        set_param(model_name, 'LoadInitialState','off');
        %set_param(model, 'SaveFinalState','on',...
        %'FinalStateName', 'SimState',...
        %'SaveOperatingPoint', 'on');
    else
        set_param(model_name,'LoadInitialState','on',...
            'InitialState','SimState_previous');
    end
    
    set_param(model_name,'StartTime',num2str(starttime),...
        'StopTime',num2str(stoptime));
    
    %%% For Matlab earlier than 2019a
    set_param(model_name,'SaveFinalState', 'on',...
        'FinalStateName', 'SimState');  %...
    %'SaveOperatingPoint', 'on');
    %{
        for contID = 1:contNb
            %         disp('New segment');
            timeId;
            segment_Id;
            contID;
            starttime;
            stoptime;
    %}
    set_param(strcat(model_name,'/Controller/'),'Numerator',strcat('[',(regexprep(num2str(K{contID}.num),'\s+',',')),']'), ...
        'Denominator',strcat('[',regexprep(num2str(K{contID}.den),'\s+',','),']'));
    
    
    sim(model_name);
    
    SimStateopt = SimState;
    min_cost(segment_Id)=contID;
    ref_opt{segment_Id}=ref;
    y_opt{segment_Id}=y;
    u_opt{segment_Id}=u;
    
    
    
    SimState_previous=SimStateopt;
end

% ref_opt is the combined structure
% clearvars ref y u
y.signals.values=[];
ref.signals.values=[];
u.signals.values=[];
ref.time=[];u.time=[];y.time=[];


for ii=1:segment_Id
    if ii<segment_Id
        ref_temp_time=ref_opt{ii}.time(1:(end-1));
        ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
        u_temp_time=u_opt{ii}.time(1:(end-1));
        u_temp_values=u_opt{ii}.signals.values(1:(end-1));
        y_temp_time=y_opt{ii}.time(1:(end-1));
        y_temp_values=y_opt{ii}.signals.values(1:(end-1));
    elseif ii==segment_Id
        ref_temp_time=ref_opt{ii}.time;
        ref_temp_values=ref_opt{ii}.signals.values;
        u_temp_values=u_opt{ii}.signals.values;
        y_temp_values=y_opt{ii}.signals.values;
        u_temp_time=u_opt{ii}.time;
        y_temp_time=y_opt{ii}.time;
    end
    %{
    if ii==1
        ref.time=[ref_temp_time]
    else
        ref.time=[ref.time;ref.time(end)+ ref_temp_time]
    end
    %}
    ref.time=[ref.time;ref_temp_time];
    u.time=[u.time;u_temp_time];
    y.time=[y.time;y_temp_time];
    y.signals.values=[y.signals.values;y_temp_values];
    u.signals.values=[u.signals.values;u_temp_values];
    ref.signals.values=[ref.signals.values;ref_temp_values];
end

figure;plot(ref.time,ref.signals.values,'-r',y.time,y.signals.values,'-.b')

%% Simstate with SS

clear ref y u u_opt u_temp_values u_temp_time y_opt y_temp_time y_temp_values
clear SimState SimState_previous SimStateopt tout starttime stoptime segment_Id
clear ref_opt ref_temp_time ref_temp_values out
model_name='switched_simstate_realization'
% model_name='switched_simstate_hes'

load_system(model_name)

% controller gains as C{i}.Kp, .Ki, .Kd
% A1=[-63 -23 -17 ; 32 0 0;0 8 0];
% B1=[ 4 0 0]';
% C1=[1.7 2.7 0.31];
% D1=0;

sys_ctrl_2=ss(K2)
% A2=[-974 -459 -229.2;1024 0 0;0 512 0];
% B2=[8192 0 0]';
% C2=[5859 38 0.074];
% D2=0;
%{
%slide
K{1}.A='[-63 -23 -17 ; 32 0 0;0 8 0]';
K{1}.B="[ 4 0 0]'";
K{1}.C='[1.7 2.7 0.31]';
K{1}.D='0';
%}
% K{1}.IC='[  -2.0828e+03,4.2418e-04, 1.6873e-07, -1.1442e-09]';
K{1}.IC='[10000000*4.2418e-01, 10000000*1.6873e-01, -1.1442e-01*10000000]'; %from ctrl 2
% K{1}.IC='0';
K{1}.IC='[-0.0010 , -0.0000,0.0000]'; %from ctrl 1

%ss
K{1}.A='[-63.28 -23.49 -8.735 ; 32 0 0;0 16 0]';
K{1}.B="[ 4 0 0]'";
K{1}.C='[-1.673 -2.665 -0.1544]';
K{1}.D='0';

%{
% slide
K{2}.A='[-974 -459 -229;1024 0 0;0 512 0]';
K{2}.B="[8192 0 0]'";
K{2}.C='[5859 38 0.074]';
K{2}.D='0';
%}
K{2}.IC='0';
contNb=length(K);
%ss
K{2}.A='[-974.2 -924.3 -457.2;512 0 0;0 512 0]';
K{2}.B="[2048 0 0]'";
K{2}.C='[-2335 -306.9 -0.5891]';
K{2}.D='0';
K{2}.IC='0';
dt=options.dt
timeNb=50;
timeNb_step=22;
timeId_span=[0,22,42];
%{
    if mod(timeNb,timeNb_step)==0 % equal segment time steps
        timeId_span=0:timeNb_step:timeNb;
    else % not equal time segments
        % T=10, tau=3
        % solution: 0:3:9 and 10,
        % segments:[0,3], [3,6], [6,9], [9,10]
        timeId_span=0:timeNb_step:floor(timeNb/timeNb_step)*timeNb_step;
        timeId_span=[timeId_span, timeNb];
    end
%}

segment_Id=0;
for timeId = timeId_span(1:end-1)
    
    
    segment_Id=segment_Id+1;
    if segment_Id==1 || segment_Id==3
        contID=2;
    elseif segment_Id==2
        contID=1;
    end
    starttime=timeId;
    %         stoptime=timeId+timeNb_step;
    stoptime=timeId_span(segment_Id+1);
    if stoptime>timeNb % the case when the intervals are not equal
        stoptime=timeNb;
    end
    if segment_Id==1 %first time horizon
        set_param(model_name, 'LoadInitialState','off');
        %set_param(model, 'SaveFinalState','on',...
        %'FinalStateName', 'SimState',...
        %'SaveOperatingPoint', 'on');
    else
        set_param(model_name,'LoadInitialState','on',...
            'InitialState','SimState_previous');
    end
    
    set_param(model_name,'StartTime',num2str(starttime),...
        'StopTime',num2str(stoptime));
    
    %%% For Matlab earlier than 2019a
    set_param(model_name,'SaveFinalState', 'on',...
        'FinalStateName', 'SimState');  %...
    %'SaveOperatingPoint', 'on');
    
    
    timeId;
    segment_Id;
    contID;
    starttime;
    stoptime;
    %} % A has to be written as a vector separate by ;
    set_param(strcat(model_name,'/State-Space/'),'A',K{contID}.A,'B',K{contID}.B,'C',K{contID}.C,'D',K{contID}.D,'InitialCondition',K{contID}.IC)%numstrcat('[',(regexprep(num2str(C{contID}.num),'\s+',',')),']'), ...
    %'Denominator',strcat('[',regexprep(num2str(C{contID}.den),'\s+',','),']'));
    
    %         get_param(strcat(model_name,'/State-Space/'),'DialogParameters')
    
    sim(model_name);
    
    SimStateopt = SimState;
    min_cost(segment_Id)=contID;
    ref_opt{segment_Id}=ref;
    y_opt{segment_Id}=y;
    u_opt{segment_Id}=u;
    
    
    
    SimState_previous=SimStateopt;
    
end
% ref_opt is the combined structure
% clearvars ref y u
y.signals.values=[];
ref.signals.values=[];
u.signals.values=[];
ref.time=[];u.time=[];y.time=[];


for ii=1:segment_Id
    if ii<segment_Id
        ref_temp_time=ref_opt{ii}.time(1:(end-1));
        ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
        u_temp_time=u_opt{ii}.time(1:(end-1));
        u_temp_values=u_opt{ii}.signals.values(1:(end-1));
        y_temp_time=y_opt{ii}.time(1:(end-1));
        y_temp_values=y_opt{ii}.signals.values(1:(end-1));
    elseif ii==segment_Id
        ref_temp_time=ref_opt{ii}.time;
        ref_temp_values=ref_opt{ii}.signals.values;
        u_temp_values=u_opt{ii}.signals.values;
        y_temp_values=y_opt{ii}.signals.values;
        u_temp_time=u_opt{ii}.time;
        y_temp_time=y_opt{ii}.time;
    end
    %{
    if ii==1
        ref.time=[ref_temp_time]
    else
        ref.time=[ref.time;ref.time(end)+ ref_temp_time]
    end
    %}
    ref.time=[ref.time;ref_temp_time];
    u.time=[u.time;u_temp_time];
    y.time=[y.time;y_temp_time];
    y.signals.values=[y.signals.values;y_temp_values];
    u.signals.values=[u.signals.values;u_temp_values];
    ref.signals.values=[ref.signals.values;ref_temp_values];
end

figure;plot(ref.time,ref.signals.values,'-r',y.time,y.signals.values,'-.b')

%% simstate tf -- integrator chain

model_name='switched_simstate_tf'
load_system(model_name)

K1=(-6.694*(s+0.9446)*(s+50.01))/((s^2+13.23*s+9.453^2)*(s+50.05))
[num1,den1]=tfdata(K1);
K2=(-2187^2*(s+0.9977)*(s+66.28))/((s^2+467.2*s+486.2^2)*(s+507))
[num2,den2]=tfdata(K2);

tf{1}.a0=num1{1}(4);
tf{1}.a1=num1{1}(3);
tf{1}.a2=num1{1}(2);
tf{1}.b0=den1{1}(4);
tf{1}.b1=den1{1}(3);
tf{1}.b2=den1{1}(2);
tf{2}.a0=num2{1}(4);
tf{2}.a1=num2{1}(3);
tf{2}.a2=num2{1}(2);
tf{2}.b0=den2{1}(4);
tf{2}.b1=den2{1}(3);
tf{2}.b2=den2{1}(2);
contNb=2;

options.dt=0.001;
dt=options.dt


timeNb=50;
timeNb_step=22;
timeId_span=[0,22,42];

segment_Id=0;
for timeId = timeId_span(1:end-1)
    
    
    segment_Id=segment_Id+1;
    if segment_Id==1 || segment_Id==3
        contID=2;
    elseif segment_Id==2
        contID=1;
    end
    starttime=timeId;
    %         stoptime=timeId+timeNb_step;
    stoptime=timeId_span(segment_Id+1);
    if stoptime>timeNb % the case when the intervals are not equal
        stoptime=timeNb;
    end
    if segment_Id==1 %first time horizon
        set_param(model_name, 'LoadInitialState','off');
        %set_param(model, 'SaveFinalState','on',...
        %'FinalStateName', 'SimState',...
        %'SaveOperatingPoint', 'on');
    else
        set_param(model_name,'LoadInitialState','on',...
            'InitialState','SimState_previous');
    end
    
    set_param(model_name,'StartTime',num2str(starttime),...
        'StopTime',num2str(stoptime));
    
    %%% For Matlab earlier than 2019a
    set_param(model_name,'SaveFinalState', 'on',...
        'FinalStateName', 'SimState');  ...
    %'SaveOperatingPoint', 'on');
    
    timeId;
    segment_Id;
    contID;
    starttime;
    stoptime;
    %} % A has to be written as a vector separate by ;
    set_param(strcat(model_name,'/Subsystem/a0'),'Gain',num2str(tf{contID}.a0))
    set_param(strcat(model_name,'/Subsystem/a1'),'Gain',num2str(tf{contID}.a1))
    set_param(strcat(model_name,'/Subsystem/a2'),'Gain',num2str(tf{contID}.a2))
    set_param(strcat(model_name,'/Subsystem/b0'),'Gain',num2str(tf{contID}.b0))
    set_param(strcat(model_name,'/Subsystem/b1'),'Gain',num2str(tf{contID}.b1))
    set_param(strcat(model_name,'/Subsystem/b2'),'Gain',num2str(tf{contID}.b2))

    
    %         get_param(strcat(model_name,'/Subsystem/'),'DialogParameters')
    
    sim(model_name);
    
    SimStateopt = SimState;
    min_cost(segment_Id)=contID;
    ref_opt{segment_Id}=ref;
    y_opt{segment_Id}=y;
    u_opt{segment_Id}=u;
    
    SimState_previous=SimStateopt;
    
end
% ref_opt is the combined structure
% clearvars ref y u
y.signals.values=[];
ref.signals.values=[];
u.signals.values=[];
ref.time=[];u.time=[];y.time=[];


for ii=1:segment_Id
    if ii<segment_Id
        ref_temp_time=ref_opt{ii}.time(1:(end-1));
        ref_temp_values=ref_opt{ii}.signals.values(1:(end-1));
        u_temp_time=u_opt{ii}.time(1:(end-1));
        u_temp_values=u_opt{ii}.signals.values(1:(end-1));
        y_temp_time=y_opt{ii}.time(1:(end-1));
        y_temp_values=y_opt{ii}.signals.values(1:(end-1));
    elseif ii==segment_Id
        ref_temp_time=ref_opt{ii}.time;
        ref_temp_values=ref_opt{ii}.signals.values;
        u_temp_values=u_opt{ii}.signals.values;
        y_temp_values=y_opt{ii}.signals.values;
        u_temp_time=u_opt{ii}.time;
        y_temp_time=y_opt{ii}.time;
    end
   
    ref.time=[ref.time;ref_temp_time];
    u.time=[u.time;u_temp_time];
    y.time=[y.time;y_temp_time];
    y.signals.values=[y.signals.values;y_temp_values];
    u.signals.values=[u.signals.values;u_temp_values];
    ref.signals.values=[ref.signals.values;ref_temp_values];
end

figure;plot(ref.time,ref.signals.values,'-r',y.time,y.signals.values,'-.b')
