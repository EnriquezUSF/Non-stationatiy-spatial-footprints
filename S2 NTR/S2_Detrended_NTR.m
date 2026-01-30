%%% Detrend and calculate surges

clear; close all; clc

% Main folder
MF = 'D:\Temporal variations SF\Seasonal variations 4\';

namefile = 'East US';

addpath([MF 'toolbox'])

fsave = [MF 'S2 NTR\'];
mkdir(fsave)

% Model data
load([MF 'S1 Data\S3 - Tide WL.mat']);

%% 

figure
plot_map(lonlat);

%%
itest = 1;

figure; hold all
plot(time,stormtide(itest,:),'.-')
plot(time,tide(itest,:))
datetickzoom('x','dd/mm')
grid minor

%% Detrend
stormtide_det   = stormtide;
tide_det        = tide;

for i = 1: size(lonlat,1)

    stormtide_det(i,:)  = det_year_running_window(stormtide(i,:));
    tide_det(i,:)       = det_year_running_window(tide(i,:));

    disp(i)
end

%%
figure; hold all
plot(time,stormtide_det(itest,:),'.-')
plot(time,tide_det(itest,:))
datetickzoom('x','dd/mm')
grid minor

%% Calculation of surges if hourly data

surge = stormtide_det - tide_det;

%% Plot

hh = figure; hold all
subplot(3,1,1)
plot(time,tide(itest,:),'.-')
datetickzoom
ylabel('tide (m)')
ca = xlim;

subplot(3,1,2)
plot(time,stormtide(itest,:),'.-')
datetickzoom
ylabel('sl (m)')
xlim(ca)

subplot(3,1,3)
plot(time,surge2(itest,:),'.-')
datetickzoom
ylabel('surge (m)')
xlim(ca)

%% Discard first month

surge        = surge(:,744:end);
surgetime    = time(744:end);

%% Plot

hh = figure; hold all
subplot(3,1,1)
plot(time,tide(itest,:),'.-')
datetickzoom
ylabel('tide (m)')
ca = xlim;

subplot(3,1,2)
plot(time,stormtide(itest,:),'.-')
datetickzoom
ylabel('sl (m)')
xlim(ca)

subplot(3,1,3)
plot(surgetime,surge(itest,:),'.-')
datetickzoom
ylabel('surge (m)')
xlim(ca)



%% Save

time = surgetime;
NTR  = surge;

save([fsave 'NTR_det.mat'],'NTR','time','lonlat','-v7.3')

disp('DONE')


