addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))

clear; close all; clc

MF = 'D:\Temporal variations SF\Seasonal variations 4\';

cd([MF 'S1 Data\']);

load('S1 - CoDEC lonlat.mat')

region = 'East US';

%% TIDES

coordinates = T_lonlat_tide.lonlat_tides;
id_tides    = (1: size(coordinates,1))';

hh= figure;
plot_map(coordinates);

% East US
lims = [-100 -50 13 46.5];

% % West US
% lims = [-180 -80 0 62];

coordinates(coordinates(:,1)< lims(1),:)   = nan;
coordinates(coordinates(:,1)> lims(2),:)   = nan;
coordinates(coordinates(:,2)< lims(3),:)   = nan;
coordinates(coordinates(:,2)> lims(4),:)   = nan;

id_tides(isnan(coordinates(:,1)),:) = [];
coordinates(isnan(coordinates(:,1)),:) = [];

hh= figure;
plot_map(coordinates);

%% Remove areas
figure;
plot(coordinates(:,1),coordinates(:,2),'.','MarkerSize',12)

boundpoly1 = ginput;
boundpoly1 = [boundpoly1; boundpoly1(1,:)];

in = inpolygon(coordinates(:,1),coordinates(:,2),boundpoly1(:,1),boundpoly1(:,2));
hold all; plot(coordinates(in==1,1),coordinates(in==1,2),'.r','MarkerSize',10)

id_tides(in==0,:)   = [];

T_lonlat_tide = T_lonlat_tide(id_tides,:);

%% Surges

coordinates =  T_lonlat_wl.lonlat_wl;
id_surges   = (1: size(coordinates,1))';

coordinates(coordinates(:,1)< lims(1),:)   = nan;
coordinates(coordinates(:,1)> lims(2),:)   = nan;
coordinates(coordinates(:,2)< lims(3),:)   = nan;
coordinates(coordinates(:,2)> lims(4),:)   = nan;

id_surges(isnan(coordinates(:,1)),:)   = [];
coordinates(isnan(coordinates(:,1)),:) = [];

figure;
plot(coordinates(:,1),coordinates(:,2),'.','MarkerSize',12)

in = inpolygon(coordinates(:,1),coordinates(:,2),boundpoly1(:,1),boundpoly1(:,2));
hold all; plot(coordinates(in==1,1),coordinates(in==1,2),'.r','MarkerSize',10)

id_surges(in==0,:)  = [];
coordinates(in==0,:)= [];

hh= figure;
plot_map(coordinates);

T_lonlat_wl = T_lonlat_wl(id_surges,:);

%% Check if the coordinates in both datasets are in order
dcoord = sum(T_lonlat_wl.lonlat_wl - T_lonlat_tide.lonlat_tides);

%% Save

save(['S2 Region - CoDEC lonlat ' region '.mat'],'T_lonlat_tide','T_lonlat_wl','-mat');




