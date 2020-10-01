% controller gains as C{i}.Kp, .Ki, .Kd

%------------

%setting 1 and 2
options.controllers.C{1}.Kp = 20.8521889762703;
options.controllers.C{1}.Ki = 19.9734819620964;
options.controllers.C{1}.Kd = 0.820834909861585;
options.controllers.C{1}.N=18.1644836383948;
% integrator andfilter initial condition: 1.2649

% rise time 0.39 seconds
% settling time 2.43
% overshoot 15.1%
% peak 1.15

% intiial condition 0
% rise time 0.33 seconds
% settling time 2.54
% overshoot 10.1%
% peak 1.1
%------------



%------------
%setting 2
options.controllers.C{2}.Kp = 53.538537545704;
options.controllers.C{2}.Ki = 130.05253443786;
options.controllers.C{2}.Kd = -0.568215123958253;
options.controllers.C{2}.N=20.1671340799048;
% intiial condition 0
% rise time 0.11 seconds
% settling time 0.95
% overshoot 13.1%
% peak 1.13
%------------

%{
options.controllers.C{3}.Kp = 22.2064159670111
options.controllers.C{3}.Ki = 24.312774991531
options.controllers.C{3}.Kd = -1.06201362545283
options.controllers.C{3}.N=18.8366926362617

% for above
% rise time 0.21s
% settling time 2.17
% overshoot 14.2%
%peak 1.1

%}



%------------
% setting 1
%{ 
options.controllers.C{2}.Kp = 20.6312571937041;
options.controllers.C{2}.Ki = 19.4884721569968
options.controllers.C{2}.Kd = 0.825261402480276;
options.controllers.C{2}.N=16.782475881882;
%}
%------------

% for above
% rise time 0.33s
% settling time 2.58
% overshoot 10%
% peak 1.1

% 
% options.controllers.C{1}.Kp = 1.00184216792805;
% options.controllers.C{1}.Ki = 0.0715029518361115;
% options.controllers.C{1}.Kd = -0.0337374499215529;
% options.controllers.C{1}.N=25.8481850830944;
% 
% options.controllers.C{2}.Kp = 3;%20.8521889762703;
% options.controllers.C{2}.Ki = 1;%19.9734819620964;
% options.controllers.C{2}.Kd = 0.820834909861585;
% options.controllers.C{2}.N=18.1644836383948;
% 
% options.controllers.C{3}.Kp = 6.72200601587379;
% options.controllers.C{3}.Ki = 2.26506770923699;
% options.controllers.C{3}.Kd = -1.4447806890366;
% options.controllers.C{3}.N=4.53935325696756;

% options.controllers.C{2}.Kp = 22.2064159670111
% options.controllers.C{2}.Ki = 24.312774991531
% options.controllers.C{2}.Kd = -1.06201362545283
% options.controllers.C{2}.N=18.8366926362617

