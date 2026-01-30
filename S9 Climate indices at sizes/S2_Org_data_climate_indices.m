%%% Organize data in quantiles and add climate index information including NoEvent

clear; close all; clc

MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S9 Climate indices at sizes\S2 Org data climate indices\'];
mkdir(fsave)

% Climate index to work with
cd([MF 'S9 Climate indices at sizes\S1 Climate indices\climate indices mat'])
climate_indices_names = dir('*data*');

Seasons = {'ETC','TC','FullYear'};

for id_season = 3 % 1:3
    season = Seasons{id_season};

    %% Load SF data
    load([MF 'S6 Size evolution\Size_Footprints_' season '.mat']);

    %% Loop over clusters
    for cluster = 1:9

        disp(cluster)
        SF_Cluster = Size_Footprints(Size_Footprints.Cluster == cluster, :);

        %% Quantiles
        qs = [0 .25 .50 .75 1];
        sizeQuantiles = quantile(unique(SF_Cluster.size_event), qs);
        Quantiles = nan(size(SF_Cluster.size_event,1),length(qs)-1);

        for i = 1:length(qs)-1
            % Find events in this quantile
            id = SF_Cluster.size_event >= sizeQuantiles(i) & SF_Cluster.size_event <= sizeQuantiles(i+1);
            Quantiles(:,i) = id;
        end

        Quantiles = array2table(Quantiles,"VariableNames",{'Q1','Q2','Q3','Q4'});
        SF_Cluster = [SF_Cluster, Quantiles];

        %% Load climate indices
        for id_ci = 1:length(climate_indices_names)
            
            CI = load(climate_indices_names(id_ci).name);
            ci_name = climate_indices_names(id_ci).name;
            ci_ts = [CI.CI_time, CI.CI_data];

            % %% Activate this cell if only the season months in the ci are included, otherwise all months in the climate index are included
            % % Hurricane season June 1 to November 30 in eastern US
            % dates = datevec(ci_ts(:,1));
            % Junes = 6;
            % Nov   = 11;
            % fhurr = find(dates(:,2)>= Junes & dates(:,2)<= Nov);
            % if strcmp(season,'TC')
            %     ci_ts = ci_ts(fhurr,:);
            % elseif strcmp(season,'ETC')
            %     ci_ts(fhurr,:) = [];
            % end

            %% Exclude years before and after time limits storm surge data
            years_SF = year(datetime(SF_Cluster.date,'ConvertFrom','datenum'));
            firstYear = min(years_SF);
            lastYear  = max(years_SF);

            % Filter CI time series
            CI_time = datetime(ci_ts(:,1),'ConvertFrom','datenum');
            valid_idx = year(CI_time) >= firstYear & year(CI_time) <= lastYear;
            CI_time = CI_time(valid_idx);
            CI_data = ci_ts(valid_idx,2);
            ci_ts = [datenum(CI_time), CI_data];

            %% Create complete month list from climate index
            all_months = unique(datetime(year(CI_time), month(CI_time), 1));

            % Current SF months
            SF_months = unique(datetime(year(datetime(SF_Cluster.date,'ConvertFrom','datenum')), month(datetime(SF_Cluster.date,'ConvertFrom','datenum')),1));

            % Find missing months (no storm events)
            noEventMonths = setdiff(all_months, SF_months);

            % Create rows for NoEvent months
            nNoEvent = length(noEventMonths);
            if nNoEvent>0
                NoEventTable = table;
                NoEventTable.id_event = NaN(nNoEvent,1);
                NoEventTable.size_event = zeros(nNoEvent,1);
                NoEventTable.max_magnitude = zeros(nNoEvent,1);
                NoEventTable.mean_magnitude = zeros(nNoEvent,1);
                NoEventTable.date = datenum(noEventMonths);
                NoEventTable.Cluster = repmat(cluster,nNoEvent,1);

                % Q1-Q4 all 0
                NoEventTable.Q1 = zeros(nNoEvent,1);
                NoEventTable.Q2 = zeros(nNoEvent,1);
                NoEventTable.Q3 = zeros(nNoEvent,1);
                NoEventTable.Q4 = zeros(nNoEvent,1);

                % Append to SF_Cluster
                SF_Cluster = [SF_Cluster; NoEventTable];
            end

            % Get climate index for all rows
            [~, loc] = ismember(datetime(year(datetime(SF_Cluster.date,'ConvertFrom','datenum')),...
                month(datetime(SF_Cluster.date,'ConvertFrom','datenum')),1), datetime(year(CI_time), month(CI_time),1));
            
            ci_cluster = array2table(ci_ts(loc,2),"VariableNames",{ci_name(1:strfind(ci_name,'.')-1)});

            SF_Cluster = [SF_Cluster, ci_cluster];

            clear CI loc ci_cluster
        end

        SF_Cluster.date = sort(datetime(SF_Cluster.date,'ConvertFrom','datenum'));
        Clusters.(['Cluster_' num2str(cluster)]) = SF_Cluster;
    end

    save([fsave 'SF_Q_CI_' season '.mat'],'Clusters','-mat')
end

