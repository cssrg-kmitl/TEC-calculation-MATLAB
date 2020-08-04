function ROTI = roticalculation(STECl,PRNall)
%{
 ========================================
            ROTI calculation
 ========================================
 Description - Calculate Rate Of TEC Index (ROTI) 
 === input  ====
 STECl - Slant TEC that is calculated by using carrier-phase
 === output ====
 ROTI  - Rate Of TEC Index
%}

for PRN = PRNall
% 1440 mins devide by / windows 5 min
% downsampling STEC to min
STEC_minute     = STECl(1:60:length(STECl),PRN);

% interpolate STEC min
ST = find(~isnan(STEC_minute(:)));
flag = find((diff(ST))>1 & (diff(ST))<=5); % flag nan value
if ~isempty(flag)
    for d = 1:length(flag)
        x = [1,length(STEC_minute(ST(flag(d)):ST(flag(d)+1)))];    % Define start/stop epoch
        v = [STEC_minute(ST(flag(d))),STEC_minute(ST(flag(d)+1))]; % Define start/stop data
        xq = 1:length(STEC_minute(ST(flag(d)):ST(flag(d)+1)));     % Define interpolated epoch
        STEC_M = interp1(x,v,xq,'linear','extrap');                % Interpolation 1D
        
        STEC_minute(ST(flag(d)):ST(flag(d)+1)) = STEC_M;
    end
end


% Calculate different STEC
ROT            = diff(STEC_minute);
ROT(length(ROT)+1)= NaN;
% window 5 min
window          = 5;
time_rot = 1;
% Calculate standard deviation
for ind = 1 : window : length(ROT)- (window - 1)
    ROT_Cal = ROT(ind:ind+(window-1));
    ROTI(time_rot,PRN) = nanstd(ROT_Cal);
    time_rot = time_rot +1;
end
% clear ST flag
end
% end
