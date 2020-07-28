%Error in each joint

E_1=SP_1-PV_1;
E_2=SP_2-PV_2;
E_3=SP_3-PV_3;
E_4=SP_4-PV_4;
E_5=SP_5-PV_5;
E_6=SP_6-PV_6;
E_7=SP_7-PV_7;

%joint 1
figure(1)
plot(Time,SP_1,Time,PV_1);
title('Joint 1 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(2)
plot(Time,E_1);
title('Joint 1 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 2
figure(3)
plot(Time,SP_2,Time,PV_2);
title('Joint 2 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(4)
plot(Time,E_2);
title('Joint 2 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 3
figure(5)
plot(Time,SP_3,Time,PV_3);
title('Joint 3 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(6)
plot(Time,E_3);
title('Joint 3 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 4
figure(7)
plot(Time,SP_4,Time,PV_4);
title('Joint 4 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(8)
plot(Time,E_4);
title('Joint 4 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 5
figure(9)
plot(Time,SP_5,Time,PV_5);
title('Joint 5 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(10)
plot(Time,E_5);
title('Joint 5 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 6
figure(11)
plot(Time,SP_6,Time,PV_6);
title('Joint 6 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(12)
plot(Time,E_6);
title('Joint 6 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

%joint 7
figure(13)
plot(Time,SP_7,Time,PV_7);
title('Joint 7 SP-PV');
xlabel('Time (s)');
ylabel('Position (rad)');
legend('SP','PV','Location','southeast');

figure(14)
plot(Time,E_7);
title('Joint 7 Error');
xlabel('Time (s)');
ylabel('Error (rad)');
legend('Error','Location','southeast');

