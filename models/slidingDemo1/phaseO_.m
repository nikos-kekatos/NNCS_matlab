disp('PHASE 2: non-stable osc')
doHyp=0;
sw=[0,1]
title('PHASE 2: unstable oscilations','color','blue','Parent',hax)
Tfinal=0.9; options=simset('MaxStep',Tfinal/80);
button=1;  %do not stop now
 %      draw phase portrait x'=f(x) for siding mode
ic=[-0.003, +0.03]; phase_O_draw;
ic=[+0.003, -0.03]; phase_O_draw;
ic=[-0.003, -0.03]; phase_O_draw;
ic=[+0.003, +0.03]; phase_O_draw;
ic=[0,-0.03]; phase_O_draw;
ic=[0,+0.03]; phase_O_draw;

function phase_O_draw
    global ic Tfinal options ;
    ic
    sim('slid_tst_',[0,Tfinal],options);  %SIMULINK simulation
    plot(x1(:,2),x2(:,2),'b-.')% unstable oscilations, phase portrait x'=f(x)
    pause(1)
end