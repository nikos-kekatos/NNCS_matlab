load data.mat

time  = diabetic(1,:);
glucose_sp = diabetic(2,:);
insulin = diabetic(3,:);
meals = diabetic(4,:);
glucose = diabetic(5,:);

figure(1)
hold off

subplot(2,1,1)
hold off
plot(time,insulin,'b-','LineWidth',2)
axis([min(time) max(time) 1 5]);
legend('Insulin Injection')
ylabel('Insulin (\muU/min)')

subplot(2,1,2)
hold off
plot(time,glucose,'b:','LineWidth',2)
legend('Blood Glucose')
axis([min(time) max(time) ...
    min(min(glucose),min(glucose_sp))-10 ...
    max(max(glucose),max(glucose_sp))+10]);
ylabel('Glucose (mg/dl)')
xlabel('Time (hr)')


% save data to text file
data = diabetic';

save -ascii 'data.txt' data