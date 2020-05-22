function[data_cex_cluster,idx_cluster]=cluster_and_sample(data_cex,falsif_pb,options,cluster_all)
%cluster_and_sample Clustering the CEX from Breach and sampling from a
%neighborhood around them
%   The steps followed involve i) use of counterexamples from Breach,
%   ii) clustering counterexamples based on the reference signals,
%   iii-a) finding an appropriate clustering technique which yields bounding borders/sets, or
%   iii-b) getting a bounded enclosure of the counterexamples in each cluster, or
%   iii-c) getting the convex hull of the points in each cluster
%   iv) obtain a tight bounded set that contains our counterexample in each cluster and probably bloat the set by an ε-term.
%   vi) perform sampling on the bloated clustering space.
%

% load('40_falsified_traces.mat')

%1. Keep only references and replace signals by points.
%{
falsif_idx=find(falsif_pb.obj_log<0);
no_cex=length(falsif_idx);
no_points_per_trace=length(data_cex.REF)/no_cex;
data_cex_ref=data_cex.REF;
fprintf('\n We have found %i counterexamples.\n',no_cex);
for i=1:no_cex
    temp_ref=unique(data_cex_ref((1+(i-1)*no_points_per_trace):i*no_points_per_trace));
    cex_ref_points{i}=temp_ref;
end
%K-means does not specify the number of clusters. So, we need to choose
%beforehand or iterate with different values.
cex_ref_points_array=cell2mat(cex_ref_points)'
%}

if nargin<4
    cluster_all=0;
end
if cluster_all==1
    data_cex_cluster=data_cex;
    return;
end
falsif_rob_values=falsif_pb.obj_false;
no_cex=length(falsif_rob_values);
cex_ref_points_array=falsif_pb.X_false(1:2:end,:)'; %ignore timing

if no_cex<10
    no_clusters=floor(no_cex/2)+1;
elseif no_cex>10 && no_cex<100
    no_clusters=floor(no_cex/3);
else
    no_clusters=floor(no_cex/4);
end

iteration=1;


fprintf(' This is the %i iteration/loop with a number of %i clusters.\n\n',iteration,no_clusters);
% Evaluate the optimal number of clusters using the silhouette
% clustering evaluation criterion.

E = evalclusters(cex_ref_points_array,'kmeans','silhouette','klist',[1:no_clusters])
figure;
plot(E);

optimal_no_clusters=E.OptimalK;
figure;gscatter(cex_ref_points_array(:,1),cex_ref_points_array(:,2),E.OptimalY,'rbgymck','xods*v><ph')
if options.plotting_sim
figure;plot(cex_ref_points_array(:,1),cex_ref_points_array(:,2),'k*','MarkerSize',5);
end
% replicates needed to avoid local minima
[idx,C]=kmeans(cex_ref_points_array,optimal_no_clusters,'replicates',8);
figure
gscatter(cex_ref_points_array(:,1),cex_ref_points_array(:,2),idx,'rbgymck','xods*v><ph')
hold on
plot(C(:,1),C(:,2),'k+')

%grid resolution as tolerance

cex_tolerance(options.coverage.delta_resolution)
disp(' ')
%user-defined tolerance
cex_tolerance(0.1)

% In each cluster, keep the samples with the smaller robustness

%map robustness values
% falsif_rob_values_sorted=falsif_rob_values(idx);
%find corresponding indices
for ii=1:optimal_no_clusters
    points_clusters{ii}=cex_ref_points_array(idx==ii,:)
    robustness_points_clusters{ii}=falsif_rob_values(idx==ii)'
end

%keep 3 in each cluster with minimum robustness
points_kept=[];index_kept=[];rob_kept=[];
for ii=1:optimal_no_clusters
    if length(robustness_points_clusters{ii})<=3
        fprintf('\n We will keep all points in cluster %i.\n',ii);
        %         points_kept=[points_kept;points_clusters{ii}];
        %         index_kept=[index_kept];
        rob_kept=[rob_kept;robustness_points_clusters{ii}]
    else
        fprintf('\n We will keep 3 points out of %i in cluster %i.\n',length(robustness_points_clusters{ii}),ii);
        [min_values,ix]=mink(robustness_points_clusters{ii},3);
        rob_kept=[rob_kept;min_values];
    end
    
end
fprintf('We will keep %i CEX out of total %i.\n',length(rob_kept),no_cex);

[tf,idx_kept]=ismember(rob_kept,falsif_rob_values)

% We will keep the idx_kept. However, what we have is the entire data_cex
% As such, we need to split the data_cex into pieces and keep the
% corresponing ones

% Need to match idx_kept to the array
idx_kept_new=[];
no_points=length(data_cex.REF)/no_cex
for i=1:length(idx_kept)
    idx_kept_new=[idx_kept_new;(idx_kept(i)-1)*no_points+1, idx_kept(i)*no_points]
end
indices_temp=sort(idx_kept_new,1)
index_final=[];
for i=1:length(idx_kept_new)
    index_final=[index_final,indices_temp(:,1):indices_temp(:,2)];
end
data_cex_cluster.REF=data_cex.REF(index_final,:);
data_cex_cluster.U=data_cex.U(index_final,:);
data_cex_cluster.Y=data_cex.Y(index_final,:);
idx_cluster=sort(idx_kept_new);
%{
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
%}


    function cex_tolerance(tol)
        nn_cluster=[];no_idx=[];
        
        for j=1:optimal_no_clusters
            
            cex_cluster_all{j}=cex_ref_points_array(idx==j,:);
            cex_cluster_tol{j}=uniquetol(cex_cluster_all{j},tol,'ByRows',true);
            fprintf('In cluster %i, there is/are %i total CEX and %i different ones (tol=%f).\n',j, sum(idx==j),size(cex_cluster_all{j},1),tol);
            %     size(cex_cluster_tol{j},1)
        end
    end
end