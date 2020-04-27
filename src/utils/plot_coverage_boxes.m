function  [testing]=plot_coverage_boxes(options,flag,testing)
%plot_coverage_boxes Plots the boxes produced for coverage analysis
%   The input is the structure that contains the boxes described by their
%   center, min, max and the resolution. The same resolution term is
%   considered for all dimensions. Currently, it only works for 2D. We wan
%   to extend it for 3D.
n=numel(options.coverage.cells);
Min=[];Max=[];centers=[];random_values=[];
resolution=options.coverage.delta_resolution;
if nargin==1
    flag=0;
end
for i=1:n
    centers=[centers, options.coverage.cells{i}.centers];
    Min=[Min,options.coverage.cells{i}.min];
    Max=[Max,options.coverage.cells{i}.max];
    Dom{i}=combvec([Min(1,i);Max(1,i)]',[Min(2,i);Max(2,i)]');
    Dom_sorted{i}=[Dom{i},Dom{i}(:,1)];
    Dom_sorted{i}(:,[4,3])=Dom_sorted{i}(:,[3,4]);
end
for i=1:options.coverage.no_traces_ref
    random_values=[random_values, options.coverage.cells{i}.random_value];
end
if options.coverage.m==2
    if nargin==2
        figure;
        hold on;
        plot(random_values(1,:),random_values(2,:),'gx');
        if ~flag
            plot(centers(1,:),centers(2,:),'r*');
        end
        for i=1:n
            % patch is an altenative
            %             fill(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),'y');
            plot(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),'k-.o');
        end
        xlabel('reference')
        ylabel('reference')
        if ~flag
            legend('random points','test points')
        else
            legend('random points')
        end
    elseif nargin==3
        
        testing.errors_mse=[];testing.errors_mae=[];
        for i=1:n
            testing.errors_mse=[testing.errors_mse;testing.errors_coverage{i}.mse.y];
            testing.errors_mae=[testing.errors_mae;testing.errors_coverage{i}.mae.y];
        end
        errors=[testing.errors_mse,testing.errors_mae];
        for j=1:size(errors,2)
            figure;
            hold on;
            [errors_sorted,ind]=sort(errors(:,j));
            % potential candidates worst 10%
            if j==1
              testing.errors_mse_index=ind(ceil(0.9*n):n);  
            elseif j==2
              testing.errors_mae_index=ind(ceil(0.9*n):n); 
            end
            % break into 25% percentile and 75%
            % assign low values -> 0 to smaller (black)
            % assign average -> 1
            % assign high ->2 (white)
            error_color=2*ones(1,length(ind));
            error_color(ind<0.25*n)=1;
            error_color(ind>0.75*n)=3;
            %         error_color(0.25*n<=ind<=0.75*n)=2;
            
            %     colorstring = 'kbgry';
            colorspec = {[0.9 0.9 0.9]; %[0.8 0.8 0.8];
                [0.6 0.6 0.6]; ...%[0.4 0.4 0.4];
                [0.2 0.2 0.2]};
            i1=find(error_color==1, 1 );
            i2=find(error_color==2, 1 );
            i3=find(error_color==3, 1 );
            for i=1:n
                % patch is an altenative
                if i==i1
                    p_11=fill(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),colorspec{error_color(i)});
                elseif i==i2
                    p_12=fill(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),colorspec{error_color(i)});
                elseif i==i3
                    p_13=fill(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),colorspec{error_color(i)});
                else
                    fill(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),colorspec{error_color(i)});
                end
                p2=plot(Dom_sorted{i}(1,:),Dom_sorted{i}(2,:),'k-.o');
            end
            p3=plot(random_values(1,:),random_values(2,:),'gx','DisplayName','cos(3x)');
            
            %colormap(jet(256));
            %colorbar;
            p4=plot(centers(1,:),centers(2,:),'r*');
            xlabel('reference')
            ylabel('reference')
            if j==1
                legend([p3,p4,p_11,p_12,p_13],{'random points','test points','Small MSE','Average','Large MSE'})
                title('Using MSE error')
            elseif j==2
                legend([p3,p4,p_11,p_12,p_13],{'random points','test points','Small MAE','Average','Large MAE'})
                title('Using MAE error')
            end
        end
    end
else
    warning('Only 2D plotting is supported')
end
end

