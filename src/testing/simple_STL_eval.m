% testing STL properties

% small example
tt=0:0.1:5;
xx=sin(tt)+0.5;
figure;plot(tt,xx,'x')

% Always is not influenced by the time horizon
r1=BreachRequirement('alw_[0,5] x[t]>0');
R1=r1.Eval(tt,xx)

r2=BreachRequirement('alw_[0,10] x[t]>0');
R2=r2.Eval(tt,xx)

r3=BreachRequirement('alw_[0,3] x[t]>0');
R3=r3.Eval(tt,xx)

% Eventually is not influenced by the time horizon
r4=BreachRequirement('ev_[4,5] x[t]>0');
R4=r4.Eval(tt,xx)

r5=BreachRequirement('ev_[4,10] x[t]>0');
R5=r5.Eval(tt,xx)

r6=BreachRequirement('ev_[4,4] x[t]>0');
R6=r6.Eval(tt,xx)



r7=BreachRequirement('alw([t]>7 => x[t]<0)');
R7=r7.Eval(tt,xx)


