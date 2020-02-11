function display_ranges(data)
%display_ranges Displaying the ranges of REF, U, Y arrays.
%   Part of the preprocessing
disp('')
fprintf('The reference range is %.5f<=ref<=%.5f.\n\n',min(data.REF),max(data.REF));
fprintf('The control range is %.5f<=u<=%.5f.\n\n',min(data.U),max(data.U));
fprintf('The plant output range is %.5f<=y<=%.5f.\n\n',min(data.Y),max(data.Y));

end

