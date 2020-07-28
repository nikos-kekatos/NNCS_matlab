% 
% Elektromechanische Bremse - SCODE Beispiel Nr. 1
% 
% Skriptfile zur 
%  - Parametrierung v. Streckenmodell und reduzierten Ersatzmodellen
%  - Auslegung der Vorsteuerung
%  - Auslegung der Beobachtervarianten
%  - Einstellen der Reglerparameter
%
% Aufbau
% 1. Modellierung
% 1.a. EMB-Strecken-Parameter
% 1.b. Zustandsdarstellung des linearen Ersatzmodells der Strecke
% 1.c. Zustandsdarstellung der reduzierten Ersatzmodelle (Varianten 1-4)
%
% 2. Flachheitsbasierte Vorsteuerung
% 2.a. Vorsteuerung für Betriebsfall Positionierung
% 2.b. Vorsteuerung für Betriebsfall Kraftregelung
%
% 3. Beobachterentwurf
% 3.a. Entwurf mit linearem Ersatzmodell (Identitätsbeobachter)
% 3.b. Abschnittsweiser Beobachterentwurf mit vereinfachten Modellen
% 3.b.1. Mit Modellvariante 2 (der reduzierten Modelle) für die Positionierung
% 3.b.1.a. Mit Annahme einer Strom- und Winkelmessung
% 3.b.1.b. Mit Annahme einer ausschliesslichen Strommessung
% 3.b.2. Mit Modellvariante 3 (der reduzierten Modelle) für die Kraftregelung
% 3.b.2.a. Mit Annahme einer ausschliesslichen Strommessung
% 3.b.2.b. Mit Strom- und Positionsmessung
%
% 4. Reglerparametrierung

% Autor: CR/AEH1-Bitzer

clc
clear all
close all
%
disp(' '); disp(' ******* Initialization of Simulink-Model for EMB/SCODE-Example No. 1 ******* ')
%% 1. Modellierung
% ----------------
disp(' Modeling and parameterization ... ')
%% 1.a. EMB-Strecken-Parameter
% -----------------------
% Ankerwiderstand DC-Motor [Ohm]
R       = 0.5;
% Motorkonstante DC-Motor [Nm/A]
K       = 0.02;
% Induktivität DC-Motor [H]
L       = 1e-3;
% Spannungsverlust an den Bürsten [V]
Ubrush  = 0.0;
% Trägheit des Rotors [kgm^2]
J       = 1e-5;
% Viskose Reibung des Rotors [Nms/rad]
d_rot   = 0.1;
% Masse der Bremszange [kg]
m       = 0.1;
% Viskose Reibung der Bremszange [Ns/m]
d_trans = 0.1;
% Getriebesteifigkeit [N/m]
c_gear  = 2e+5;
% Radius der Spindel [m]
r2      = 0.05;
% Neigungswinkel [rad]
alpha   = 0.175;
% Getriebeübersetzung [-]
i       = 1/(r2*tan(alpha));
% Federsteifigkeit der Bremsscheibe [N/m]
c_break = 1e6;
% Lose [m]
x0      = 0.05;
%
% Schaltzeitpunkte/Delays für die Logik [s]
t0      = 0.1;
t1      = 2.5e-3;
% (Soll-)Ersatzgröße: Federweg [m] zur Aufbringung der Bremskraft
x_break = 0.0005;
% Abtastdauer [s]
T_abtast = 100e-6;
%
%% 1.b. Zustandsdarstellung des linearen Ersatzmodells der Strecke
%
% Zustandsdarstellung:
%   dx/dt = Ax + Bu
%       y = Cx + Du
%
%   mit x = Vektor der Zustandsgrößen
%       u = Vektor der Eingangsgrößen
%       y = Vektor der Ausgangs(Mess-)größen
%       A = Dynamik-Matrix
%       B = Eingangsmatrix
%       C = Ausgangsmatrix
%       D = Durchgriffsmatrix
%
% Dynamik-Matrix - Fall 1: Positionierung
A = [-R/L -K/L       0              0          0;
      K/J -d_rot/J  -c_gear/(J*i)   0          c_gear/J;
      0    1         0              0          0;
      0    0         c_gear/m      -d_trans/m -i*c_gear/m;
      0    0         0              1          0];
