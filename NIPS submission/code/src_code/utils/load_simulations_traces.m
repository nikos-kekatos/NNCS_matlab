load('random_reference_multiple_simulations_30traces_robotic_arm_time_04-02-2020_10:26.mat')
R_1=REF_array;Y_1=Y_array;U_1=U_array;
load('random_reference_multiple_simulations_40traces_robotic_arm_time_05-02-2020_16:00.mat')
R_2=REF_array;Y_2=Y_array;U_2=U_array;
load('random_reference_random_x0_multiple_simulations_153traces_robotic_arm_time_06-02-2020_11:25.mat')
R_3=REF_array;Y_3=Y_array;U_3=U_array;
load('random_reference_random_x0_multiple_simulations_289traces_robotic_arm_time_06-02-2020_22:46.mat')
R_4=REF_array;Y_4=Y_array;U_4=U_array;
load('random_reference_random_x0_multiple_simulations_81traces_robotic_arm_time_05-02-2020_19:17.mat')
R_5=REF_array;Y_5=Y_array;U_5=U_array;

REF_array=[R_1;R_2;R_3;R_4;R_5];
U_array=[U_1;U_2;U_3;U_4;U_5];
Y_array=[Y_1;Y_2;Y_3;Y_4;Y_5];