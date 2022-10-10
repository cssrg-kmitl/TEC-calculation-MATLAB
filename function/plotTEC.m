function plotTEC(year,month,date,station,S_path)
% Plot the results
% Noted: This function has the command that starting in R2018b: sgtitle()
close all
plotfilter = [0 0 0]; % 1 1 1 plot everything
% Setting#2
graph_size = [10 10 800 600]; % figure size
gray   = [.5 .5 .5];
red    = [1 0 0];
blue   = [0 0 1];
ltgray = [.8 .8 .8];
Time_TEC  = (0:86399)/3600;      %   Time rate 1 second


%% Figure#1 TEC and ROTI
main1 = figure('Renderer', 'painters', 'Position', graph_size);
% Starting in R2018b
try
    sgtitle(['TEC and ROTI at ' station ' station date:' year '/' month '/' date])
catch
	 axes( 'Position', [0, 0.95, 1, 0.05] ) ;
     set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
     text( 0.5, 0, ['TEC and ROTI at ' station ' station date:' year '/' month '/' date], 'FontSize', 14', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
end

% load the results from save path
filename = [S_path 'TEC_' station '_' year '_' month '_' date];
load(filename)
name1 = ['TEC_' year '_' month '_' date];
name2 = ['DCB_' year '_' month '_' date];
name3 = ['ROTI_' year '_' month '_' date];
name4 = ['prm_' year '_' month '_' date];
eval(['TEC   = ' name1 ';'])
eval(['DCB   = ' name2 ';'])
eval(['ROTI  = ' name3 ';'])
eval(['prm   = ' name4 ';'])

subplot(211)
plot(Time_TEC,TEC.slant,'.');
hold on
plot(Time_TEC,TEC.vertical,'.','LineWidth',1,'Color',[0 0 0]);
hold off
xlim([0 24])
ylim([0 inf])
% legend([p2(1) pm],'STEC','median VTEC')
grid on
ylabel('TEC (TECU)')
title('Total Electron Content (TEC)')
text(0.5,nanmin(ylim)+2,'CSSRG Laboratory@KMITL, Thailand.','Color',[0 0 0],'FontSize',6)

subplot(212)
plot(Time_TEC,ROTI,'k')
axis([0 24 0 1])
grid on
xlabel('Time (UTC)')
ylabel('ROTI (TECU/min)')
title('Rate of TEC change index (ROTI)')
text(0.5,0.12,'CSSRG Laboratory@KMITL, Thailand.','Color',[0 0 0],'FontSize',6)
movegui(main1,'center');

%% Figure#2 DCB
if plotfilter(1) == 1
main2 = figure('Renderer', 'painters', 'Position', graph_size);
% Starting in R2018b
try
    sgtitle(['Differential Code Bais (DCBs) at ' station ' station date:' year '/' month '/' date])
catch
	 axes( 'Position', [0, 0.95, 1, 0.05] ) ;
     set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
     text( 0.5, 0, ['Differential Code Bais (DCBs) at ' station ' station date:' year '/' month '/' date], 'FontSize', 14', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
end

subplot(211)
for P = 1:length(DCB.sat)
    namePRN{P} = sprintf('Sat#%.2d',P);
end
stat = categorical(namePRN);
bar(stat,DCB.sat);
grid on
ylabel('DCBs(TECU)')
text(1:length(namePRN),DCB.sat,num2str(DCB.sat,'%.2f'),'vert','bottom','horiz','center'); 
box off
subplot(212)
stat2 = categorical({'Receiver Bias'});
bar(stat2,DCB.rcv,'BarWidth', 0.1)
grid on
ylabel('DCBs(TECU)')
text(1,DCB.rcv,num2str(DCB.rcv,'%.2f'),'vert','bottom','horiz','center'); 
box off

movegui(main2,'northwest');
end

%% Figure#3 STEC with DCBs
if plotfilter(2) == 1
main3 = figure('Renderer', 'painters', 'Position', graph_size);
% Starting in R2018b
try
    sgtitle(['STEC with DCBs at ' station ' station date:' year '/' month '/' date])
catch
    axes( 'Position', [0, 0.95, 1, 0.05] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
    text( 0.5, 0, ['STEC with DCBs at ' station ' station date:' year '/' month '/' date], 'FontSize', 14', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
end

subplot(211)
plot(Time_TEC,TEC.withbias,'.');
xlim([0 24])
grid on
ylabel('TEC (TECU)')
title('STEC with satellite and receiver DCBs')
subplot(212)
plot(Time_TEC,TEC.withrcvbias,'.');
xlim([0 24])
grid on
ylabel('TEC (TECU)')
title('STEC with receiver DCB only')
xlabel('Time (UTC)')
movegui(main3,'southwest');
end
%% Figure#4 STECp and STECl
if plotfilter(3) == 1
main4 = figure('Renderer', 'painters', 'Position', graph_size);
try
    sgtitle(['Raw STEC at ' station ' station date:' year '/' month '/' date])
catch
	axes( 'Position', [0, 0.95, 1, 0.05] ) ;
    set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
    text( 0.5, 0, ['Raw STEC at ' station ' station date:' year '/' month '/' date], 'FontSize', 14', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
end
subplot(211)
plot(Time_TEC,TEC.STECp,'.');
xlim([0 24])
grid on
ylabel('TEC (TECU)')
title('STEC from psudorange code calculation')
subplot(212)
plot(Time_TEC,TEC.STECl,'.');
xlim([0 24])
grid on
ylabel('TEC (TECU)')
title('STEC from carrier phase calculation')
xlabel('Time (UTC)')
movegui(main4,'northeast');
end

end
