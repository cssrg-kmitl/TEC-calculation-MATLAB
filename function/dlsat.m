function [satb_P1C1,satb_P1P2] = dlsat(obs,p_path,DCB_path)
% This function is the automatic download satellite biases from CODE
% website "ftp://ftp.aiub.unibe.ch/CODE/"
% >>> Output
% satb_P1C1 = DCB of P1 and C1
% satb_P1P2 = DCB of P1 and P2
% >>> Input
% obs = observation RINEX file
% p_path = program_path
% DCB_path = Differential Code Biases path


year = num2str(obs.date(1));
month = num2str(obs.date(2),'%.2d');
% define Filename of P1-C1 DCB and P1-P2 DCB
P1C1_filename = ['P1C1' year(3:4) month '.DCB'];
P1P2_filename = ['P1P2' year(3:4) month '.DCB'];
chk_d = datetime(obs.date(1),obs.date(2),1);
ck = datevec(chk_d);
lg = str2double(month) == ck(2)-1 || str2double(month) == ck(2);
if (~exist([DCB_path P1C1_filename], 'file') && ~exist([DCB_path P1P2_filename], 'file')) && lg
    P1C1_filename = 'P1C1.DCB';
    P1P2_filename = 'P1P2.DCB';
end
% download and read biases
cd(DCB_path);
% download and read Satellite biases 
% Download the satellites DCB from ftp://ftp.aiub.unibe.ch/CODE/
% == Download and DCB files
if     length(P1C1_filename) == 8 &&  length(P1P2_filename) == 8
        %====== Download cURL command
        P1C1_download_cmd = ['curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' P1C1_filename];
        P1P2_download_cmd = ['curl.exe -v -O --retry 50 --retry-max-time 0 ftp://ftp.aiub.unibe.ch/CODE/' P1P2_filename];
        system(P1C1_download_cmd)
        system(P1P2_download_cmd)
            P1C1_filename2 = ['P1C1' year(3:4) month '.DCB'];
            P1P2_filename2 = ['P1P2' year(3:4) month '.DCB'];
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
satb_P1C1 = P1C1_DCB(1:32).*(10^-9);
satb_P1P2 = P1P2_DCB(1:32).*(10^-9);

cd(p_path)

end


