title('PHASE 3:  set slant switching line ','color','k','Parent',hax)
    xc=-0.07; yc=0.8;  
xlabel('........ new switching line..............OK, wait...'), 
c=yc/xc;            %s=c*x1+x2=0  --> x2=-c*x1 switching line equation
[xaxis]=axis;  xx=[xaxis(1) xaxis(2)];                      % points on x1 axis
plot(xx,c*xx,'k','LineWidth',1)               % switching line  s==0
xlabel(['switching line eq: s=c*x1+x2=0 , c=',num2str(-c)]) 
