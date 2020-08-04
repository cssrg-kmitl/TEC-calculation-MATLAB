%% download and read Satellite biases 
% Download the satellites DCB from ftp://ftp.aiub.unibe.ch/CODE/
% == Download and DCB files
if     length(P1C1_filename) == 8 &&  length(P1P2_filename) == 8
        %====== Download cURL command
        P1C1_download_cmd = ['nohup curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' P1C1_filename];
        P1P2_download_cmd = ['nohup curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' P1P2_filename];
        system(P1C1_download_cmd)
        system(P1P2_download_cmd)
            P1C1_filename2 = ['P1C1' year(3:4)...
                num2str(str2double(month),'%.2d') '.DCB'];
            P1P2_filename2 = ['P1P2' year(3:4)...
                num2str(str2double(month),'%.2d') '.DCB'];
        movefile(P1C1_filename,P1C1_filename2);
        movefile(P1P2_filename,P1P2_filename2);
        
        %====== Read Satellites DCB
        P1C1Row_fileDCB = ReadRowDCB(P1C1_filename2);
        P1P2Row_fileDCB = ReadRowDCB(P1P2_filename2);
        P1C1_DCB = ReadDCB(P1C1_filename2,P1C1Row_fileDCB-2);
        P1P2_DCB = ReadDCB(P1P2_filename2,P1C1Row_fileDCB-2);
        
elseif (exist(P1C1_filename, 'file') && exist(P1P2_filename, 'file'))
       %====== Read Satellites DCB
        P1C1Row_fileDCB = ReadRowDCB(P1C1_filename);
        P1P2Row_fileDCB = ReadRowDCB(P1P2_filename);
        P1C1_DCB = ReadDCB(P1C1_filename,P1C1Row_fileDCB-2);
        P1P2_DCB = ReadDCB(P1P2_filename,P1C1Row_fileDCB-2);
else
        P1C1_download_cmd = ['curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' year '/' P1C1_filename '.Z'];
        P1P2_download_cmd = ['curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' year '/' P1P2_filename '.Z'];
        system(P1C1_download_cmd)
        system(P1P2_download_cmd)
        P1P2_unzip_cmd    = ['gzip.exe -d ' P1P2_filename];
        P1C1_unzip_cmd    = ['gzip.exe -d ' P1C1_filename];
        system(P1P2_unzip_cmd);
        system(P1C1_unzip_cmd);
        %====== Read Satellites DCB
        P1C1Row_fileDCB = ReadRowDCB(P1C1_filename);
        P1P2Row_fileDCB = ReadRowDCB(P1P2_filename);
        P1C1_DCB = ReadDCB(P1C1_filename,P1C1Row_fileDCB-2);
        P1P2_DCB = ReadDCB(P1P2_filename,P1C1Row_fileDCB-2);
end


