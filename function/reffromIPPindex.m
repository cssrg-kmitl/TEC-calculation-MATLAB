function refpos = reffromIPPindex(station_name)
% Read station name from PPP file
% Input: 
%        station_name = station name (string arrays)
% Output:
%        refpos       = reference position (PPP solution)

readO  = fopen('PPPindex.txt','r');
text = textscan(readO,'%s','Delimiter','\n');
text = text{1,1};
readO  = fclose(readO);
% Find epoch time and epoch log
try
    line1 = find(~cellfun('isempty', strfind(text,station_name)));
    all_epoch_line = text{line1,1};
    all_epoch = regexp(all_epoch_line,'\=*','split');
    eval(sprintf('refpos= %s;',all_epoch{2}));
catch
    disp('No PPP reference or wrong station')
    refpos = [];
end
