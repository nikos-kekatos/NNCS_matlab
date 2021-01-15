load vector.mat
figure
box on
plot3([0 1 0 0]', [1 0 0 1]', [0 0 1 0]')
axis([0 1 0 1 0 1]); 
view(135, 13)
curve_1 = animatedline('LineWidth',1)
curve_2 = animatedline('LineWidth',1)
z = linspace(1,300,300)
hold on
for i = 1:length(z)
    addpoints(curve_1, x2(i,1), x2(i,2), x2(i,3));
    head_1 = scatter3(x2(i,1), x2(i,2), x2(i,3));
%     drawnow
     pause(0.5);
end