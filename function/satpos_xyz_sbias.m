function [satpos,satclock] = satpos_xyz_sbias(Time,PRN,eph,index,ps)
% Calculate GPS position
% Inputs: 
%        SOD   = Second of day
%        PRN   = PRN number
%        eph   = ephemaris data
%        index = navigation index
%        ps    = pseudorange
% Outputs:
%       satpos     - Satellite position
%       satclock   - Satellite clock bias (sec)

Sat = find(index == PRN);      % Read selected PRN ephemeride 

%%%% Read Ephemeride %%%%

% Orbit Parameters
a       = eph(Sat,17).^2;      % Semi-major axis                       (m)              
e       = eph(Sat,15);         % Eccentricity
w0      = eph(Sat,24);         % Argument of perigee                   (rad)
W0      = eph(Sat,20);         % Right ascension of ascending node     (rad)
Wdot    = eph(Sat,25);         % Rate of right ascension               (rad/sec)
i0      = eph(Sat,22);         % Inclination                           (rad)
idot    = eph(Sat,26);         % Rate of inclination                   (rad/sec)
M0      = eph(Sat,13);         % Mean anomaly                          (rad)
delta_n = eph(Sat,12);         % Mean motion rate                      (rad/sec)

% Correction coefficients
Cuc     = eph(Sat,14);         % Argument of perigee (cos)             (rad) 
Cus     = eph(Sat,16);         % Argument of perigee (sine)            (rad)
Crc     = eph(Sat,23);         % Orbit radius        (cos)             (m)
Crs     = eph(Sat,11);         % Orbit radius        (sine)            (m)
Cic     = eph(Sat,19);         % Inclination         (cos)             (rad) 
Cis     = eph(Sat,21);         % Inclination         (sine)            (rad)

% Time
Toe     = eph(Sat,18);         % Time of Ephemeris                     (SOW : sec of GPS week)
GPS_week= eph(Sat,28);         % GPS Week
Ttm     = eph(Sat,34);         % Transmission time of message -604800  (SOW : sec of GPS week)
y       = eph(Sat,1);          % Year     
m       = eph(Sat,2);          % Month
d       = eph(Sat,3);          % Day of month

% Clock
T0_bias = eph(Sat,7);          % Clock Bias                            (sec)
T0_drift= eph(Sat,8);          % Clock Drift                           (sec/sec)
T0_drate= eph(Sat,9);          % Clock Drift rate                      (sec/sec^2)
Tgd     = eph(Sat,32);         % Time Group delay                      (sec)

% Status
SV_health   = eph(Sat,31);     % SV Health
SV_accuracy = eph(Sat,30);     % SV Accuracy
L2_P_flag   = eph(Sat,29);     % L2 P data flag
L2_code     = eph(Sat,27);     % Code on L2 channel
IODC        = eph(Sat,33);     % Issue of Data, Clock
IODE        = eph(Sat,10);     % Issue of Data, Ephemeris

% Constant
GM = 3.986004418*10^14;        % Earth's universal gravitational parameter     (m^3/s^2)
We = 7.2921151467*10^-5;       % Earth rotation rate                           (rad/sec)

%%%% Satellite Position Computation %%%%

Y = 2000 + y(1);
MA = m(1);
D = d(1);

% Calculate Julian date
JD  = juliandate(Y,MA,D);

% Calculation of GPS Week
GPSW = fix((JD - 2444244.5)/7);

% Calculation of day of the GPS Week (DOW)
DOW = round(((JD - 2444244.5)/7 - GPSW)*7);
satpos = nan(3,length(Time))';

for ii = 1:length(Time)
    SOD = Time(ii);
% Calculation of second of the GPS Week (SOW)
    SOW = round(((JD - 2444244.5)/7 - GPSW)*7)*(24*60*60) +SOD;

    % Find correct ephemerides
    [y,col] = min(abs(SOW-Toe));                     % Use closest Toe
    %[y,col] = max(find((SOW-Toe)>=0));              % Use last Toe (like GPS receiver do)


    %%%%% Calculate satellite position
    c  = 299792458;
    tr = ps(ii)/c;
    TOS   = SOW-tr;                                           % Expected Time             (SOW : sec of GPS week)

    Tk      = TOS - Toe(col);                                 % Time elaped since Toe     (SOW : sec of GPS week)

    MA       = M0(col) + (sqrt(GM/a(col)^3)+delta_n(col))*Tk;    % Mean anomaly at Tk 

    % Iterative solution for E 
    E_old = MA;
    dE = 1;
    while (dE > 10^-12)
      EA = MA + e(col)*sin(E_old);                                % Eccentric anomaly
      dE = abs(EA-E_old);
      E_old = EA;
    end

    TA = atan2(sqrt(1-e(col)^2)*sin(EA), cos(EA)-e(col));          % True anomaly

    W = W0(col) + (Wdot(col)-We)*Tk - (We*Toe(col));            % Right ascension of ascending node

    % Correction for orbital perturbations
    w = w0(col) + Cuc(col)*cos(2*(w0(col)+TA)) + Cus(col)*sin(2*(w0(col)+TA));                        % Argument of perigee
    r = a(col)*(1-e(col)*cos(EA)) + Crc(col)*cos(2*(w0(col)+TA)) + Crs(col)*sin(2*(w0(col)+TA));       % Radial distance
    i = i0(col) + idot(col)*Tk + Cic(col)*cos(2*(w0(col)+TA)) + Cis(col)*sin(2*(w0(col)+TA));         % Inclination

    satpos_in = [r*cos(TA) r*sin(TA) 0]';                  % Satellite position vector (Earth's center in inertial frame)

    % rotation matrix
    R = [cos(W)*cos(w)-sin(W)*sin(w)*cos(i) -cos(W)*sin(w)-sin(W)*cos(w)*cos(i)  sin(W)*sin(i);
         sin(W)*cos(w)+cos(W)*sin(w)*cos(i) -sin(W)*sin(w)+cos(W)*cos(w)*cos(i) -cos(W)*sin(i);
                   sin(w)*sin(i)                    cos(w)*sin(i)                      cos(i)];

    satpos(ii,:) = (R*satpos_in)';                               % Satellite position vector (ECEF)

    %%%% Clock error computation %%%%
    F       = -4.442807633e-10; % constant        (sec/(meter)1/2)

    % 1. relative correction
    r_c = F*e(col)*sqrt(a(col))*sin(EA);
    % 2. SV clock correction
    t_sv = T0_bias(col) + T0_drift(col)*(Tk) + T0_drate(col)*(Tk^2) + r_c;

    satclock(ii,:) = t_sv-Tgd(col);
    end
end