clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

% independence time window (intw is the total time window, i.e., it would
% be used as intw/2 before and after the extreme event)
intw = 4;

%% Choose variables
% load surges
load([MF 'S4 Seasons\Ext_NTR_Season.mat']);

% choose season
season = 'FullYear';

% choose the data to work with (ETC or TC or FullYear):
time = Time{2,3};
data = Ext_NTR_Season{2,3};

% Load KMeans. Choose the polygon to work with (TC or ECT):
load([MF 'S5 KMeans\Polygons\Polygons_FullYear.mat']);

poly = Polygons_FullYear;

clear Polygons_* coordinates_all Ext_NTR_Season Time

% folder to save
fsave = [MF 'S6 Size evolution\'];
mkdir(fsave)

%% Plot
figure
color = rgb('MediumOrchid');

for i = 1: 9

    subplot(3,3,i)

    m_proj('miller','long',[min(coordinates(:,1)) max(coordinates(:,1))],...
        'lat',[min(coordinates(:,2)) max(coordinates(:,2))]);

    m_grid('tickdir','in','linest','none',...
        'FontName','Times','FontSize',12, 'xticklabels',[],'yticklabels',[]);
    m_coast('patch',[.7 .7 .7],'edgecolor','k');

    m_line(poly.('Cluster'){i,:}(:,1),poly.('Cluster'){i,:}(:,2),...
        'Marker','o','MarkerFace',color,'MarkerEdge',color,...
        'Linest','none','markersize',5);

    title(['Cluster ' num2str(poly.('NCluster')(i))])

end

%% Identify events and clasify them in a cluster

data_temp = data;
time_temp = time;

% results
res = [];

% count
c = 1;

fmax= 0;

% Loop to identify independent events. Events defined as those +/- 2 days length
while isempty(fmax)== 0

    % find the position of the maximum value
    fmax    = find(data_temp == max(max(data_temp)));
    [r,col] = find(data_temp == max(max(data_temp)));

    if isempty(fmax)== 1
        continue
    end

    % two surges with the same value
    if length(fmax)> 1
        fmax= fmax(1);
        r = r(1); col = col(1);
    end

    % times around max value
    tiempos_max= find(...
        time_temp> time_temp(col)-intw/2 & time_temp< time_temp(col)+intw/2);

    % event
    ev_ii = data_temp(:,tiempos_max);
    ev_ii(isnan(ev_ii))= 0;
    ev_ii = max(abs(ev_ii),[],2);

    ev_ii = [coordinates,ev_ii];
    ev_ii(ev_ii(:,3) == 0,:) = [];

    % coordinates of the peak of the storm
    [~,pos]= max(ev_ii(:,3));
    coord_peak = ev_ii(pos,:);

    % What cluster does it belong to?
    maxIndex = choose_polygon(coord_peak,poly); % Use coord_peak to find
    % the polygon where the peak of the storm happens.
    % Use ev_ii to find the polygon where the majority of the model
    % points exceed the threshold.

    % figure; plot_map(ev_ii);
    % 
    % hs= m_line(coord_peak(:,1),coord_peak(:,2),...
    %     'Marker','o','MarkerFace','r','MarkerEdge','r',...
    %     'Linest','none','markersize',12);
    % 
    % title(['Event in Cluster # ' num2str(maxIndex)])

    % saves

    % id of event
    res(c,1) = c;

    % size of event (number of points)
    res(c,2) = size(ev_ii,1);

    % magnitude
    res(c,3) = max(ev_ii(:,3));

    % mean
    res(c,4) = mean(ev_ii(:,3));

    % date
    res(c,5) = time_temp(col);

    % cluster
    res(c,6) = maxIndex;

    c = c+1;

    % nan in the max position to don't find it again
    data_temp(:,tiempos_max)= nan;

end

%% Store results

Size_Footprints = array2table(res,'VariableNames',{'id_event','size_event','max_magnitude',...
    'mean_magnitude','date','Cluster'});

save([fsave 'Size_Footprints_' season '.mat'],'Size_Footprints','-mat')

