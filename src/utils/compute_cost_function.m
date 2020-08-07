function [J] = compute_cost_function(ref,u,y,options)
%compute_cost_function It computes the cost of a controller for a given
%time segment.
%   The inputs to this function are the traces ref,u, y (saved as
%   structures with time) and the options. The 'options' is a structure
%   which contains information regarding the controllers, e.g. the Q and
%   the R matrices.
persistent counter
if isempty(counter)
  counter = 0;
end
counter=counter+1;
if counter==1
if isequal(options.y_index_lqr,size(ref.signals.values,2))
    fprintf('The number of ref and y is correct for LQR computation.\n');
else
    warning('The number of ref and y is NOT correct for LQR computation.');
end
end
y_index=options.y_index_lqr;
u_des=options.u_des;
ref_values=ref.signals.values;
u_values=u.signals.values(1:end-1,:);
y_values_all=y.signals.values;
y_values=y_values_all(:,y_index);
Q=options.Q;
R=options.R;
J=((y_values-ref_values)'*Q*(y_values-ref_values)+(u_values-u_des)'*R*(u_values-u_des));
