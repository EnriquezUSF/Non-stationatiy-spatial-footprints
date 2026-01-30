clear; close all; clc

fsave = 'D:\Temporal variations SF\Seasonal variations 3\S1 Data\';

%% Load water levels lonlat

cd('H:\Javed - Data\CODEC\WL\cf_esl')

infoJ = ncinfo('gtsm_station00000.nc');

files = dir('gtsm*.nc');

lonlat_wl = nan(length(files),1);

for i = 1:length(lonlat_wl)

    disp(i)

    lonlat_wl(i,1) = ncread(files(i).name,'longitude');
    lonlat_wl(i,2) = ncread(files(i).name,'latitude');

end


files_name = {files.name}';

T_lonlat_wl = table(files_name,lonlat_wl);

%% Load tides lonlat

cd('H:\Javed - Data\CODEC\Tide\cf_tides')

files = dir('gtsm*.nc');

infoJ = ncinfo(files(1).name);
ncdisp(files(1).name);

lonlat_tides = nan(length(files),1);

for i = 1:length(lonlat_tides)

    disp(i)

    lonlat_tides(i,1) = ncread(files(i).name,'longitude');
    lonlat_tides(i,2) = ncread(files(i).name,'latitude');

end


files_name = {files.name}';

T_lonlat_tide = table(files_name,lonlat_tides);


%%
figure; hold all; 
plot(lonlat_tides(:,1),lonlat_tides(:,2),'o')
plot(lonlat_wl(:,1),lonlat_wl(:,2),'.')

%% 

save([fsave 'S1 - CoDEC lonlat.mat'],'T_lonlat_tide','T_lonlat_wl','-mat');



