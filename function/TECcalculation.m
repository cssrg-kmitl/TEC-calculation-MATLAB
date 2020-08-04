function TECcalculation(obs,nav,satb,S_path)
% Calculate Total Electron Content (TEC)
% Inputs: 
%        obs     = observation data
%        nav     = navigation data
%        satb    = Satellite bias
%        S_path  = results path
% Save files:
%       TEC      = Total Electron Content (STEC VTEC STEC_with_rcvbias STEC_with_bias STECp STECl )
%       ROTI     = Rate Of Change TEC Index
%       DCB      = Satellite and receiver Differential Code Bias (DCB)
%       prm      = parameters (elevation angle)
%       refpos   = reference position


% ======================================
% Ref position (Read PPP from PPPindex.txt)
refpos = reffromIPPindex(obs.station);
disp(['Calculate TEC at ' obs.station ' station'])
if isempty(refpos)
    try
        refpos = obs.rcvpos;
    catch
    end
end
% Constants
gpscons

%% 1. Prepare matrix
% NaN
TEC.vertical         = nan(86400,32); % Vertical Total Electron Content(VTEC)
TEC.slant            = nan(86400,32); % Slant Total Electron Content(STEC)
TEC.withrcvbias      = nan(86400,32); % STEC with receiver DCB
TEC.withbias         = nan(86400,32); % STEC with satellite and receiver DCB
STECp                = nan(86400,32); % STEC calculated from code range
STECl                = nan(86400,32); % STEC calculated from carrier phase

ROTI                 = nan(288,32);   % Rate of Change TEC (5 min sample)
DCB.sat              = nan(86400,32); % Satellite DCB
DCB.rcv              = nan(86400,32); % Receiver DCB
prm.elevation        = nan(86400,32); % elevation angle

%% 2. TEC calculation
%== Satellte index
Sat_obs = unique(nav.index);
for i = 1 : length(Sat_obs) % GPS 1 - 32
    disp(['PRN# ... ' num2str(Sat_obs(i)) ' ...'])
    PRN = Sat_obs(i);
    Sat  = find(obs.index == PRN);
    Time = obs.epoch(Sat)+((obs.date(4)*60*60)+(obs.date(5)*60)+obs.date(6));
    
    % 2.1 Read pseudorange from observation file
        % Pseudorange C/A code    :L1   (m)
    C1   = obs.data(Sat,ismember(obs.type,'C1'));
        % Pseudorange P code      :L2   (m)
    P2 = obs.data(Sat,ismember(obs.type,'P2'));
        % Carrier Phase in length :L1   (m)
    L1 = lambda1*obs.data(Sat,ismember(obs.type,'L1'));
        % Carrier Phase in length :L2   (m)
    L2 = lambda2*obs.data(Sat,ismember(obs.type,'L2'));
    
    % 2.2 Calculate elevation angle
    [satpos,~]  = satpos_xyz_sbias(Time,PRN,nav.eph,nav.index,C1);
    vector_s  = satpos-refpos;
    vector_r2 = refpos-center_E;
    vector_r  = repmat(vector_r2,length(vector_s),1);
        % elevation angle
    prm.elevation(Time+1,PRN) = 90-acosd(dot(vector_s,vector_r,2)./(vecnorm(vector_s')'...
                                .*vecnorm(vector_r')'));
    % 2.3 Calculate STEC
        %===== STEC Pseudorange
    STECp(Time+1,PRN) = k*(P2-C1);
        %===== STEC Carrier phase
    STECl(Time+1,PRN) = k*(L1-L2);
end

    % 2.4 elevation angle cutoff <15 degree
mask                 = prm.elevation;
mask(mask<elev_mask) = NaN;
mask(~isnan(mask))   = 1;
% angle cut STEC
TEC.STECp = mask.*STECp;
TEC.STECl = mask.*STECl;
prm.elevation = mask.*prm.elevation;

    % 2.5 Cycle slip correction
Sample = 1;
STECl_M_new = CycleSlipCorrection(TEC.STECl,prm.elevation,Sample,Sat_obs',3*60,24*60,1,30);

    % 2.6 Adjusted STEC 
% window adjusted every length of nan/2
TEC.withbias = windowshiftTEC(STECl_M_new,TEC.STECp);

    % 2.7 STEC remove satellite Bias
% Satellite bias (TECu)
Bias_sat1    = (satb.P1C1-satb.P1P2);
Bias_sat_tec = (Bias_sat1)*(c*(f1^2*f2^2/(A*(f1^2-f2^2)*10^16)));
DCB.sat      = Bias_sat_tec(1:32);
% remove satellite biases
disp('Remove satellite bias ....')
STEC_adj_nosatbias = TEC.withbias - ones(size(TEC.withbias))*diag(DCB.sat');
% STEC Remove outlinier
STEC_nooutline     = outlinecorr(STEC_adj_nosatbias);
% Last Check outlinier
TEC.withrcvbias    = STEC_nooutline;
for PNN = 1:32
     count=0;
     for chk = 84900:86400
         if ~isnan(TEC.withrcvbias(chk,PNN))
             count = count+1;
         end
     end
     if count<1500
         TEC.withrcvbias(84900:86400,PNN)=nan;
     end
end

    % 2.8 Estimation for receiver bias (G. Ma and T. Maruyama, 2003)
% Slant factor
slant_factor       = sqrt(1-(Re*cosd(prm.elevation)/(Re+h)).^2);
disp('Remove receiver bias ....')
starting_point = -30;
ending_point   = 30;
step_size      = 0.1;
rcv_bias_ns  = rcv_bias_ma(starting_point,ending_point...
        ,step_size,TEC.withrcvbias,slant_factor);
DCB.rcv     = (rcv_bias_ns*10^-9*(c*(f1^2*f2^2/(A*(f1^2-f2^2)*10^16))));

    %================================
    %          Absolute TEC
    %================================
STEC_completed = (TEC.withrcvbias - DCB.rcv);
VTEC_completed  = (TEC.withrcvbias - DCB.rcv).*slant_factor;
% Using zero adjust TEC (Minimum TEC is Zero)
tec_min = nanmin(STEC_completed);
TEC.slant    =  STEC_completed + abs(nanmin(tec_min));
TEC.vertical = VTEC_completed  + abs(nanmin(tec_min));

%% 3. ROTI calculation
disp('Estimate the receiver bias ....')
ROTI = roticalculation(STECl_M_new,Sat_obs');
   
%% Save file
year  = num2str(obs.date(1));
month = num2str(obs.date(2),'%.2d');
date  = num2str(obs.date(3),'%.2d');
name1 = ['TEC_' year '_' month '_' date];
name2 = ['DCB_' year '_' month '_' date];
name3 = ['ROTI_' year '_' month '_' date];
name4 = ['prm_' year '_' month '_' date];
eval([name1 '= TEC;'])
eval([name2 '= DCB;'])
eval([name3 '= ROTI;'])
eval([name4 '= prm;'])
filename = [S_path 'TEC_' obs.station '_' year '_' month '_' date];
save(filename,name1,name2,name3,name4,'refpos')
disp(['Complete to Calculate TEC at ' obs.station ' station'])
end

    