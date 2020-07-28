function [sys,x0,str,ts,simStateCompliance] = diabetic(t,y,u,flag)

switch flag,
    
    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0,
        [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes();
        
        %%%%%%%%%%%%%%%
        % Derivatives %
        %%%%%%%%%%%%%%%
    case 1,
        sys=mdlDerivatives(t,y,u);
        
        %%%%%%%%%%
        % Update %
        %%%%%%%%%%
    case 2,
        sys=mdlUpdate(t,y,u);
        
        %%%%%%%%%%%
        % Outputs %
        %%%%%%%%%%%
    case 3,
        sys=mdlOutputs(t,y,u);
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % GetTimeOfNextVarHit %
        %%%%%%%%%%%%%%%%%%%%%%%
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,y,u);
        
        %%%%%%%%%%%%%
        % Terminate %
        %%%%%%%%%%%%%
    case 9,
        sys=mdlTerminate(t,y,u);
        
        %%%%%%%%%%%%%%%%%%%%
        % Unexpected flags %
        %%%%%%%%%%%%%%%%%%%%
    otherwise
        DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
        
end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes()

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 6;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);
%
% initialize the initial conditions
% SS for insulin injection of 2.0.
%x0 = [112.4400   22.2230   22.2220   11.1110   11.1110  166.6700]';
% SS for insulin injection of 3.0.
x0 = [ 76.2159   33.3333   33.3333   16.6667   16.6667  250.0000]';

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%==========================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,y,u)
%
% Model source:
% R. Palma and T.F. Edgar, Toward Patient Specific Insulin Therapy: A Novel
%    Insulin Bolus Calculator.  In Proceedings Texas Wisconsin California Control
%    Consortium, Austin, TX, Feb. 7-8, 2011.
%
% Expanded Bergman Minimal model to include meals and insulin
% Parameters for an insulin dependent type-I diabetic

% Inputs (2):
% Insulin infusion rate
ui = u(1);               % micro-U/min

% meal disturbance
d = u(2);

% States (6):
% In non-diabetic patients, the body maintains the blood glucose level at a
%   range between about 3.6 and 5.8 mmol/L (64.8 and 104.4 mg/dL).
g = y(1,1);               % blood glucose (mg/dl)
x = y(2,1);               % remote insulin (micro-u/ml)
i = y(3,1);               % insulin (micro-u/ml)
q1 = y(4,1);
q2 = y(5,1);
g_gut = y(6,1);           % gut blood glucose (mg/dl)

% Parameters:
gb    = 291;             % Basal Blood Glucose (mg/dL)
p1    = 3.17e-2;         % 1/min
p2    = 1.23e-2;         % 1/min
si    = 2.9e-2;          % 1/min * (mL/micro-U)
ke    = 9.0e-2;          % 1/min
kabs  = 1.2e-2;          % 1/min
kemp  = 1.8e-1;          % 1/min
f     = 8.00e-1;         % L
vi    = 12.0;            % L
vg    = 12.0;            % L

% Compute ydot:
sys(1,1) = -p1*(g-gb) - si*x*g + ...
    f*kabs/vg * g_gut + f/vg * d;  % glucose dynamics
sys(2,1) =  p2*(i-x);             % remote insulin compartment dynamics
sys(3,1) = -ke*i + ui;            % insulin dynamics
sys(4,1) = ui - kemp * q1;
sys(5,1) = -kemp*(q2-q1);
sys(6,1) = kemp*q2 - kabs*g_gut;

% convert from minutes to hours
sys = sys*60;
% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,y,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,y,u)

y1 = y(1);

sys = [y1];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,y,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,y,u)

sys = [];

% end mdlTerminate
