function [net_cex,data] = nn_retraining(net,data,training_options,options,testing)
%nn_training This is for NN retraining.
%   Similar setting with NN training but more options.

REF_original=data.REF;
U_original=data.U;
Y_original=data.Y;

if options.testing_breach==0
    REF_cex=[];U_cex=[];Y_cex=[];
    for i=1:length(testing.errors_final_index)
        REF_cex=[REF_cex;testing.data.REF_test{i}];
        U_cex=[U_cex;testing.data.U_test{i}];
        Y_cex=[Y_cex;testing.data.Y_test{i}];
    end
elseif options.testing_breach==1
    REF_cex=data.REF_cex_breach;
    U_cex=data.U_cex_breach;
    Y_cex=data.Y_cex_breach;
elseif options.testing_breach==2 % split training in parts
    REF_cex=data.REF_cex;
    U_cex=data.U_cex;
    Y_cex=data.Y_cex;
end
data.REF_cex=REF_cex;
data.U_cex=U_cex;
data.Y_cex=Y_cex;

if training_options.retraining_method==1 % retrain with all from scratch
    
    REF_test=[REF_original;REF_cex];
    U_test=[U_original;U_cex];
    Y_test=[Y_original;Y_cex];
    
elseif training_options.retraining_method==2 %retrain with all but with old weights
    REF_test=[REF_original;REF_cex];
    U_test=[U_original;U_cex];
    Y_test=[Y_original;Y_cex];
elseif training_options.retraining_method==3 % old weights but new data only
    REF_test=[REF_cex];
    U_test=[U_cex];
    Y_test=[Y_cex];
elseif training_options.retraining_method==4 % find a cluster and blend/mix/combine
    %having only the three is probably wrong!!
    type=1; %1 for original, 2 for cex
    [in_orig,out_orig]=format_nn_structure(training_options,data,1);
    ALL=[in_orig',out_orig'];
    
    options.no_clusters=options.no_traces;
