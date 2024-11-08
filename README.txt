This is the README file for 
the Total Electron Content(TEC) calculation on MATLAB from RINEX 2.11
Calculate TEC based on dual-frequency receiver (GPS) 
Original by Napat Tongkasem, Somkit Sopan, Jirapoom Budtho, Nantavit Wongthodsarat
Version 1.2
(15/02/2019) - Create the program
(04/10/2022) - Fix some bug (Outlinier correction, receiver position, ROTI , Ploting)
(10/10/2022) - Update Roti calculation
(26/06/2023) - Update azimuth and IPP computation
(01/11/2024) - add calelevation function
1. The program need linux command. Cygwin must be installed
- install Cygwin-setup-x86_64.exe (64-bit ver.)
or download: https://www.cygwin.com/

2. Main program is ProcessTECCalculation.m

3. We have laboratory website, you can visit
- http://iono-gnss.kmitl.ac.th/

=================================================
Advisor: Prof.Dr. Pornchai Supnithi
CSSRG Laboratory
School of Telecommunication Engineering
Faculty of Engineering
King Mongkut's Institute of Technology Ladkrabang
Bangkok, Thailand
=================================================
Output: data 1 day 
TEC.vertical    = Vertical Total Electron Content(VTEC)
TEC.slant       = Slant Total Electron Content(STEC)
TEC.withrcvbias = STEC with receiver DCB
TEC.withbias    = STEC with satellite and receiver DCB
TEC.STECp       = STEC calculated from code range
TEC.STECl       = STEC calculated from carrier phase
DCB.sat         = Satellite DCB
DCB.rcv         = Receiver DCB
prm.elevation   = elevation angle
prm.azimuth     = azimuth angle
prm.IPP_(lat,long)= IPP position
ROTI            = Rate Of Change TEC Index

