function checkfileRN(r_o_name,rinex_path)
% Check input the observation file
% Inputs 
%       r_o_name   - observation name
%       rinex_path - RINEX file path

s = dir([rinex_path r_o_name]);
if isempty(r_o_name)
    error('Please define/change the observation file')
elseif strcmp(char(r_o_name),char(s.name))
    return
else
    error('Please copy Observation file to /RINEX path')
end

end