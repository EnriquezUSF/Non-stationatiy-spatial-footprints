
addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))

clear; close all; clc

MF = 'D:\Temporal variations SF\Seasonal variations 4\';

cd([MF 'S1 Data\']);

load('S2 Region - CoDEC lonlat East US.mat')

tidefolder = 'H:\Javed - Data\CODEC\Tide\cf_tides\';
surgefolder= 'H:\Javed - Data\CODEC\WL\cf_esl\';

%% Time

timetide = ncread([tidefolder T_lonlat_tide.files_name{1}],'index');
timetide = double(timetide);
timetide = datenum([1979 1 1 0 0 0]) + timetide/24;

timewl = ncread([surgefolder T_lonlat_wl.files_name{1}],'index');
timewl = double(timewl);
timewl = datenum([1979 1 1 0 0 0]) + timewl/24;

%% Load data
close all; clc

tide  = nan(size(T_lonlat_tide,1),length(timetide));
wl    = nan(size(T_lonlat_wl,1),length(timewl));

for i = 1: size(T_lonlat_wl,1)

    disp([num2str(i) ' out of ' num2str(size(T_lonlat_wl,1))])

    tide(i,:) = ncread([tidefolder T_lonlat_tide.files_name{i}],'waterlevel');

    tidelonlat(i,1) = ncread([tidefolder T_lonlat_tide.files_name{i}],'longitude');
    tidelonlat(i,2) = ncread([tidefolder T_lonlat_tide.files_name{i}],'latitude');

    wl(i,:) = ncread([surgefolder T_lonlat_wl.files_name{i}],'waterlevel');

    wllonlat(i,1) = ncread([surgefolder T_lonlat_wl.files_name{i}],'longitude');
    wllonlat(i,2) = ncread([surgefolder T_lonlat_wl.files_name{i}],'latitude');

end

%% From mm to m

tide = tide./1000;
wl   = wl./1000;

%%

figure; hold all
plot(timetide,tide(1,:))
plot(timewl,wl(1,:))

%% Tides and surges have different time length

is = ismember(timetide,timewl);

timetide(is== 0) = [];
tide(:,is== 0)   = [];

lonlat = wllonlat;
time   = timetide;

stormtide = wl;

save(['S3 - Tide WL.mat'],'time','tide','stormtide','lonlat','-v7.3');
