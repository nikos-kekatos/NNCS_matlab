%slid_ % new SIMULINK and STATEFLOW diagram
Tfinal=0.5; options=simset('MaxStep',1e-3);
gcf;  title('Sliding mode control: start anywhere, go to switching line, slide to (0,0)')%,'color','red','Parent',hax)
ic=[-0.04,0.8];  phase_SLIdraw
ic=[-0.04,0.8];  phase_SLIdraw
ic=[0.04,-0.9];  phase_SLIdraw
ic=[-0.04,0.8];  phase_SLIdraw
ic=[-0.07,-0.6]; phase_SLIdraw
ic=[+0.07,-1.0];  phase_SLIdraw

function phase_SLIdraw
    global ic Tfinal options ;
    ic
    plot(ic(1),ic(2),'pr')%    mark start coordinates with pentagram star
    sim('slid_',[0,Tfinal],options);  %SIMULINK and STATEFLOW simulation
    plot(x1(:,2),x2(:,2),'r')%      phase portrait x'=f(x) for siding mode
    pause(1)
end
