function [STEC_new] = CycleSlipCorrection(STECl,Elevation,Sample,PRNall,Gap_Miss,Gap_orbitCycle,Delta_cycle,Cut_nMiss)
%% ==== Descriptions ====
% [STEC_new] = CycleSlipCorrection(STECl,Elevation,Sample,PRNall,Gap_Miss,Gap_orbitCycle,Delta_cycle,Cut_nMiss)
% Writed by Somkit Sophan; Date: Jan, 2019.
% STECl         : STEC(Carrier phase)
% Elevation     : Elevation angle
% Sample        : Time scal for sampling in second per day
% PRNall        : PRN number form matric as [1 2 3 ..]
% Gap_Miss      : Searching the signal missing in Gap (Minute of day)
% Gap_obitCycle : Searching the orbit cycle in Gap (Minute of day)
% Delta_cycle   : the Gap checking of cycle slip (Integer)
% Cut_nMiss     : the cutting amount of missing signal (Integer)

%% ==== Determine ====
Sampling_s = 86400; % Sampling 1 second of day
STEC =  STECl;
STEC(1,:) = NaN;
STEC_temp = STEC;
STEC_new = STEC;

%% ==== Signal correction each PRN: ====
Temp_miss = (Sampling_s/Sample)/((Sampling_s/Sample)/((60/Sample)*Gap_Miss));
Temp_orbitCycle = (Sampling_s/Sample)/((Sampling_s/Sample)/((60/Sample)*Gap_orbitCycle));

