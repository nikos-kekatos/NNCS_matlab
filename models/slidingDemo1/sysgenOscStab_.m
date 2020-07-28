omeg=2*pi*2;
bet=.2;
A=[0  1;  -omeg^2 -2*bet*omeg];
B=[0, omeg^2]';
C=[1 0; 0 1]; D=0;
sysTST=ss(A,B,C,D); sysTST, 
