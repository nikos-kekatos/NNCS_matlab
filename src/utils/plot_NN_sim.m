function  plot_NN_sim(data,options)
%plot_NN_sim This function simulates the generated NN.
%   The input of the NN is the entire dataset (training, validation & test
%   data.
if options.plotting_sim
    figure;
    for i=1:size(data.out,1)
        subplot(size(data.out,1),1,i)
        plot(1:length(data.out),data.out(i,:),'rx',1:length(data.out_NN),data.out_NN(i,:),'bs')
        xlabel('no of points')
        ylabel('output values $u$')
        legend('nominal','NN')
        title('Output of PID vs NN -- all points')
    end
    try
        figure;
        for i=1:size(data.out,1)
            subplot(size(data.out,1),1,i)
            plot(1:5000,data.out(i,1:5000),'rx',1:5000,data.out_NN(i,1:5000),'bs')
            xlabel('no of points')
            ylabel('output values $u$')
            legend('nominal','NN')
            title('Output of PID vs NN -- first 5000 points')
        end
    catch
%         figure;
        for i=1:size(data.out,1)
            subplot(size(data.out,1),1,i)
            plot(1:400,data.out(i,1:400),'rx',1:400,data.out_NN(i,1:400),'bs')
            xlabel('no of points')
            ylabel('output values $u$')
            legend('nominal','NN')
            title('Output of PID vs NN -- first 400 points')
        end
    end
end

