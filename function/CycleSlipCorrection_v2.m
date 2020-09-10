function [STEC_new] = CycleSlipCorrection_v2(STECl,Elevation,Time,PRNall)
%% ==== Descriptions ====
% For correct the Cycle slip effect
% Writed by Somkit Sophan; Date: Jan, 2020
% Updated by - Napat; date: Sep, 2020 - add the data missing correction
% STECl         : STEC(Carrier phase)
% Elevation     : Elevation angle
% Time          : Time scal for sampling in second per day
% PRNall        : PRN number form matric as [1 2 3 ..]

STEC_new = nan(size(STECl,1),size(STECl,2));

for PRN = PRNall
    index = Time(~isnan(Time(:,PRN)),PRN);
    T = Time(index,PRN);
    STEC          = STECl(index,PRN);                  
    STEC_ref      = STECl(index,PRN);
    elev          = Elevation(index,PRN);
    gap_bound     = nanstd(diff(STEC));
    if gap_bound <= 1 % min gap 1 TECu
        gap_bound = 1;
    end
    if gap_bound >= 2 % max gap 2 TECu
        gap_bound = 2;
    end
    gap_time   = 3*60*60; % 3 hours
    dif_time   = diff(T);
    time_gap   = find(dif_time>=gap_time, 1); 
    % Split into 2 situations
    %% 1. STEC has not time gap (3 hours)
    if isempty(time_gap)
        % 1.1 connect the missing data
        slip1      = find(isnan(STEC));                                     % Data missing (NaN)
        if ~isempty(slip1)
            for i = 1:length(slip1)                                         % Correct data
                try
                    STEC(slip1(i)) = STEC(slip1(i)-1);          
                catch
                    STEC(slip1(i)) = STEC(slip1(i)+1);
                end
            end
        end
        % 1.2 Cycle slip correction
        dif_STEC   = abs(diff(STEC));
        slip2 = find(abs(dif_STEC)>=gap_bound);                             % Find the Data slip
        slip2 = union(slip2,length(STEC));
        if ~isempty(slip2)
            for ii = 1:length(slip2)-1                                      % Correct the cycle slip
                bound1 = STEC(1:slip2(ii));
                bound2 = STEC(slip2(ii)+1:slip2(ii+1));
                TEC_part = bound1 - (bound1(end)-bound2(1));
                STEC(1:slip2(ii+1)) = [TEC_part;bound2];
            end
        end
    %% 2. STEC has time gap (3 hours)  
    else
        % 2.1 Group TEC from time gap
        time_gap = union(time_gap,0);                                       % Add initial
        time_gap = union(time_gap,length(STEC));                            % Add end
        for iii = 1:length(time_gap)-1
            STEC_g = STEC(time_gap(iii)+1:time_gap(iii+1));                 % group STEC
            % 2.2 connect the missing data
            slip1_g      = find(isnan(STEC_g));                             % Data missing (NaN)
            if ~isempty(slip1_g)
                for i = 1:length(slip1_g)                                   % Correct data
                    try
                        STEC_g(slip1_g(i)) = STEC_g(slip1_g(i)-1);
                    catch
                        STEC_g(slip1_g(i)) = STEC_g(slip1_g(i)+1);
                    end
                end
            end
            % 2.3 Cycle slip correction
            dif_STEC_g   = abs(diff(STEC_g));
            slip2_g = find(abs(dif_STEC_g)>=gap_bound);                     % Find the Data slip
            slip2_g = union(slip2_g,length(STEC_g));
            if ~isempty(slip2_g)
                for ii = 1:length(slip2_g)-1                                % Correct the cycle slip
                    bound1 = STEC_g(1:slip2_g(ii));
                    bound2 = STEC_g(slip2_g(ii)+1:slip2_g(ii+1));
                    TEC_part = bound1 - (bound1(end)-bound2(1));
                    STEC_g(1:slip2_g(ii+1)) = [TEC_part;bound2];
                end
            end
            STEC(time_gap(iii)+1:time_gap(iii+1)) = STEC_g;
        end
    end
    %% Levelling to highest elevation angle
    [~,ref_index] = nanmax(elev);                                            % Find highest elevation angle
    STEC = STEC + (STEC_ref(ref_index)-STEC(ref_index));                     % Levelling the STEC to the STEC at highest elevation angle
    STEC_new(index,PRN) = STEC;
end
