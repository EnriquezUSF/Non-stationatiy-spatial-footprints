clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

% folder where ERA-5 is
fera5 = 'D:\ERA5';

% Season to work with
season = 'FullYear';

% Folder to save
fsave = [MF 'S7 Weather composites\Plots ' season '\'];
mkdir(fsave)

%% Load SF data
load([MF 'S6 Size evolution\Size_Footprints_' season '.mat']);

% coastline
coastline = load('Coastline_North_Atlantic.mat');

%% Step 1: Determine all years needed across all clusters
all_dates = datetime(Size_Footprints.date,'ConvertFrom','datenum');
years_needed = unique(year(all_dates));

%% Step 2: Load all ERA5 years into a cache
era5_cache = struct;

for ii = 1:length(years_needed)

    year_i = years_needed(ii);
    file = fullfile(fera5, "era5_" + string(year_i) + ".nc");
    disp(['Loading ' file])

    % Load variables
    lon  = ncread(file,'longitude');
    lat  = ncread(file,'latitude');
    time_era5 = ncread(file,'valid_time');
    msl = ncread(file,'msl');
    u10 = ncread(file,'u10');
    v10 = ncread(file,'v10');

    % Convert to datetime and strip sub-day info
    t_days = dateshift(datetime(datenum(1970,1,1) + double(time_era5)/(24*3600),'ConvertFrom','datenum'),'start','day');
    era5_cache(ii).year = year_i;
    era5_cache(ii).days = unique(t_days);
    era5_cache(ii).msl  = msl;
    era5_cache(ii).u10  = u10;
    era5_cache(ii).v10  = v10;

end

%% Step 3: Loop over clusters and quantiles
for cluster = 1:9

    disp(cluster)

    SF_Cluster = Size_Footprints(Size_Footprints.Cluster == cluster, :);
    qs = [0 .25 .50 .75 1];
    sizeQuantiles = quantile(unique(SF_Cluster.size_event), qs);
    
    for i = 1:length(qs)-1
        % Find events in this quantile
        id = SF_Cluster.size_event >= sizeQuantiles(i) & SF_Cluster.size_event < sizeQuantiles(i+1);
        set = SF_Cluster(id,:);
        SF_days = unique(dateshift(datetime(set.date,'ConvertFrom','datenum'),'start','day'));

        atmosp_set = cell(1,4);

        % Loop over cached ERA5 years
        for ii = 1:length(era5_cache)
            [~,~,Indices] = intersect(SF_days, era5_cache(ii).days);
            if isempty(Indices)
                continue
            end
            atmosp_set{1,1} = cat(1,atmosp_set{1,1}, era5_cache(ii).days(Indices));
            atmosp_set{1,2} = cat(3,atmosp_set{1,2}, era5_cache(ii).msl(:,:,Indices));
            atmosp_set{1,3} = cat(3,atmosp_set{1,3}, era5_cache(ii).u10(:,:,Indices));
            atmosp_set{1,4} = cat(3,atmosp_set{1,4}, era5_cache(ii).v10(:,:,Indices));
        end

        % Compute composites
        atmosp_set_av{i,1} = atmosp_set{1,1};
        atmosp_set_av{i,2} = nanmean(atmosp_set{1,2},3);
        atmosp_set_av{i,3} = nanmean(atmosp_set{1,3},3);
        atmosp_set_av{i,4} = nanmean(atmosp_set{1,4},3);
        atmosp_set_av{i,5} = qs(i+1);
    end

    % Save cluster results
    composite_cluster_quantile = cell2table(atmosp_set_av,...
        "VariableNames",{'Dates','MSLP','U10','V10','Quantile'});
    eval(['Cluster_' num2str(cluster) '= composite_cluster_quantile;'])
    clear composite_cluster_quantile
end

%% Save
cd(fsave)
save(['Composites_' season '.mat'],'Cluster_1','Cluster_2','Cluster_3',...
    'Cluster_4','Cluster_5','Cluster_6','Cluster_7','Cluster_8','Cluster_9','lon','lat','-mat')

%% Plot
% plot_maps(Cluster_1.MSLP{1,1}',Cluster_1.U10{1,1}',Cluster_1.V10{1,1}',lon,lat,coastline)
