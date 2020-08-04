%==========================================================================
% Estimation of receiver bias (G. Ma and T. Maruyama, 2003)
%==========================================================================
% Developed by Athiwat Chiablaem, Jirapoom Budtho, Napat Tongkasem
%==========================================================================
function rcv_bias_ns = rcv_bias_ma(sp,ep,step,STEC_removesatbias,slant_factor)
% Output:
%        rcv_bias_ns = receiver DCB in nano second
% Input:
%               sp   = minimum of delay (definded)
%               ep   = maximum of delay (definded)
%               step = sample  of delay (definded)
% STEC_removesatbias = STEC without satellite DCB
%      slant_factor  = Slant factor (STEC to VTEC convertor)

STEC_removesatbias = STEC_removesatbias(1:30:end,:);
slant_factor = slant_factor(1:30:end,:);
br = [sp:step:ep];
flac = 1;
f1 = 1575.42*10^6;          %   f1 = 1575.42 MHz (L1)
f2 = 1227.60*10^6;          %   f2 = 1227.60 MHz (L2)
c  = 299792458;             %   light speed = 299792458 m/s
A  = 40.3;
for loop=0:5
    if ~flac
        br = rcv_bias_ns-(step/(10^(loop-1))):step/(10^loop):rcv_bias_ns+(step/(10^(loop-1)));
    end
    std_vtec = nan(length(br),1);
    for bri = 1:length(br)
        %=========== remove receiver bias
        Br = br*(c*(f1^2*f2^2/(A*(f1^2-f2^2)*10^16)))*(10^-9);
        STEC_adj_allnobias = STEC_removesatbias - Br(bri);
        %=========== convert to VTEC
        VTEC_no_sat_bias1  = STEC_adj_allnobias.*slant_factor;
        %=========== determine standard deviation
        VTEC_std_during    = nanstd(VTEC_no_sat_bias1');
        std_vtec(bri)      = nansum(VTEC_std_during');
    end
    %========== find minimum value
    [std_vtec,Br] = min(std_vtec(:));
    [Y,Z] = ind2sub([size(std_vtec,1) size(std_vtec,2)],Br);
    %========== choose receiver bias
    rcv_bias_ns = br(Y,Z);
    flac = 0;
%     disp(rcv_bias_ns);
end