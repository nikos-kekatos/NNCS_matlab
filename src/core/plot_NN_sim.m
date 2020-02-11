function  plot_NN_sim(data,options)
%plot_NN_sim This function simulates the generated NN.
%   The input of the NN is the entire dataset (training, validation & test
%   data.
if options.plotting_sim
    figure;
    plot(1:length(data.out),data.out,'rx',1:length(data.out_NN),data.out_NN,'bs')
    xlabel('no of points')
    ylabel('output values $u$')
    legend('nominal','NN')
    title('Output of PID vs NN -- all points')
    figure;
    plot(1:5000,data.out(1:5000),'rx',1:5000,data.out_NN(1:5000),'bs')
    xlabel('no of points')
    ylabel('output values $u$')
    legend('nominal','NN')
    title('Output of PID vs NN -- first 5000 points')
end

