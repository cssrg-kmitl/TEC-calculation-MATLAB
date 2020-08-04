function STEC_adj = windowshiftTEC(STECl,STECp)
% Window Shift TEC
% Inputs: 
%         STECp   = STEC calculated from code range
%         STECl   = STEC calculated from carrier phase
% Outputs:
%       STEC_adj  = STEC levelling

STEC_adj        = nan(86400,32);
for LP = 1:32
    [val,~] = find(~isnan(STECl(:,LP)));
    zz = find(diff(val)>=10800); %3hr*3600
    if isempty(zz)
        STEC_adj(:,LP) = STECl(:,LP)+ ones(size(STECl(:,LP)))...
          *diag(nanmean(STECp(:,LP)-STECl(:,LP)));
        continue
    end
    
    for wd = 1:length(zz)             
        if val(zz(wd)) <=82800
            wind(wd) = val(zz(wd))+3600;
        end
    end
    wind(wd+1) = length(STECl);

    for SW = 1:length(wind)
        if SW == 1
            STEC_adj(1:wind(SW),LP)=STECl(1:wind(SW),LP) ...
            + ones(size(STECl(1:wind(SW),LP)))...
            *diag(nanmean(STECp(1:wind(SW),LP)...
            -STECl(1:wind(SW),LP)));
        
        else
            STEC_adj(wind(SW-1):wind(SW),LP)=STECl(wind(SW-1):wind(SW),LP) ...
            + ones(size(STECl(wind(SW-1):wind(SW),LP)))...
            *diag(nanmean(STECp(wind(SW-1):wind(SW),LP)...
            -STECl(wind(SW-1):wind(SW),LP)));
        end     
    end
    clear wind
end
end