function dydt=first_order_slx(x)
    u=x(1);
    y=x(2);
    tau=5;
    K=2;
    dydt=(-y+K*u)/tau;
end