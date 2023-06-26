function pos_lla = xyz2lla(x,y,z)
% convert earth-centered earth-fixed (ECEF)
% cartesian coordinates to latitude, longitude, and altitude
% Input: 
%        x = ECEF X-coordinate (m)
%        y = ECEF Y-coordinate (m)
%        z = ECEF Z-coordinate (m)
% Output: pos_lla
%        lat    = geodetic latitude(m)
%        lon    = longitude(m)
%        height = height above WGS84 ellipsoid(m)
% WGS84 ellipsoid constants:
a = 6378137;
e = 8.1819190842622e-2;
% calculations:
b   = sqrt(a^2*(1-e^2));
ep  = sqrt((a^2-b^2)/b^2);
p   = sqrt(x.^2+y.^2);
th  = atan2(a*z,b*p);
lon = atan2(y,x);
lat = atan2((z+ep^2.*b.*sin(th).^3),(p-e^2.*a.*cos(th).^3));
N   = a./sqrt(1-e^2.*sin(lat).^2);
height = p./cos(lat)-N;
% return lon in range [0,2*pi)
lon = mod(lon,2*pi);
% correct for numerical instability in altitude near exact poles:
% (after this correction, error is about 2 millimeters, which is about
% the same as the numerical precision of the overall function)
k=abs(x)<1 & abs(y)<1;
lon = (180/pi)*lon; % Radian to degree
lat = (180/pi)*lat; % Radian to degree
height(k) = abs(z(k))-b;
if lat==180;lat=0;end
if lon==180;lon=0;end
pos_lla = [lat,lon,height];
end