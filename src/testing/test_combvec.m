function test_combvec

a=1:3;
b=4:6;
combvec([a;b])
combvec([a,b])
combvec(a,b)
multiple(a,b,a)
c={a,b}
combvec(c)
combvec(c{:})
function varargout = multiple(varargin)    
    varargout = combvec(varargin);
return