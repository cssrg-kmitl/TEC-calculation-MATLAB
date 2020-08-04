function row = ReadRowDCB(filename)
fid = fopen(filename,'r');
kk = 1;
% j = 1;

% num = NaN(32,1);
% fid2 = NaN(32,1);

while (~feof(fid))
    line{kk,1} = fgetl(fid);
%     if (i>=8 && i<=number_row)
%         num(j,1) = str2num(line{i,1}(2:3));
%         fid2(j,1)= str2num(line{i,1}(30:35));
%         j = j+1;
%     end
    kk = kk+1;
end
% num(isnan(num))=[];
% for ii=1: length(num)
%     dcb(num(ii),1)=fid2(ii);    
% end
row = kk;
fclose(fid);