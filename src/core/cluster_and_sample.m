function[data_cex_cluster]=cluster_and_sample(data_cex,falsif_pb,options)
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

load('40_falsified_traces.mat')

%1. Keep only references and replace signals by points.
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
no_clusters=floor(no_cex/2);

iteration=1;


fprintf(' This is the %i iteration/loop with a number of %i clusters.\n\n',iteration,no_clusters);
% Evaluate the optimal number of clusters using the silhouette
% clustering evaluation criterion.

E = evalclusters(cex_ref_points_array,'kmeans','silhouette','klist',[1:5])
figure;
plot(E);

optimal_no_clusters=E.OptimalK;
figure;gscatter(cex_ref_points_array(:,1),cex_ref_points_array(:,2),E.OptimalY,'rbgym','xods*')
figure;plot(cex_ref_points_array(:,1),cex_ref_points_array(:,2),'k*','MarkerSize',5);

[idx,C]=kmeans(cex_ref_points_array,optimal_no_clusters);
end
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

end

