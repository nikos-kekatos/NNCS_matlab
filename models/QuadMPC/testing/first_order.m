function dydt=first_order(t,y,u)
    tau=5;
    K=2;
    dydt=(-y+K*u)/tau;
end