% Dynamik-Matrix - Fall 2: Kraftregelung
A2 = [-R/L -K/L       0              0          0;
       K/J -d_rot/J  -c_gear/(J*i) 0            c_gear/J;
       0    1         0              0          0;
       0    0         c_gear/m      -d_trans/m -i*c_gear/m - c_break/m;
       0    0         0              1          0];
% Eingangsmatrix - Fall 1: Positionierung
B     = [1/L 0 0  0   0]';
% Eingangsmatrix - Fall 2: Kraftregelung
B2    = [1/L 0 0 0 0;
         0   0 0 c_break/m 0]';
% Eingangsmatrix - Darstellung für die Simulation in Simulink 
% in Kombination mit 'Dead-Zone'-Simulink-Block und zum Vergleich mit RBSL-Modell 
B_Sim = [1/L 0 0 0   0;
         0   0 0 1/m 0]';
% Ausgangsmatrix - Fall1: Positionierung
C = [0 0 0 0 1];
% Ausgangsmatrix - Fall 2: Kraftregelung
C2 = [0 0 0 0 1];
% Ausgangsmatrix - Darstellung für die Simulation
C_Sim = eye(5);
% Durchgriffsmatrix - Fall 1: Positionierung
D = [0];
% Durchgriffsmatrix - Fall 2: Kraftregelung
D2 = [0 0];
% Durchgriffsmatrix - Darstellung für die Simulation
D_Sim = [0 0 0 0 0;
         0 0 0 0 0]';
     
%% 1.c. Reduzierte Modelle
%       (verwendet für den Beobachterentwurf)
%
% ... Variante 1:
%     - Drei Zustände: Strom DC-Motor, Drehwinkel der Spindel, Positon der
%                      Bremszange
%     - Bemerkung zur Herleitung: Quasistationaritätsannahmen für die
%       Spindeldrehzahl und die Geschwindigkeit der Bremszange
%     - Bemerkung zur Übereinstimmung mit linearem (Gesamt-)Modell:
%       sehr gute Übereinstimmung
%
% Dynamikmatrix
Ared1 = [-(R/L+K^2/(L*d_rot))  K*c_gear/L/d_rot/i -K*c_gear/L/d_rot;
         K/d_rot              -c_gear/d_rot/i      c_gear/d_rot;
         0                     c_gear/d_trans     -i*c_gear/d_trans];
% Eingangsmatrix
Bred1 = [1/L 0 0;
         0   0 1/d_trans]';
% Ausgangsmatrix
Cred1 = eye(3);
% Durchgriffsmatrix
Dred1 = zeros(3,2);
% (--> Ende Variante 1)
%
% ... Variante 2:
%     - Zwei Zustände: Strom DC-Motor, Position der Bremszange
%     - Bemerkungen:
%        # Ausgehend von Variante 1 wurde bei der Herleitung eine zusätzliche
%          Quasistationaritätsannahme für die Position zu Grunde gelegt,
%          zusätzlich wird ein starres Getriebe angenommen und mit 
%          x = 1/i phi die Position der berechnet.
%        # Das Modell passt sehr gut für die Betriebsphase 'Positionierung',
%          für die Phase 'Kraftregelung' stimmt das Modell nicht mit dem
%          linearen Gesamtmodell überein.
%        # Es wurde nur der Fall 1 'Positionierung' in Simulink umgesetzt
%          (Aufgrund den Annahmen ergibt sich ein großer struktureller
%           Modellunterschied zw. beiden Fällen.).
%
% Hilfsgrößen
a1help2 = -(R/L+K^2/(L*d_rot));
a2help2 = K/d_rot/i;
% Dynamikmatrix
Ared2 = [a1help2 0;
         a2help2 0];
