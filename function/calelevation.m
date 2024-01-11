function [elev,azi] = calelevation(satpos,xyz)
% Calculate elevation angle from satellite
% Inputs: 
%        satpos = Satellite position
%        xyz    = user position
% Outputs:
%       elevation_angle - Elevation angle
%       azi             - Azimute

user_lla     = xyz2lla(xyz(1),xyz(2),xyz(3));                    % USER Lat Long Height
xyz_lla      = xyz2lla(satpos(1,:),satpos(2,:),satpos(3,:));     % Sate Lat Long Height
Lat = user_lla(1);
Lon = user_lla(2);
Lat_s = xyz_lla(1);
Lon_s = xyz_lla(2);
R = [-sind(Lon)                cosd(Lon)                0;...
     -sind(Lat)*cosd(Lon) -sind(Lat)*sind(Lon)  cosd(Lat);...
     cosd(Lat)*cosd(Lon)   cosd(Lat)*sind(Lon)  sind(Lat)];
Rs = [satpos(1,:)-xyz(1);satpos(2,:)-xyz(2);satpos(3,:)-xyz(3)];
RL = (R*Rs)';
Xl = RL(:,1);
Yl = RL(:,2);
Zl = RL(:,3);
elev = atan2(Zl,sqrt(Xl.^2+Yl.^2))*180/pi;
azi = atan2(cos(Lat_s) .* sin(Lon_s-Lon),...
           cos(Lat) .* sin(Lat_s) - sin(Lat) .* cos(Lat_s) .* cos(Lon_s-Lon));
end