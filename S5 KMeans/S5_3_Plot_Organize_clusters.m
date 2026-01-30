clear; close all; clc

% Main folder
MF = 'C:\Users\enriqueza\OneDrive - University of South Florida\Working papers\Paper spatial footprints\Seasonal variations 4\';
addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))
addpath([MF 'toolbox'])

load([MF '\S5 KMeans\KMeans NOC9 - Organized\KMeans_sorted.mat'])

data = KMeans.('FullYear'){1,:};
centroids = KMeans.('FullYear'){2,:};

%% Plot
figure
color = rgb('MediumOrchid');

for i = 1: 9

    data_in = find(data(:,3)== i);
    data_in = data(data_in,:);

    subplot(3,3,i)

    m_proj('miller','long',[min(data(:,1)) max(data(:,1))],...
        'lat',[min(data(:,2)) max(data(:,2))]);

    m_grid('tickdir','in','linest','none',...
        'FontName','Times','FontSize',12, 'xticklabels',[],'yticklabels',[]);
    m_coast('patch',[.7 .7 .7],'edgecolor','k');

    hs= m_line(data_in(:,1),data_in(:,2),...
    'Marker','o','MarkerFace',color,'MarkerEdge',color,...
    'Linest','none','markersize',5);

    m_line(centroids(i,1),centroids(i,2),...
    'Marker','o','MarkerFace','k','MarkerEdge','k',...
    'Linest','none','markersize',7);

    title(['Cluster ' num2str(data_in(1,3))])

end