% Eingangsmatrix
Bred2 = [1/L 0;
         0   0];
% Ausgangsmatrix
Cred2 = [1 0; 0 1];
% Durchgriffsmatrix
Dred2 = zeros(2,2);
% (--> Ende Variante 2)
%
% ... Variante 3: 
%     - Zwei Zustände: Strom DC-Motor, Position der Bremszange
%     - Bemerkungen:
%        # Ausgehend von Variante 1 wurde bei der Herleitung eine zusätzliche
%          Quasistationaritätsannahme für den Drehwinkel zu Grunde gelegt.
%        # Das Modell stimmt sehr gut für den Betriebsfall 'Kraftregelung'
%          mit dem linearen Vollmodell überein; keine Übereinstimmung für
%          den Betriebsfall 'Postitionierung'.
%
% Hilfsgrößen
a1help3 = L*c_gear/(L*c_gear + K^2*i);
a2help3 = -(R/L + K^2*i^2/L/d_trans);
a3help3 = K*i/L/d_trans;
a4help3 = K*i/d_trans;
% Dynamikmatrix
Ared3 = [a1help3*a2help3 0;
         a4help3         0];
% Eingangsmatrix
Bred3 = [a1help3*1/L -a1help3*a3help3;
         0            1/d_trans];
% Ausgangsmatrix
Cred3 = eye(2);
% Durchgriffsmatrix
Dred3 = zeros(2,2);
% (--> Ende Variante 3)
%
% ... Variante 4:
%     - Zwei Zustände: Drehwinkel Spindel, Position der Bremszange
%     - Bemerkungen:
%        # Ausgehend von Variante 1 wurde bei der Herleitung eine
%          zusätzliche Quasistationaritätsannahme für den Strom zu Grunde
%          gelegt
%        # Das Modell stimmt nicht mit dem linearen Gesamtmodell überein.
%
% Hilfsgrößen
a1help4 = K/(R/L*d_rot + K^2/(L*d_rot));
a2help4 = K/L*c_gear/d_rot;
a3help4 = c_gear/d_rot;
% Dynamikmatrix
Ared4 = [(-a3help4 + a1help4*a2help4/i)  (-a1help4*a2help4 + a3help4);
         c_gear/d_trans                 -i*c_gear/d_trans];
% Eingangsmatrix
Bred4 = [a1help4/L 0;
         0         1/d_trans];
