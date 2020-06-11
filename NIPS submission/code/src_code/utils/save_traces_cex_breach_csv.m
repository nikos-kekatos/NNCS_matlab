function [completed] = save_traces_cex_breach_csv(data,options)
%save_traces_csv Need to FIX:
%   Some of the traces used for testing are saved in csv.
%   The traces used for testing are separated in good, bad and average. The
%   good and the bad ones are selected and are saved as CSV files so that
%   further analyis via mining can be performed. The columns include
%   number, time stamps, references, u_nn, u_nominal, y_nn, y_nominal
%
% Remark: tested on 20/04/2020 for the quadcopter robot arm which has 1
% ref, 4 u, 12 y.

% data=testing.data;
try
    n=data.no_cex;
catch
    n=7;
end
if ~isfield(data,'REF_cex')
    data.REF_cex=data.REF_cex_breach;
end
    
no_points=length(data.REF_cex)/n;

% missing time
data.time_cex=data.time_cex_breach;
data.U_nn=data.U_NN_cex_breach;
data.Y_nn=data.Y_NN_cex_breach;
data.U=data.U_cex_breach;
data.Y=data.Y_cex_breach;
if ~isfield(options,'csv_filename')
    file_name='quadcopter_csv_cex_breach_';
end
% Note each trace would be saved in a different file.

%  we write the csv files for the "original traces". This requires:
% 1)create a TXT file and choose the columns and the corresponding values,
% 2) first row should be the description and the filename will end up with
% original
% 4) loop through these traces (avoid "for" loop due to time computations
% 5) use fid, fprintf, etc.
% 6)

% open file
fprintf('Creating CSV for original traces. \n');
fprintf('------------------------------ \n\n')
create_csv;


completed = 1;



    function create_csv
        index=n;
        index_start=1;
        
        for i=1:index
            
            filename=strcat(file_name,num2str(i),'.csv');
            fid = fopen(filename,'wt');
            if (fid < 0)
                error('could not open file "myfile.txt"');
            end
            disp(' ')
            fprintf('Started writing the CSV file -- %i.\n',i)
            % need to automate generation of characters
            fprintf(fid,['time, ref, y_nom_1, y_nom_2,y_nom_3,y_nom_4,y_nom_5,' ...
                'y_nom_6, y_nom_7,y_nom_8,y_nom_9,y_nom_10,y_nom_11,y_nom_12,' ...
                'y_nn_1, y_nn_2,y_nn_3,y_nn_4,y_nn_5,y_nn_6,y_nn_7,y_nn_8,' ...
                'y_nn_9, y_nn_10,y_nn_11,y_nn_12,',...
                'u_nn_1, u_nn_2, u_nn_3,u_nn_4,'...
                'u_nom_1,u_nom_2,u_nom_3,u_nom_4' ...
                '\n']);

            % fprintf(fid,'---------------------------------------\n');
            warning off;
            jj=1;
            for j=index_start:index_start+no_points-1
                fprintf(fid,['%.5f, %.5f, %.5f, %.5f, %0.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %0.5f, %.5f,',...
                    '%.5f, %.5f, %.5f, %.5f, %0.5f,%.5f, %.5f, %.5f, %.5f, %0.5f,',...
                    '%.5f, %.5f, %.5f, %.5f, %0.5f,%.5f, %.5f, %.5f, %.5f, %0.5f,%.5f, %0.5f \n'],...
                    data.time_cex(jj),data.REF_cex(j),data.Y(j,1),data.Y(j,2),data.Y(j,3),data.Y(j,4),data.Y(j,5),...
                    data.Y(j,6),data.Y(j,7),data.Y(j,8),data.Y(j,9),data.Y(j,10),data.Y(j,11),data.Y(j,12),...
                    data.Y_nn(j,1),data.Y_nn(j,2),data.Y_nn(j,3),data.Y_nn(j,4),data.Y_nn(j,5),...
                    data.Y_nn(j,6),data.Y_nn(j,7),data.Y_nn(j,8),data.Y(j,9),data.Y_nn(j,10),data.Y_nn(j,11),data.Y_nn(j,12),...
                    data.U(j,1),data.U(j,2),data.U(j,3),data.U(j,4),...
                    data.U_nn(j,1),data.U_nn(j,2),data.U_nn(j,3),data.U_nn(j,4));
                jj=jj+1;
            end
            index_start=index_start+no_points;
            % close the file
            fclose(fid);
            fprintf('Finished writing the CSV file -- %i.\n\n',i)
        end
    end
end

