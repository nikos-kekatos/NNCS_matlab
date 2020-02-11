function [data,options]=preprocessing(data,options)
%remove traces where the error between two traces is less than eps\% for
% all points

if isfield(options,'preprocessing_eps')
    eps=options.preprocessing_eps;
else
    eps=0;
end
in=[data.REF,data.Y]';
%OLD

%{
rows=size(in,1)
cols=size(in,2)
eps=0.01
in_trimmed=[];
duplicate=[];exact=[];
for i=1:cols-1
    for j=i+1:cols
        if in(:,i)==in(:,j)
            exact=[exact;i j];
        end
    diff=in(i)-in(j);
    if abs(diff)<eps*in(i)
        duplicate=[duplicate;j];
    end
    end
end
fprintf('The number of duplicates is %i out of %i.\n',length(duplicate),length(in))
disp('A random example:')
disp('The error between 1st duplicate is')
disp(in(:,duplicate(1))-in(:,duplicate(1)-1))
disp('original')
disp(in(:,duplicate(1)))
disp('duplicate')
disp(in(:,duplicate(1)-1))
in_trimmed=in;
in_trimmed(:,duplicate)=[];
%}
if  options.preprocessing_eps==0
%     [in_trimmed,index1,index2]=unique(in','rows','stable');
    [~,index,index2]=unique(in','rows');
    in_trimmed=in(:,sort(index));
    s='exact';
else
    [~,index]=uniquetol(in',eps,'ByRows',true);
    in_trimmed=in(:,sort(index));
%     in_trimmed=in_trimmed';
    s='approximate';
end
fprintf('The number of %s duplicates is %i out of %i.\n',s,length(in)-length(in_trimmed),length(in))
disp('')
fprintf('We keep %i values out of %i.\n',length(in_trimmed),length(in))
% index=sort(index);
data.REF_new=in_trimmed(1,:)';
data.Y_new=in_trimmed(2,:)';
data.U_new=data.U(sort(index));

if options.plotting_sim
    nn=1:1000;
    figure;plot(nn,data.REF(nn),'b--',nn,data.Y(nn),'rx')
    xlabel('time (s)')
    ylabel('angle (rad)')
    legend('ref','y')
    title('Simulation before preprocessing (first 1000 points)'); 
    figure;plot(nn,data.REF_new(nn),'b--',nn,data.Y_new(nn),'rx');
    xlabel('time (s)')
    ylabel('angle (rad)')
    legend('ref','y')
    title('Simulation after preprocessing (first 1000 points)');
end