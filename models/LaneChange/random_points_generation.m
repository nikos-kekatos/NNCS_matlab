function Data=random_points_generation(no_points)

global Vx mpcobj initialState
% use a different seed such as rng('shuffle') to create differing data
rng(0)


% Generate random data
Data = zeros(no_points,9);
for ct = 1:no_points
    [x0,u0,rho] = getFeaturesRandomImLKA;
    initialState.Plant = x0;
    initialState.LastMove = u0;
    [uStar,info] = mpcmove(mpcobj,initialState,x0,zeros(1,4),Vx*rho);
    
    % vy,r,e1,e2,u,rho,cost,iterations,uStar
    Data(ct,:) = [x0(:)',u0,rho,info.Cost,info.Iterations,uStar];
end

end