% Ausgangsmatrix
Cred4 = eye(2);
% Durchgriffsmatrix
Dred4 = zeros(2,2);
% (--> Ende Vairante 4)
%
%
disp(' ... modeling done! ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Flachheitsbasierte Vorsteuerung
% -----------------------------------
disp(' Flatness-based feedforward control ... ')
% 2.a. Vorsteuerung für Betriebsfall Positionierung
%
% ... Flacher Ausgang z = x1
% ... Vorsteuerung    u = Sum_{i=0}^n a(i) z^(i)         mit   y = b_0 z
%      somit          u = 1/b Sum_{i=0}^n a(i) yd^(i)    mit   yd = Sollverlauf
%
% System in Zustandsdarstellung
sys_zf = ss(A,B,C,D);
% Berechnung der Übertragungsfunktion
sys_tf  = tf(sys_zf);
% Koeffizienten des Zähler- und Nennerpolynoms der Übertragungsfunktion
[num,den] = tfdata(sys_tf); 
a = den{1};
b = num{1}(6);
%
% 2.b. Vorsteuerung für Betriebsfall Kraftregelung
% 
% Bemerkung: Entwurf nicht mit Matlab möglich, 
%            siehe Mathematica Files 
%
% {... Ansatz über Übertragungsfunktion funktioniert nicht 
%      (zu grosse Vereinfachung durch Vernachlässigung d. Kennlinie): 
% sys_tf2 = tf(ss(A2,B2,C2,D2));
% [num2,den2] = tfdata(sys_tf2); 
% a2 = den2{1};
% b2 = num2{1}(6);
% %
% a2_DistComp = den2{2};
% b2_DistComp = num2{2};
% ...}
%
disp(' ... feedforward control done! ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Beobachterentwurf
% ---------------------
disp( ' Observer design ... ')
%% 3.a. Entwurf mit linearem Gesamtmodell
disp(' ... identity observer ')
%
% ... Vorgabe der Entwurfsmatrizen
% Dynamikmatrix
A_BeoEntwurf = A; 
% Eingangsmatrix
B_BeoEntwurf = B_Sim(:,1);  
% Messmodell (Ausgangsmatrix)
C_BeoMess = [1 0 0 0 0;
             0 1 0 0 0;
             0 0 1 0 0];       
%
% ... Dimensionierung des Korrekturterms
% Vorgabe der Eigenwerte
lambda = [-1200 -1700 -2000 -2800 -2900];
% Berechnung der Verstärkung
% -> Variante 1 (Eigenwertvorgabe für das Gesamtfehlersystem (wird nicht verwendet!))
SysBeoEntwurf.A = A_BeoEntwurf;
SysBeoEntwurf.B = B_BeoEntwurf;
SysBeoEntwurf.C = C_BeoMess;
[SysBeobachter,L_Beo,OB,rkOB] = ObserverDesign_CLin(SysBeoEntwurf,lambda);
% -> Variante 2 (Eigenwertvorgabe für Untersysteme)
% Eigenwertvorgabe
lambda = [-1200 -15000 -8000 -25000 -30000];
% Korrektur der Strommessung nur auf Strom
L_B1h = place(A_BeoEntwurf(1,1),1,lambda(1,1));
% Korrektur der Winkelmessung auf alle andere Groessen, 
% keine Korrektur mit gemessener Winklgeschw.
L_B2h = place(A_BeoEntwurf(2:5,2:5)',C_BeoMess(3,2:5)',lambda(2:5));
L_Beo = [L_B1h,zeros(1,4);zeros(1,5);0,L_B2h];
% ... Berechnung der Beobachtermatrizen
% Dynamikmatrix
A_Beo1 = A_BeoEntwurf - L_Beo'*C_BeoMess;
% Eingangsmatrix
B_Beo1 = [B_BeoEntwurf, L_Beo'];
% Ausgangsmatrix
C_Beo1 = eye(size(A_Beo1));
% Durchgangsmatrix
[a1 b1] = size(C_Beo1);
[c1 d1] = size(B_Beo1);
D_Beo1 = zeros(a1,d1);
% Anfangsbedingungen
x0_Beo1 = zeros(5,1);
%
%
%% 3.b. Abschnittsweiser Beobachterentwurf mit vereinfachten Modellen
%
% 3.b.1. Mit Modellvariante 2 (der reduzierten Modelle) 
%        für die Positionierung
disp(' ... reduced order observer for case 1 ')
%
% 3.b.1.a. Mit Annahme einer Strom- und Winkelmessung
%
% ... Vorgabe der Systemmatrizen des Entwurfssystems 
% Dynamikmatrix
SysBeoEntwurf_red2_1a.A = Ared2;
% Eingangsmatrix
SysBeoEntwurf_red2_1a.B = Bred2(:,1);
% Messmatrix
SysBeoEntwurf_red2_1a.C = Cred2;
% Eigenwertvorgabe
lambda_red2_1a = [-600 -700];
% Berechnung der Verstärkung und der Systemmatrizen des Beobachters
[SysBeoRed2,Lred2,OBred2,rkOBred2] = ObserverDesign_CLin(SysBeoEntwurf_red2_1a,lambda_red2_1a);
%
%
% 3.b.1.b. Mit Annahme einer ausschliesslichen Strommessung
%
% Bemerkung: Modell für beide Zustände nicht beobachtbar,
%            daher Beobachter nur für den Strom, 
%            die Position wird durch Integration des Stroms berechnet
%
% ... Vorgabe der Systemmatrizen des Entwurfssystems
% Dynamikmatrix
SysBeoEntwurf_red2_1b.A = Ared2(1,1);
% Eingangsmatrix
SysBeoEntwurf_red2_1b.B = Bred2(1,1);
% Messgröße
SysBeoEntwurf_red2_1b.C = 1;
% Eigenwertvorgabe
lambda_red2_1b = -600;
% Berechnung der Verstärkung und der Systemmatrizen des Beobachters
[SysBeoRed2_1b,Lred2_1b,OBred2_1b,rkOBred2_1b] = ObserverDesign_CLin(SysBeoEntwurf_red2_1b,lambda_red2_1b);
% Erweiterung der Systemmatrizen zur zusätzlichen Integration der Position
SysBeoRed2_1b.A = [SysBeoRed2_1b.A 0; Ared2(2,:)];
SysBeoRed2_1b.B = [SysBeoRed2_1b.B; zeros(1,2)];
SysBeoRed2_1b.C = eye(2);
%
%
% 3.b.2. Mit Modellvariante 3 (der reduzierten Modelle)
%        für die Kraftregelung
disp(' ... reduced order observer for case 2 ')
%
% ... Reduziertes Modell der Variante 3 -> Koordinatenverschiebung in den Arbeitpunkt
% Dynamikmatrix
SysBeoEntwRed3apV1.A = [a1help3*a2help3  a1help3*a3help3*c_break; 
                        a4help3         -c_break/d_trans];
% Eingangsmatrix
SysBeoEntwRed3apV1.B = Bred3(:,1);
%
%
% 3.b.2.a. Mit Annahme einer ausschliesslichen Strommessung
%
% Messmatrix (Ausgangsmatrix)
SysBeoEntwRed3apV1.C = [1 0];
% Eigenwertvorgabe
lambda_red3 = [-3e7 -1e7];
% Berechnung der Verstärkung und der Systemmmatrizen des Beobachters
[SysBeoRed3apV1,LRed3apV1,OBRed3apV1,rkOBRed3V1] = ObserverDesign_CLin(SysBeoEntwRed3apV1,lambda_red3);
%
% 
% 3.b.2.b. Mit Strom- und Positionsmessung
%
% ... Vorgabe der Systemmatrizen des Entwurfsmodells
% Dynamikmatrix
SysBeoEntwRed3apV2.A = SysBeoEntwRed3apV1.A;
% Eingangsmatrix
SysBeoEntwRed3apV2.B = SysBeoEntwRed3apV1.B; 
% Ausgangsmatrix
SysBeoEntwRed3apV2.C = eye(2);
% Eigenwertvorgabe
lambda_red3 = [-3e7 -4e7];
% Berechnung der Verstärkung und der Systemmatrizen des Beobachters
[SysBeoRed3apV2,LRed3apV2,OBRed3apV2,rkOBRed3V2] = ObserverDesign_CLin(SysBeoEntwRed3apV2,lambda_red3);
%
% % ... Entwurf ohne Koordinatenverschiebung um den Arbeitspunkt (wird nicht verwendet!)
% % ... Belegung der Systemmatrizen
% % Dynamikmatrix
% SysBeoEntwurf_red3.A = Ared3;
% % Eingangsmatrix
% SysBeoEntwurf_red3.B = Bred3(:,1);
% % Ausgangsmatrix
% SysBeoEntwurf_red3.C = Cred3;
% % Eigenwertvorgabe
% lambda_red3 = [-600 -700];
% % Berechnung der Verstärkung und der Systemmatrizen des Beobachters
% [SysBeoRed3,Lred3,OBred3,rkOBred3] = ObserverDesign_CLin(SysBeoEntwurf_red2_1a,lambda_red3);
%
disp(' ... observer done! ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Regelung
% ------------
disp(' Feedback control ... ')
%
% Reglerparameter
P_Pos   = 10000;
I_Pos   = 1000;D_Pos   = 0;
P_Kraft = 7e4;
I_Kraft = 1e6;
D_Kraft = 1;
%
disp(' ... feedback control done! ')
save EMB_Variables
disp(' ******* DONE! ************************************************************** ')
