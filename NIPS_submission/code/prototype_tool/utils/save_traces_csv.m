function [completed] = save_traces_csv(testing,options)
%save_traces_csv Some of the traces used for testing are saved in csv.
%   The traces used for testing are separated in good, bad and average. The
%   good and the bad ones are selected and are saved as CSV files so that
%   further analyis via mining can be performed. The columns include
%   number, time stamps, references, u_nn, u_nominal, y_nn, y_nominal
%
% Remark: tested on 10/04/2020 for the single robot arm which has 1 ref, 1
% u, 1 y.

data=testing.data;
n=length(data.time); % total traces--alternative options.no_traces,
no_points=length(data.time{1});
mse_errors_all=testing.errors_mse;
[~,ind]=sort(mse_errors_all);
% mse_errors_min_index=mse_errors_all_sorted(
for i_ind=1:(floor(0.25*n))
    mse_min_index(i_ind)=(find(ind==i_ind));
end
ix=1
for i_ind=ceil(0.75*n):n
    mse_max_index(ix)=(find(ind==i_ind));
    ix=ix+1;
end

if ~isfield(options,'csv_filename')
    file_name='robot_arm_csv_';
end
% Note each trace would be saved in a different file.

% first we write the csv files for the "good traces". This requires:
% 1)create a TXT file and choose the columns and the corresponding values,
% 2) first row should be the description and the good or bad would be in
% the filename along with a number.
% 3) finding the indexes of these "good" traces
% 4) loop through these traces (avoid "for" loop due to time computations
% 5) use fid, fprintf, etc.
% 6)

% open file
fprintf('Creating CSV for good traces. \n');
fprintf('------------------------------ \n\n')
flag='minimum';
create_csv;

fprintf('Creating CSV for good traces. \n');
fprintf('------------------------------ \n\n')
flag='maximum';
create_csv;
completed = 1;



    function create_csv
        if strcmp(flag,'minimum')
            name_identifier='good_traces_';
            index=mse_min_index;
        elseif strcmp(flag,'maximum')
            name_identifier='bad_traces_';
            index=mse_max_index;
        end
        for i=1:length(index)
            
            filename=strcat(file_name,name_identifier,num2str(i),'.csv');
            fid = fopen(filename,'wt');
            if (fid < 0)
                error('could not open file "myfile.txt"');
            end
            disp(' ')
            fprintf('Started writing the CSV file -- %i.\n',i)
            fprintf(fid,'No, time, ref, y_nom, y_nn, u_nom, u_nn\n');
            % fprintf(fid,'---------------------------------------\n');
            warning off;
            for j=1:no_points
                fprintf(fid,'%i, %.5f, %.5f, %.5f, %.5f, %0.5f, %.5f \n',j, data.time{index(i)}(j),data.REF_test{index(i)}(j),...
                    data.U_test{index(i)}(j),data.U_NN_test{index(i)}(j),data.Y_test{index(i)}(j),data.Y_NN_test{index(i)}(j));
            end
            
            % close the file
            fclose(fid);
            fprintf('Finished writing the CSV file -- %i.\n\n',i)
        end
    end
end

