rng('default') % For reproducibility
m=2;
X = [randn(100,m)*0.75+ones(100,m);
    randn(100,m)*0.5-ones(100,m);
    randn(100,m)*0.75];
[idx,C] = kmeans(X,3);

figure
gscatter(X(:,1),X(:,2),idx,'bgm')
hold on
plot(C(:,1),C(:,2),'kx')
legend('Cluster 1','Cluster 2','Cluster 3','Cluster Centroid')

%%
Xtest = [randn(10,2)*0.75+ones(10,2);
    randn(10,2)*0.5-ones(10,2);
    randn(10,2)*0.75];

[~,idx_test] = pdist2(C,Xtest,'euclidean','Smallest',1);

gscatter(Xtest(:,1),Xtest(:,2),idx_test,'bgm','ooo')
legend('Cluster 1','Cluster 2','Cluster 3','Cluster Centroid', ...
    'Data classified to Cluster 1','Data classified to Cluster 2', ...
    'Data classified to Cluster 3')

%% attempt with 3d -- gscatter does not work in 3d

m=3;
X = [randn(100,m)*0.75+ones(100,m);
    randn(100,m)*0.5-ones(100,m);
    randn(100,m)*0.75];
[idx,C] = kmeans(X,3);

figure
gscatter(X(:,1),X(:,2),X(:,3),idx)%,'bgm')
%%
y=[705.7142857
705.7142857
173.4285714
84.71428571
232.5714286
232.5714286
114.2857143
55.14285714
25.57142857
74.85714286
35.42857143
15.71428571
5.857142857
5.857142857];
group = findgroups(y);
uniqueGroups = unique(group,'stable');

%% we have data
% or data.in and data.out

X=[data.REF,data.Y,data.U];
% columns should be the dimension
[idx,C] = kmeans(X,5);
figure
gscatter(X(:,1),X(:,2),idx,'bgmry')
hold on
plot(C(:,1),C(:,2),'kx')
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster Centroid')
title('Dimensions 1 & 2')
figure
gscatter(X(:,2),X(:,3),idx,'bgmry')
hold on
plot(C(:,2),C(:,3),'kx')
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster Centroid')
title('Dimensions 2 & 3')
figure
gscatter(X(:,1),X(:,3),idx,'bgmry')
hold on
plot(C(:,1),C(:,3),'kx')
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5','Cluster Centroid')
title('Dimensions 1 & 3')
