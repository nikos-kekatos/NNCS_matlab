function display_ranges(data)
%display_ranges Displaying the ranges of REF, U, Y arrays.
%   Part of the preprocessing
disp(' ')
for i=1:size(data.REF,2)
    fprintf('The reference range is %.5f<=ref%i<=%.5f.\n\n',min(data.REF(:,i)),i,max(data.REF(:,i)));
end
for i=1:size(data.U,2)
    fprintf('The control range is %.5f<=u%i<=%.5f.\n\n',min(data.U(:,i)),i,max(data.U(:,i)));
end
for i=1:size(data.Y,2)
    fprintf('The plant output range is %.5f<=y%i<=%.5f.\n\n',min(data.Y(:,i)),i,max(data.Y(:,i)));
end
end