for PRN = 1:32
    Index_Miss = find(~isnan(STEC_temp(:,PRN)));
    Comp_Miss = ((Index_Miss(2:end)-Index_Miss(1:end-1)) > 1).*...
        ((Index_Miss(2:end)-Index_Miss(1:end-1)) < Temp_miss);  % Checking the missing signal
    N_Miss = find(Comp_Miss); % finding the missing signal position
    if ~isempty(Comp_Miss)&& length(N_Miss)< Cut_nMiss
        Num_Miss = sum(Comp_Miss); % Counting the missing signal point
        % %         nLoss_begin = Index_loss(N_loss);   % Point of missing signal begining
        Index_MissGap = Index_Miss(N_Miss+1) - Index_Miss(N_Miss)-1;    % Point of missing signal ending
        for p = 1:Num_Miss
            Index_begin = Index_Miss(N_Miss(p)); % Begining point of missing signal
            % ==== missing signal correction
            STEC_temp(Index_begin:Index_begin+Index_MissGap(p)+1,PRN) = ...
                linspace(STEC_temp(Index_begin,PRN),STEC_temp(Index_begin + Index_MissGap(p) +1,PRN),Index_MissGap(p)+2)';
        end
        
        Index_cycle = find(~isnan(STEC_temp(:,PRN)));
        Comp_orbitCycle = ((Index_cycle(2:end)-Index_cycle(1:end-1)) > Temp_miss).*...
            ((Index_cycle(2:end)-Index_cycle(1:end-1)) < Temp_orbitCycle);   % Checking the orbit cycle
        if ~isempty(Comp_orbitCycle)
            N_overCycle = find(Comp_orbitCycle); % finding the orbit cycle position
            Num_overCycle = sum(Comp_orbitCycle); % Counting the missing signal point
            nCycle_end = [Index_cycle(N_overCycle); Index_cycle(end)];  % Point of orbit cycle ending
            Index_overGap = Index_cycle(N_overCycle+1) - Index_cycle(N_overCycle)-1;
            nCycle_begin = [Index_cycle(1); Index_cycle(N_overCycle)+Index_overGap+1]; % Point of orbit cycle begining
            for n_cycle = 1:Num_overCycle+1
                [~,nMax] = max(Elevation(nCycle_begin(n_cycle):nCycle_end(n_cycle),PRN)); % finding the maximum elevation angle point
                nMax_elev = nCycle_begin(n_cycle) + nMax -1;
                Index_LS = find(~isnan(STEC(nCycle_begin(n_cycle):nCycle_end(n_cycle),PRN)));
                Comp_LS = ((Index_LS(2:end)-Index_LS(1:end-1)) > 1).*...
                    ((Index_LS(2:end)-Index_LS(1:end-1)) < Temp_miss);  % finding the Missing & cycle slip (MS)
                N_MS = find(Comp_LS); % Point of Missing & cycle slip
                for n_slip = 1:length(N_MS)
                    nSlip_begin = nCycle_begin(n_cycle) + Index_LS(N_MS) - 1;   % Point of cycle slip begining
                    nSlip_end = nCycle_begin(n_cycle) + Index_LS(N_MS+1) - 1;   % Point of cycle slip ending
                    Deltal_slip = abs(STEC(nSlip_end,PRN) - STEC(nSlip_begin,PRN));
                    % ==== Missing signal & Cycle slip correction
                    if (nMax_elev > nSlip_begin(n_slip)) && (STEC(nSlip_begin(n_slip),PRN) > STEC(nSlip_end(n_slip),PRN))
                        STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) = ...
                            STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) - Deltal_slip((n_slip));
                    elseif (nMax_elev > nSlip_begin(n_slip)) && (STEC(nSlip_begin(n_slip),PRN) < STEC(nSlip_end(n_slip),PRN))
                        STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) = ...
                            STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) + Deltal_slip((n_slip));
                    elseif (nMax_elev < nSlip_begin(n_slip)) && (STEC(nSlip_begin(n_slip),PRN) > STEC(nSlip_end(n_slip),PRN))
                        STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) = ...
                            STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) + Deltal_slip((n_slip));
                    elseif (nMax_elev < nSlip_begin(n_slip)) && (STEC(nSlip_begin(n_slip),PRN) < STEC(nSlip_end(n_slip),PRN))
                        STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) = ...
                            STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) - Deltal_slip((n_slip));
                    end
                end
                
                Delta_stec = STEC_new(nCycle_begin(n_cycle)+1:nCycle_end(n_cycle),PRN) -...
                    STEC_new(nCycle_begin(n_cycle):nCycle_end(n_cycle)-1,PRN);
                Index_slip = find(abs(Delta_stec)> Delta_cycle);
                nSlip_begin = nCycle_begin(n_cycle) + Index_slip - 1;   % Point of cycle slip begining
                nSlip_end = nCycle_begin(n_cycle) + Index_slip;   % Point of cycle slip ending
                Delta_slip = abs(STEC_new(nSlip_end,PRN) - STEC_new(nSlip_begin,PRN));
                % ==== Cycle slip correction
                for n_slip = 1:length(Index_slip)
                    if (nMax_elev > nSlip_begin(n_slip)) && (STEC_new(nSlip_begin(n_slip),PRN) > STEC_new(nSlip_end(n_slip),PRN))
                        STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) = ...
                            STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) - Delta_slip((n_slip));
                    elseif (nMax_elev > nSlip_begin(n_slip)) && (STEC_new(nSlip_begin(n_slip),PRN) < STEC_new(nSlip_end(n_slip),PRN))
                        STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) = ...
                            STEC_new(nCycle_begin(n_cycle):nSlip_begin(n_slip),PRN) + Delta_slip((n_slip));
                    elseif (nMax_elev < nSlip_begin(n_slip)) && (STEC_new(nSlip_begin(n_slip),PRN) > STEC_new(nSlip_end(n_slip),PRN))
                        STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) = ...
                            STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) + Delta_slip((n_slip));
                    elseif (nMax_elev < nSlip_begin(n_slip)) && (STEC_new(nSlip_begin(n_slip),PRN) < STEC_new(nSlip_end(n_slip),PRN))
                        STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) = ...
                            STEC_new(nSlip_end(n_slip):nCycle_end(n_cycle),PRN) - Delta_slip((n_slip));
                    end
                end
            end
        end
    else
        STEC_new(:,PRN) = NaN;
    end
end
end
