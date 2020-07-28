% phase00_.m    variable initialisation and axis,  invoked by   start_sli.m
hfig=figure; hax=newplot; hold on
xlabel ('x'), ylabel('dx/dt')
title('click IC: hyperbolic, than click in the uper left corner  ','color','k')
sw=[1,0]; c=0;
yc=0;                   %there is no switching line yet
% ic=[0.05,-0.8]; 
Tfinal=0.3; options=simset('MaxStep',Tfinal/400);
xx=[-.1 .1 ]; yy=[-1 1] ;   axis([xx yy])      %set axis limits  
plot( xx, [0 0],  ':',   [0 0], yy,  ':')                     %plot axis
set(gcf,'MenuBar','none','NumberTitle','off','Name', 'SLIDING Mode CONTROLLER');  %nadano tytul


