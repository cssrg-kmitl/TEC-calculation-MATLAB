function [dcb] = ReadDCB(filename,number_row)
% Read Satellite DCB files
fid = fopen(filename,'r');
i = 1;
j = 1;
dcb = NaN(32,1);
num = NaN(32,1);
fid2 = NaN(32,1);

while (~feof(fid))
    line{i,1} = fgetl(fid);
    if (i>=8 && i<=number_row)
        num(j,1) = str2num(line{i,1}(2:3));
        fid2(j,1)= str2num(line{i,1}(30:35));
        j = j+1;
    end
    i = i+1;
end
num(isnan(num))=[];
for ii=1: length(num)
    dcb(num(ii),1)=fid2(ii);    
end

fclose(fid);