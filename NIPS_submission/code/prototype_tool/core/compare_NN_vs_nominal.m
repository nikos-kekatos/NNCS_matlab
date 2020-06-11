function compare_NN_vs_nominal(data,options)
%compare_NN_vs_nominal Here we compare the NN against the actual data.
%   We compare the Simulink block, the NN simulation options and the
%   original output when we provide the original inputs.
if options.plotting_sim
    figure;
    plot(1:length(data.out),data.out,'rx',1:length(data.out_NN),data.out_NN,'bs')
    xlabel('no of points')
    ylabel('output values $u$')
    legend('nominal','NN')
    title('Output of PID vs NN')
end

end

%% to do - add gensim option and comparison with sim