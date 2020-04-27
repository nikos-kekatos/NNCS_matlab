clear;clc;

t=linspace(0,10);
y0=0.5;
u=1;
z=ode23(@(t,y) first_order(t,y,u),[0 10],y0);
time=z.x;
y=z.y;
figure;plot(time,y,'rx')
hold
[tt,yy]=ode23(@(t,y) first_order(t,y,u),[0 10],y0);

plot(tt,yy,'bd')
legend('struct','double')
function dydt=first_order(t,y,u)
tau=5;
K=2;
dydt=(-y+K*u)/tau;
end