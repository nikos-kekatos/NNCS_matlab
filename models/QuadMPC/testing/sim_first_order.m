clear;close all;clc;

t=linspace(0,10);
y0=0.5;
u=1;

z=ode23(@(t,y)first_order(t,y,u),t,y0);
time=z.x;
y=z.y;
plot(time,y)

first_order(0,0.5,1)
sim('model_first_order.slx')