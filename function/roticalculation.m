function ROTI_sec = roticalculation(STECl,PRNall)
%{
 ========================================
            ROTI calculation (calculate every second)
 ========================================
 
 Description - Calculate Rate Of TEC Index (ROTI) 
 === input  ====
 STECl - Slant TEC that is calculated by using carrier-phase
 === output ====
 ROTI  - Rate Of TEC Index
%}
ROTI_sec = nan(size(STECl));
for PRN = PRNall
    % 1440 mins devide by / windows 5 min
    STEC_sec = STECl(:,PRN);  
    ST = find(~isnan(STEC_sec(:)));
    flag = find((diff(ST))>1 & (diff(ST))<=300); % flag nan value
    if ~isempty(flag)
        for d = 1:length(flag)
            x = [1,length(STEC_sec(ST(flag(d)):ST(flag(d)+1)))];    % Define start/stop epoch
            v = [STEC_sec(ST(flag(d))),STEC_sec(ST(flag(d)+1))];    % Define start/stop data
            xq = 1:length(STEC_sec(ST(flag(d)):ST(flag(d)+1)));     % Define interpolated epoch
            STEC_M = interp1(x,v,xq,'linear','extrap');             % Interpolation 1D
        
            STEC_sec(ST(flag(d)):ST(flag(d)+1)) = STEC_M;
        end
    end
    
    % downsampling STEC to min
    for T = 300:length(STEC_sec) % 5 min
        if isnan(STEC_sec(T))
            ROTI_sec(T,PRN) = nan;
        else
            STEC_min = STEC_sec(T-299:60:T);
            % Calculate different STEC
            ROT            = diff(STEC_min);
            ROT(length(ROT)+1)= NaN;
            % Calculate standard deviation
            ROTI_sec(T,PRN) = nanstd(ROT);
        end
    end
end
