
%data generation
options.combination=0;
[data_single,options]=trace_generation_nncs(options.SLX_model_combined,options);
% [data_single,options]=trace_generation_nncs(options.SLX_model,options);
timer.trace_gen=toc(timer_trace_gen);

% Training
timer_train=tic;
iter=1;reached=0;
training_options.replace_by_zeros=0;
while true && iter<=training_options.iter_max_fail
    fprintf('\n Iteration %i.\n',iter);
    [net,data_single,tr]=nn_training(data_single,training_options,options);
    net_all{iter}=net;
    tr_all{iter}=tr;
    if tr_all{iter}.best_perf<training_options.error*10 && tr_all{iter}.best_vperf<training_options.error*100
        reached=1;
        break;
    else
        if iter<training_options.iter_max_fail
            iter=iter+1;
        else
            break;
        end
    end
end
fprintf('\n The requested training error was %f.\n',training_options.error);
if reached
    fprintf('The obtained training error is %f reached after %i random initializations.\n',tr_all{iter}.best_perf,iter);
    fprintf('The validation error is %f.\n',tr_all{iter}.best_vperf);
    net=net_all{iter};
    tr=tr_all{iter};
else
    fprintf('\n We ran %i training attempts with random initializations.\n',iter);
    for ii=1:iter
        training_perf(ii)=tr_all{ii}.best_perf;
    end
    iter_best=find(training_perf==min(training_perf));
    fprintf('\n The smallest training error was %f.\n',tr_all{iter_best}.best_vperf);
    fprintf('\n The smallest validation error was %f.\n',tr_all{iter_best}.best_vperf);
    net=net_all{iter_best};
    tr=tr_all{iter_best};
end
timer.train=toc(timer_train)
if options.plotting_sim
    figure;plotperform(tr)
end

%evaluate training
% options.plotting_sim=1
plot_NN_sim(data_single,options);

% Simulink
options.SLX_model_combined=strcat(options.SLX_model,'_comb')
% gensim(net)
[options]=create_NN_diagram(options,net);

file_name=options.SLX_model_combined;
construct_SLX_with_NN(options,file_name,'NN_single');
