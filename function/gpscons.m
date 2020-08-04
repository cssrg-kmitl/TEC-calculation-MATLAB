% =========== GPS Constant ================================
f1  = 1575.42*10^6;                     %   f1 = 1575.42 MHz (L1)
f2  = 1227.60*10^6;                     %   f2 = 1227.60 MHz (L2)
we = 7.2921151467e-5;                   %   Earth rotation rate (rad/sec)
GM = 3.986004418*10^14;                 %   Earth's universal gravitational parameter (m^3/s^2)
c  = 299792458;                         %   light speed = 299792458 m/s
omega_e = 7.2921151467e-5;              %   Earth's rotation rate(rad/sec)
lambda1 = 299792458/(1575.42*10^6);     %   wave length of f1 c/f1
lambda2 = 299792458/(1227.60*10^6);     %   wave length of f2 c/f2
k = 9.5196;                             %   coefficient of f1 and f2 gps
A = 40.3;                               %   TEC to ionodelay conversion coefficient
Re = 6371.009*10^3;                     %   The mean radius of the Earth (6371.009 km)
h  = 350*10^3;                          %   Ionospheric height for mapping function (350 km.)
elev_mask   = 15;                       %   Mask elevation angle (Can change)
center_E = [0 0 0];                     %   Center of Earth
