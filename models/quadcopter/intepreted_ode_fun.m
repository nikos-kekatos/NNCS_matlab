function dydt = intepreted_ode_fun(x)
y=x(1);
u=x(3);
z=x(2);
tau=5;
K=2;
dydt(1)=(-y+K*u)/tau;
dydt(2)=y-z;
end

