clear; close all; clc

% Main folder
MF = 'D:\Temporal variations SF\Seasonal variations 4\';
addpath([MF 'toolbox'])

load ([MF 'S3 Extremes\NTR_Extr.mat'])

fsave = ([MF 'S4 Seasons\']);
mkdir(fsave)

time = Time_extr;
data = NTR_Extr;

%% Seasons ................................................................

% Hurricane season June to November in eastern US

dates = datevec(time);
Junes = 6;          
Nov   = 11;          

fhurr = find(dates(:,2)>= Junes & dates(:,2)<= Nov);

Hurr     = data(:,fhurr); 
timeHurr = time(fhurr);

noHurr          = data; 
noHurr(:,fhurr) = [];

timenoHurr          = time;
timenoHurr(fhurr)   = [];

%% Plot
figure; plot(timeHurr,Hurr(10,:),'.-r')
hold all
plot(timenoHurr,noHurr(10,:),'.-b')
datetickzoom
legend('TC','ETC')

ylabel('NTR (m)')

set(gca,'FontName','Times','FontSize',12)
grid minor

saveas(gcf,[fsave 'NTR Extr seasons.png'])

%% Organize and save

Ext_NTR_Season{1,1} = 'TC';
Ext_NTR_Season{1,2} = 'ETC';
Ext_NTR_Season{1,3} = 'FullYear';

Ext_NTR_Season{2,1} = Hurr;
Ext_NTR_Season{2,2} = noHurr;
Ext_NTR_Season{2,3} = data;

Time{1,1} = 'TC';
Time{1,2} = 'ETC';
Time{1,3} = 'FullYear';

Time{2,1} = timeHurr;
Time{2,2} = timenoHurr;
Time{2,3} = time;

save([fsave 'Ext_NTR_Season.mat'],'Ext_NTR_Season','Time','coordinates','-v7.3')






