%         options.no_clusters=25;

            iteration=1;

    while true
        fprintf(' This is the %i iteration/loop with a number of %i clusters.\n\n',iteration,options.no_clusters);
        [idx,C]=kmeans(ALL,options.no_clusters);
        % for each cluster we select find the centroid (center of the cluster)
        % and then find 10 closest points
        nn_cluster=[];no_idx=[];
        for j=1:options.no_clusters
            diff=ALL((idx==j))-C(j,:);
            no_idx=[no_idx;length(find(idx==j))];
             fprintf('The total number of different points/samples in cluster %i is %i.\n\n',j,length(find(idx==j)));
            [diff_srt,ind]=sort(abs(diff)); % from smallest to largest
            
            %add check if there are less than 10 samples in the cluster
            m=size(diff_srt,1);
            points_per_cluster=50;
            m_des=40;
            if m>=points_per_cluster
                nn_cluster=[nn_cluster;diff_srt(1:points_per_cluster,:)];
            else
                nn_cluster=[nn_cluster;diff_srt(1:m,:)];
            end
        end
        in_nn_cluster=nn_cluster(:,1:size(in_orig,1));
        out_nn_cluster=nn_cluster(:,1:(size(ALL,2)-size(in_orig,1)));
        if no_idx(:)>m_des
            fprintf('All clusters have more than %i points.\n\n',m_des);
            break;
        else
            options.no_clusters=options.no_clusters-1;
            iteration=iteration+1;
        end
    end
    fprintf('Started with %i clusters ended up with %i clusters.\n\n',options.no_traces,options.no_clusters);

    %%
    [in_cex,out_cex]=format_nn_structure(training_options,data,2);
    in=[in_nn_cluster',in_cex];
    out=[out_nn_cluster',out_cex];
elseif training_options.retraining_method==5 %weighted
    REF_test=[REF_original;REF_cex];
    U_test=[U_original;U_cex];
    Y_test=[Y_original;Y_cex];
end

no_REF_test=size(REF_test,2);
no_U_test=size(U_test,2);
no_Y_test=size(Y_test,2);

if training_options.retraining_method~=4
    if training_options.use_error_dyn
        if training_options.use_previous_y
            if training_options.use_previous_u
                in=[REF_test-Y_test [0;REF_test(1:end-1)-Y_test(1:end-1)] [0;0;REF_test(1:end-2)-Y_test(1:end-2)]...
                    [0;0;0;REF_test(1:end-3)-Y_test(1:end-3)] [0;U_test(1:end-1)] [0;0;U_test(1:end-2)]...
                    ]';
            else
                in=[REF_test-Y_test [0;REF_test(1:end-1)-Y_test(1:end-1)] [0;0;REF_test(1:end-2)-Y_test(1:end-2)]...
                    [0;0;0;REF_test(1:end-3)-Y_test(1:end-3)]]';
            end
        else
            in=[REF_test-Y_test]';
        end
    else
        if training_options.use_previous_y
            if training_options.use_previous_ref
                if training_options.use_previous_u
%                     in=[[REF_test] [0;REF_test(1:end-1)] [0;0;REF_test(1:end-2)] [0;0;0;REF_test(1:end-3)]...
%                         [Y_test] [0;Y_test(1:end-1)] [0;0;Y_test(1:end-2)] [0;0;0;Y_test(1:end-3)]...
%                         [0;U_test(1:end-1)] [0;0;U_test(1:end-2)]...
%                         ]';
                in=[[REF_test] [zeros(1,no_REF_test);REF_test(1:end-1,:)] [zeros(2,no_REF_test);REF_test(1:end-2,:)] [zeros(3,no_REF_test);REF_test(1:end-3,:)]...
                    [Y_test] [zeros(1,no_Y_test);Y_test(1:end-1,:)] [zeros(2,no_Y_test);Y_test(1:end-2,:)] [zeros(3,no_Y_test);Y_test(1:end-3,:)]...
                    [zeros(1,no_U_test);U_test(1:end-1,:)] [zeros(2,no_U_test);U_test(1:end-2,:)]...
                    ]';
                else
                    in=[[REF_test] [0;REF_test(1:end-1)] [0;0;REF_test(1:end-2)] [0;0;0;REF_test(1:end-3)]...
                        [Y_test] [0;Y_test(1:end-1)] [0;0;Y_test(1:end-2)] [0;0;0;Y_test(1:end-3)]...
                        ]';
                end
            else
                if training_options.use_previous_u
                    in=[REF_test Y_test [0;Y_test(1:end-1)] [0;0;Y_test(1:end-2)]...
                        [0;0;0;Y_test(1:end-3)] [0;U_test(1:end-1)] [0;0;U_test(1:end-2)]...
                        ]';
                else
                    in=[[REF_test] ...
                        [Y_test] [0;Y_test(1:end-1)] [0;0;Y_test(1:end-2)] [0;0;0;Y_test(1:end-3)]...
                        ]';
                end
            end
        else
            if training_options.use_previous_u
                in=[REF_test Y_test...
                    [0;U_test(1:end-1)] [0;0;U_test(1:end-2)]...
                    ]';
            else
                in=[[REF_test] ...
                    [Y_test] ...
                    ]';
            end
        end
    end
    
    % Output
    out=U_test';
end

% Input normalization
if training_options.input_normalization==1
    in=mapminmax(in);
end

disp('')
disp('Re-training started')

if training_options.retraining_method==1 % retrain with all from scratch
    net=feedforwardnet(training_options.neurons);
    net = configure(net,in,out);
    % net.performFcn='custom_v1';
    net = init(net);
    net.divideFcn=training_options.div;
%     net.trainFcn='trainrp';
%     net.trainParam.epochs=15000;
    [net_cex,tr] = train(net, in, out);
    p = [in];
    uu = sim(net_cex,p);
    perf = perform(net_cex,in,out)
elseif training_options.retraining_method==2  % 2: keep old net and use all data...
    net.divideFcn=training_options.div;
    net.trainParam.goal=1e-6
    [net_cex,tr] = train(net, in, out);
    p = [in];
    uu = sim(net_cex,p);
%     perf = perform(net_cex,in,out)
    
    
elseif training_options.retraining_method==3  % 3: keep old net and use only new data
    net.divideFcn=training_options.div;
    [net_cex,tr] = train(net, in, out);
    p = [in];
    uu = sim(net_cex,p);
%     perf = perform(net_cex,in,out)
    
    
elseif training_options.retraining_method==4     % 4: blend/mix old and new datincremental retrain
    net.divideFcn=training_options.div;
    [net_cex,tr] = train(net, in, out);
    p = [in];
    uu = sim(net_cex,p);
    perf = perform(net_cex,in,out)
    
    % data.in=in;
    % data.out=out;
    % data.out_NN=uu;
    
    
elseif training_options.retraining_method==5
    net_cex=feedforwardnet(training_options.neurons);
    net_cex = configure(net_cex,in,out);
    net_cex.performFcn='wmse';
    net_cex = init(net_cex);
    net_cex.divideFcn=training_options.div;
    net_cex.trainFcn='trainrp'%'trainlm'; % trainscg % trainrp
    net_cex.trainParam.max_fail=50; 
    net_cex.trainParam.goal=1e-6; 

    global w;
    size_n=length((REF_test));
    w=zeros(size_n,1);
    w(1:length(REF_original))=0.1;
    w(1:length(REF_cex))=950;
    net_cex.trainParam.epochs=15000;

    [net_cex,tr] = train(net_cex, in, out);
    p = [in];
    uu = sim(net_cex,p);
    perf = perform(net_cex,in,out)
elseif training_options.retraining_method==6     % 4: blend/mix old and new datincremental retrain
%     warning('To-do: adding weights to the CEX');
%     warning('Returns old net');
%     net_cex=net;
    net.divideFcn=training_options.div;
    net.performFcn='wmse';
    net.trainFcn='trainrp'%'trainlm'; % trainscg % trainrp

    global w;
    size_n=length((REF_test));
    w=zeros(size_n,1);
    w(1:length(REF_original))=0.1;
    w(1:length(REF_cex))=0.9;
    [net_cex,tr] = train(net, in, out);
    p = [in];
    uu = sim(net_cex,p);
    perf = perform(net_cex,in,out)

end
disp('')
disp('Re-training finished')
end
