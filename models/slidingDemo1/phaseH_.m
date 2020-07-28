% phaseH_.m
global ic Tfinal options ;
title('PHASE 1: hyperbolic ','color','g','Parent',hax)
doHyp=1;
Tfinal=0.3; options=simset('MaxStep',Tfinal/400);
%button=1;            doHyp=1;
% draw phase portrait x'=f(x) for siding mode
ic=[-0.08, +0.95];  phaseH_draw,
ic=[+0.08, -0.95];  phaseH_draw,
ic=[+0.05, -0.95];  phaseH_draw,
ic=[-0.03, +0.95];  phaseH_draw,
ic=[+0.03, -0.95];  phaseH_draw,
                
function phaseH_draw
    global ic Tfinal options ;
    ic
    sim('slid_tst_',[0,Tfinal],options);  %SIMULINK simulation
    plot(x1(:,2),x2(:,2),'g-.')  % draw phase portrait x'=f(x) for siding mode
    pause(1)
end
