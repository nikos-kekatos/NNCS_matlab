%%Kynematic model Kuka LWR robotic arm
%%Denavit-Hatenberg Parameters
% i  thi  di  ai    alphai
% 1  th1  d1   0     -pi/2  
% 2  th2  0   0     pi/2 
% 3  th3  d2  0     pi/2
% 4  th4  0   0     -pi/2
% 5  th5  d3  0     -pi/2
% 6  th6  0   0     pi/2
% 7  th7  d4   0     0
syms th1 th2 th3 th4 th5 th6 th7 d1 d2 d3 d4;
d1=0.36; d2=0.418; d3=0.4; d4=0.081; %arm architecture (m)


R1z=[cos(th1) -sin(th1) 0 0; sin(th1) cos(th1) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T1z=[1 0 0 0;0 1 0 0;0 0 1 d1;0 0 0 1]; %Translation in z axis
R1x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_0to1=T1z*R1z*R1x;
R2z=[cos(th2) -sin(th2) 0 0; sin(th2) cos(th2) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R2x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_1to2=R2z*R2x;
R3z=[cos(th3) -sin(th3) 0 0; sin(th3) cos(th3) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T3z=[1 0 0 0;0 1 0 0;0 0 1 d2;0 0 0 1]; %Translation in z axis
R3x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_2to3=T3z*R3z*R3x;
R4z=[cos(th4) -sin(th4) 0 0; sin(th4) cos(th4) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R4x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_3to4=R4z*R4x;
R5z=[cos(th5) -sin(th5) 0 0; sin(th5) cos(th5) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T5z=[1 0 0 0;0 1 0 0;0 0 1 d3;0 0 0 1]; %Translation in z axis
R5x=[1 0 0 0;0 cos(-pi/2) -sin(-pi/2) 0;0 sin(-pi/2) cos(-pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_4to5=T5z*R5z*R5x;
R6z=[cos(th6) -sin(th6) 0 0; sin(th6) cos(th6) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
R6x=[1 0 0 0;0 cos(pi/2) -sin(pi/2) 0;0 sin(pi/2) cos(pi/2) 0;0 0 0 1]; %Rotation matrix around x axis
A_5to6=R6z*R6x;
R7z=[cos(th7) -sin(th7) 0 0; sin(th7) cos(th7) 0 0;0 0 1 0;0 0 0 1]; %Rotation matrix around z axis
T7z=[1 0 0 0;0 1 0 0;0 0 1 d4;0 0 0 1]; %Translation in z axis
A_6to7=T7z*R7z;

%A_0to7=A_0to1*A_1to2*A_2to3+A_3to4*A_4to5*A_5to6*A_6to7;

%%Dynamic model Kuka LWR robotic arm

A_0to2=A_0to1*A_1to2;
A_0to3=A_0to2*A_2to3;
A_0to4=A_0to3*A_3to4;
A_0to5=A_0to4*A_4to5;
A_0to6=A_0to5*A_5to6;
A_0to7=A_0to6*A_6to7;

A_matrix=[A_0to1 A_0to2 A_0to3 A_0to4 A_0to5 A_0to6 A_0to7];
th_matrix=[th1 th2 th3 th4 th5 th6 th7];

%links specs

%mass in kg of each link
m1=3.4525; m2=3.4821; m3=4.0562; m4=3.4822; m5=2.1633; m6=2.3466; m7=0.31290;
%Position of the center of mass in the DH framework, units in m
r1=[0; -0.03; 0.12; 0]; 
r2=[3.0000e-04; 0.059; 0.042; 0];
r3=[0; 0.03; 0.13; 0];
r4=[0; 0.067; 0.034; 0];
r5=[1.0000e-04; 0.021; 0.076; 0];
r6=[0; 6.0000e-04; 4.0000e-04; 0];
r7=[0; 0; 0.02; 0];
  

   %Uij Matrixes
   U11=diff(A_0to1,th1); U21=diff(A_0to2,th1); U31=diff(A_0to3,th1);
   U12=zeros(4);         U22=diff(A_0to2,th2); U32=diff(A_0to3,th2);
   U13=zeros(4);         U23=zeros(4);         U33=diff(A_0to3,th3);
   U14=zeros(4);         U24=zeros(4);         U34=zeros(4);         
   U15=zeros(4);         U25=zeros(4);         U35=zeros(4);         
   U16=zeros(4);         U26=zeros(4);         U36=zeros(4);         
   U17=zeros(4);         U27=zeros(4);         U37=zeros(4);         
   
   U41=diff(A_0to4,th1); U51=diff(A_0to5,th1); U61=diff(A_0to6,th1);
   U42=diff(A_0to4,th2); U52=diff(A_0to5,th2); U62=diff(A_0to6,th2);
   U43=diff(A_0to4,th3); U53=diff(A_0to5,th3); U63=diff(A_0to6,th3);
   U44=diff(A_0to4,th4); U54=diff(A_0to5,th4); U64=diff(A_0to6,th4);
   U45=zeros(4);         U55=diff(A_0to5,th5); U65=diff(A_0to6,th5);
   U46=zeros(4);         U56=zeros(4);         U66=diff(A_0to6,th6);
   U47=zeros(4);         U57=zeros(4);         U67=zeros(4);
   
   U71=diff(A_0to7,th1);
   U72=diff(A_0to7,th2);
   U73=diff(A_0to7,th3);
   U74=diff(A_0to7,th4);
   U75=diff(A_0to7,th5);
   U76=diff(A_0to7,th6);
   U77=diff(A_0to7,th7);
  
   %Uijk Matrixes
   
   %U1jk Matrixes
   U111=diff(U11,th1); U121=zeros(4)     ; U131=zeros(4);
   U112=zeros(4)     ; U122=zeros(4)     ; U132=zeros(4);
   U113=zeros(4)     ; U123=zeros(4)     ; U133=zeros(4);
   U114=zeros(4)     ; U124=zeros(4)     ; U134=zeros(4);
   U115=zeros(4)     ; U125=zeros(4)     ; U135=zeros(4);
   U116=zeros(4)     ; U126=zeros(4)     ; U136=zeros(4);
   U117=zeros(4)     ; U127=zeros(4)     ; U137=zeros(4);
   
   U141=zeros(4)     ; U151=zeros(4)     ; U161=zeros(4);
   U142=zeros(4)     ; U152=zeros(4)     ; U162=zeros(4);
   U143=zeros(4)     ; U153=zeros(4)     ; U163=zeros(4);
   U144=zeros(4)     ; U154=zeros(4)     ; U164=zeros(4);
   U145=zeros(4)     ; U155=zeros(4)     ; U165=zeros(4);
   U146=zeros(4)     ; U156=zeros(4)     ; U166=zeros(4);
   U147=zeros(4)     ; U157=zeros(4)     ; U167=zeros(4);
   
   U171=zeros(4);
   U172=zeros(4);
   U173=zeros(4);
   U174=zeros(4);
   U175=zeros(4);
   U176=zeros(4);
   U177=zeros(4);
   
   %U2jk Matrixes
   U211=diff(U21,th1); U221=diff(U22,th1); U231=zeros(4);
   U212=diff(U21,th2); U222=diff(U22,th2); U232=zeros(4);
   U213=zeros(4)     ; U223=zeros(4)     ; U233=zeros(4);
   U214=zeros(4)     ; U224=zeros(4)     ; U234=zeros(4);
   U215=zeros(4)     ; U225=zeros(4)     ; U235=zeros(4);
   U216=zeros(4)     ; U226=zeros(4)     ; U236=zeros(4);
   U217=zeros(4)     ; U227=zeros(4)     ; U237=zeros(4);
   
   U241=zeros(4)     ; U251=zeros(4)     ; U261=zeros(4);
   U242=zeros(4)     ; U252=zeros(4)     ; U262=zeros(4);
   U243=zeros(4)     ; U253=zeros(4)     ; U263=zeros(4);
   U244=zeros(4)     ; U254=zeros(4)     ; U264=zeros(4);
   U245=zeros(4)     ; U255=zeros(4)     ; U265=zeros(4);
   U246=zeros(4)     ; U256=zeros(4)     ; U266=zeros(4);
   U247=zeros(4)     ; U257=zeros(4)     ; U267=zeros(4);
   
   U271=zeros(4);
   U272=zeros(4);
   U273=zeros(4);
   U274=zeros(4);
   U275=zeros(4);
   U276=zeros(4);
   U277=zeros(4);
   
   %U3jk Matrixes
   U311=diff(U31,th1); U321=diff(U32,th1); U331=diff(U33,th1);
   U312=diff(U31,th2); U322=diff(U32,th2); U332=diff(U33,th2);
   U313=diff(U31,th3); U323=diff(U32,th3); U333=diff(U33,th3);
   U314=zeros(4)     ; U324=zeros(4)     ; U334=zeros(4);
   U315=zeros(4)     ; U325=zeros(4)     ; U335=zeros(4);
   U316=zeros(4)     ; U326=zeros(4)     ; U336=zeros(4);
   U317=zeros(4)     ; U327=zeros(4)     ; U337=zeros(4);

   U341=zeros(4)     ; U351=zeros(4)     ; U361=zeros(4);
   U342=zeros(4)     ; U352=zeros(4)     ; U362=zeros(4);
   U343=zeros(4)     ; U353=zeros(4)     ; U363=zeros(4);
   U344=zeros(4)     ; U354=zeros(4)     ; U364=zeros(4);
   U345=zeros(4)     ; U355=zeros(4)     ; U365=zeros(4);
   U346=zeros(4)     ; U356=zeros(4)     ; U366=zeros(4);
   U347=zeros(4)     ; U357=zeros(4)     ; U367=zeros(4);
   
   U371=zeros(4);
   U372=zeros(4);
   U373=zeros(4);
   U374=zeros(4);
   U375=zeros(4);
   U376=zeros(4);
   U377=zeros(4);
   
   %U4jk Matrixes
   U411=diff(U41,th1); U421=diff(U42,th1); U431=diff(U43,th1);
   U412=diff(U41,th2); U422=diff(U42,th2); U432=diff(U43,th2);
   U413=diff(U41,th3); U423=diff(U42,th3); U433=diff(U43,th3);
   U414=diff(U41,th4); U424=diff(U42,th4); U434=diff(U43,th4);
   U415=zeros(4);      U425=zeros(4);      U435=zeros(4);
   U416=zeros(4);      U426=zeros(4);      U436=zeros(4);
   U417=zeros(4);      U427=zeros(4);      U437=zeros(4);
   
   U441=diff(U44,th1); U451=zeros(4);      U461=zeros(4);      
   U442=diff(U44,th2); U452=zeros(4);      U462=zeros(4);      
   U443=diff(U44,th3); U453=zeros(4);      U463=zeros(4);      
   U444=diff(U44,th4); U454=zeros(4);      U464=zeros(4);      
   U445=zeros(4);      U455=zeros(4);      U465=zeros(4);      
   U446=zeros(4);      U456=zeros(4);      U466=zeros(4);      
   U447=zeros(4);      U457=zeros(4);      U467=zeros(4);      
   
   U471=zeros(4);      
   U472=zeros(4);      
   U473=zeros(4);      
   U474=zeros(4);      
   U475=zeros(4);  
   U476=zeros(4);      
   U477=zeros(4);      
   
   %U5jk Matrixes
   U511=diff(U51,th1); U521=diff(U52,th1); U531=diff(U53,th1); 
   U512=diff(U51,th2); U522=diff(U52,th2); U532=diff(U53,th2); 
   U513=diff(U51,th3); U523=diff(U52,th3); U533=diff(U53,th3); 
   U514=diff(U51,th4); U524=diff(U52,th4); U534=diff(U53,th4); 
   U515=diff(U51,th5); U525=diff(U52,th5); U535=diff(U53,th5); 
   U516=zeros(4);      U526=zeros(4);      U536=zeros(4);      
   U517=zeros(4);      U527=zeros(4);      U537=zeros(4);      
   
   U541=diff(U54,th1); U551=diff(U55,th1); U561=zeros(4);  
   U542=diff(U54,th2); U552=diff(U55,th2); U562=zeros(4);
   U543=diff(U54,th3); U553=diff(U55,th3); U563=zeros(4);      
   U544=diff(U54,th4); U554=diff(U55,th4); U564=zeros(4);      
   U545=diff(U54,th5); U555=diff(U55,th5); U565=zeros(4);      
   U546=zeros(4);      U556=zeros(4);      U566=zeros(4);      
   U547=zeros(4);      U557=zeros(4);      U567=zeros(4);      
   
   U571=zeros(4); 
   U572=zeros(4); 
   U573=zeros(4); 
   U574=zeros(4); 
   U575=zeros(4); 
   U576=zeros(4); 
   U577=zeros(4); 
   
   %U6jk Matrixes
   U611=diff(U61,th1); U621=diff(U62,th1); U631=diff(U63,th1); 
   U612=diff(U61,th2); U622=diff(U62,th2); U632=diff(U63,th2); 
   U613=diff(U61,th3); U623=diff(U62,th3); U633=diff(U63,th3); 
   U614=diff(U61,th4); U624=diff(U62,th4); U634=diff(U63,th4); 
   U615=diff(U61,th5); U625=diff(U62,th5); U635=diff(U63,th5); 
   U616=diff(U61,th6); U626=diff(U62,th6); U636=diff(U63,th6); 
   U617=zeros(4);      U627=zeros(4);      U637=zeros(4);
   
   U641=diff(U64,th1); U651=diff(U65,th1); U661=diff(U66,th1); 
   U642=diff(U64,th2); U652=diff(U65,th2); U662=diff(U66,th2);
   U643=diff(U64,th3); U653=diff(U65,th3); U663=diff(U66,th3);
   U644=diff(U64,th4); U654=diff(U65,th4); U664=diff(U66,th4);
   U645=diff(U64,th5); U655=diff(U65,th5); U665=diff(U66,th5);
   U646=diff(U64,th6); U656=diff(U65,th6); U666=diff(U66,th6);
   U647=zeros(4);      U657=zeros(4);      U667=zeros(4);     
    
   U671=zeros(4);
   U672=zeros(4);
   U673=zeros(4);
   U674=zeros(4);
   U675=zeros(4);
   U676=zeros(4);
   U677=zeros(4);
   
   %U7jk Matrixes
   
   U711=diff(U71,th1); U721=diff(U72,th1); U731=diff(U73,th1); 
   U712=diff(U71,th2); U722=diff(U72,th2); U732=diff(U73,th2); 
   U713=diff(U71,th3); U723=diff(U72,th3); U733=diff(U73,th3); 
   U714=diff(U71,th4); U724=diff(U72,th4); U734=diff(U73,th4); 
   U715=diff(U71,th5); U725=diff(U72,th5); U735=diff(U73,th5); 
   U716=diff(U71,th6); U726=diff(U72,th6); U736=diff(U73,th6); 
   U717=diff(U71,th7); U727=diff(U72,th7); U737=diff(U73,th7); 
   
   U741=diff(U74,th1); U751=diff(U75,th1); U761=diff(U76,th1); 
   U742=diff(U74,th2); U752=diff(U75,th2); U762=diff(U76,th2); 
   U743=diff(U74,th3); U753=diff(U75,th3); U763=diff(U76,th3); 
   U744=diff(U74,th4); U754=diff(U75,th4); U764=diff(U76,th4); 
   U745=diff(U74,th5); U755=diff(U75,th5); U765=diff(U76,th5); 
   U746=diff(U74,th6); U756=diff(U75,th6); U766=diff(U76,th6); 
   U747=diff(U74,th7); U757=diff(U75,th7); U767=diff(U76,th7); 
   
   U771=diff(U77,th1); 
   U772=diff(U77,th2); 
   U773=diff(U77,th3); 
   U774=diff(U77,th4); 
   U775=diff(U77,th5); 
   U776=diff(U77,th6); 
   U777=diff(U77,th7); 
   
   %I matrixes
   
   I1=[0.0747 0.0085 0;
      0.0085 0.0574 0;
      0 0 0.0239];
  
  I2=[0.0390 -0.0086 -0.0037;
    -0.0086 0.0279 -6.1633e-05;
    -0.0037 -6.1633e-05 0.0199];

  I3=[0.006052050623697 0.000000262383560 0.000001120384479;
     0.000000262383560 0.005990028254028 -0.001308542301422;
    0.000001120384479 -0.001308542301422 0.001861529721327];
 
  I4=[0.006052050623697 -0.000000262507583 -0.000001120888863;
      -0.000000262507583 0.005990028254028 -0.001308542301422;
     -0.000001120888863 -0.001308542301422 0.001861529721327];

  I5=[0.005775526977146 -0.000000448127278 0.000000782342032;
      -0.000000448127278 0.005348473437925 0.001819965983941;
      0.000000782342032 0.001819965983941 0.002181233531810];

  I6=[0.001882302441080 0.000000003150206 -0.000000072256604;
      0.000000003150206 0.001889339660303 -0.000012066987492;
     -0.000000072256604 -0.000012066987492 0.002133520179065];

  I7=[0.0003390625 0 0;
      0 0.0003390625 0;
      0 0 0.000528125];
  
  %J matrix
  
  I=zeros(4);
  for i=1:7
      I=eval(['I' num2str(i)]);
      m=eval(['m' num2str(i)]);
      r=eval(['r' num2str(i)]);
      eval(['j11' '=((-I(1,1)+I(2,2)+I(3,3))/2)']);
      eval(['j12' '=I(1,2)']);
      eval(['j13' '=I(1,3)']);
      eval(['j14' '=m*r(1)']);
      
      eval(['j21' '=I(1,2)']);
      eval(['j22' '=((I(1,1)-I(2,2)+I(3,3))/2)']);
      eval(['j23' '=I(2,3)']);
      eval(['j24' '=m*r(2)']);
      
      eval(['j31' '=I(1,3)']);
      eval(['j32' '=I(2,3)']);
      eval(['j33' '=((I(1,1)+I(2,2)-I(3,3))/2)']);
      eval(['j34' '=m*r(3)']);
      
      eval(['j41' '=m*r(1)']);
      eval(['j42' '=m*r(2)']);
      eval(['j43' '=m*r(3)']);
      eval(['j44' '=m']);
      
      J=[j11 j12 j13 j14;j21 j22 j23 j24; j31 j32 j33 j34;j41 j42 j43 j44];
      eval(['J' num2str(i) '=J']);
  end
  
  
  %D matrix
  
  Uaux=zeros(4);
for i=1:7
   for j=1:7
       m=max([i j]);
       x=1;
       for k=m:7
       Uaux=eval(['U' num2str(k) num2str(i)]);
       Ud=Uaux';
       A=eval(['U' num2str(k) num2str(j)])*eval(['J' num2str(k)])*Ud;
       x=x+trace(A);
       end
       eval(['d' num2str(i) num2str(j) '=x']);
   end
end

D=[d11 d12 d13 d14 d15 d16 d17;
   d21 d22 d23 d24 d25 d26 d27;
   d31 d32 d33 d34 d35 d36 d37;
   d41 d33 d43 d44 d45 d46 d47;
   d51 d52 d53 d54 d55 d56 d57;
   d61 d62 d63 d64 d65 d66 d67;
   d71 d72 d73 d74 d75 d76 d77];

%Hikm matrix
  for i=1:7
   for k=1:7
     for m=1:7
       j=max([i m k]);
       x=0;
       for l=j:7
       Uaux=eval(['U' num2str(j) num2str(i)]);
       Uh=Uaux';
       x=x+trace(eval(['U' num2str(j) num2str(k) num2str(m)])*eval(['J' num2str(j)])*Uh);
       end
       eval(['h' num2str(i) num2str(k) num2str(m) '=x']);
     end 
   end
  end
  
  
  %Coriolis column matrix
 syms dth1 dth2 dth3 dth4 dth5 dth6 dth7 
 
  for i=1:7
      y=0;
      for k=1:7 
        y=y+x;
        x=0;  
          for m=1:7
          y=x+eval(['h' num2str(i) num2str(k) num2str(m)])*eval(['dth' num2str(k)])*eval(['dth' num2str(m)]);
          end    
      end
      eval(['h' num2str(i) '=y']);
  end
  
  H=[h1;h2;h3;h4;h5;h6;h7];
  
  %Gravity column matrix
  
  g=[0 0 -9.81 0];
  
  for i=1:7
      x=0;
      for j=i:7
      x=x+(-eval(['m' num2str(j)])*g*eval(['U' num2str(j) num2str(i)])*eval(['r' num2str(j)]));  
      end
      eval(['c' num2str(i) '=x']);
  end
   
  C=[c1;c2;c3;c4;c5;c6;c7];
  
  %Final dynamic model
  
  %angular acceleration matrix
  
  syms ddth1 ddth2 ddth3 ddth4 ddth5 ddth6 ddth7
  ddth=[ddth1;ddth2;ddth3;ddth4;ddth5;ddth6;ddth7]; 
  %T=[t1;t2;t3;t4;t5;t6;t7]; %Matrix with torques of each joint
  
  T=D*ddth+H+C;