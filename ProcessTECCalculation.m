%% Total Electron Content (TEC) calculation from RINEX 2.11
% Calculate TEC based on dual-frequency receiver (GPS)
% Original by Napat Tongkasem
% Version 1.00 
% (10/08/2019) - Create the program
% 
% 1. The program need linux command. Cygwin must be installed
% - install Cygwin-setup-x86_64.exe (64-bit ver.)
% or download: http://cygwin.com/install.html
% 
% 2. Main program is ProcessTECCalculation.m
% 
% 3. We have laboratory website, you can visit
% - http://iono-gnss.kmitl.ac.th/
% =================================================
% CSSRG Laboratory
% School of Telecommunication Engineering
% Faculty of Engineering
% King Mongkut's Institute of Technology Ladkrabang
% Bangkok, Thailand
% =================================================
% Output : data 1 day 
% TEC.vertical    = Vertical Total Electron Content(VTEC)
% TEC.slant       = Slant Total Electron Content(STEC)
% TEC.withrcvbias = STEC with receiver DCB
% TEC.withbias    = STEC with satellite and receiver DCB
% TEC.STECp       = STEC calculated from code range
% TEC.STECl       = STEC calculated from carrier phase
% DCB.sat         = Satellite DCB
% DCB.rcv         = Receiver DCB
% prm.elevation   = elevation angle
% ROTI            = Rate Of Change TEC Index

close all;clear
warning off
tic
% 1. copy RINEX v 2.11 to /RINEX folder
% 2. define RINEX file's name
%% RINEX file
r_o_name = 'KMIT2000.20o'; % observation file's name
r_n_name = 'KMIT2000.20n'; % navigation file's name (if blank, program will downloaded from IGS)
% r_n_name = ''; % navigation file's name

% Setting#1
% =========== Program's path ==========================
p_path = [pwd '\'];             % Program path
R_path = [p_path 'RINEX\'];     % RINEX path
S_path = [p_path 'Results\'];   % Results path
DCB_path   = [p_path 'DCB\'];   % DCB path
path(path,[p_path 'function']);

%% 1. Read RINEX (using readrinex .mex file)
% Check file
checkfileRN(r_o_name,R_path);
% Read RINEX  
[obs,nav,doy,Year] = readrinex211(r_o_name,r_n_name,R_path); 
year  = num2str(obs.date(1));
month = num2str(obs.date(2),'%.2d');
date  = num2str(obs.date(3),'%.2d');
% download satellite bias
[satb.P1C1,satb.P1P2] = dlsat(obs,p_path,DCB_path);

%% 2. Calculate Total Electron Content(TEC)
TECcalculation(obs,nav,satb,S_path);

%% 3. Plot Error
plotTEC(year,month,date,obs.station,S_path)
toc
% remove file (reset)
% delete([S_path 'TEC_' obs.station '_' year '_' month '_' date '.mat']);
warning on

