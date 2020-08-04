function row = ReadRowDCB(filename)
% Read Satellite DCB file
fid = fopen(filename,'r');
kk = 1;
while (~feof(fid))
    line{kk,1} = fgetl(fid);
    kk = kk+1;
end
row = kk;
fclose(fid);