% clear; close all; clc

% Main folder
MF = 'C:\Users\enriqueza\OneDrive - University of South Florida\Working papers\Paper spatial footprints\Seasonal variations 4\';
addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S6 Size evolution\'];

%% Load data
load([MF 'S6 Size evolution\Size_Footprints_FullYear.mat']);

season = 'FullYear';

%% Data preparation

% Exclude events smaller than 10 points
% Size_Footprints(Size_Footprints.size_event < 10, :) = [];

% Annual mean, all clusters included

% Convert datenum to datetime if not already
Size_Footprints.date = datetime(Size_Footprints.date, 'ConvertFrom', 'datenum');

% Extract year from datetime
Size_Footprints.Year = year(Size_Footprints.date);

%% Group by year and compute means
annual_means = groupsummary(Size_Footprints, "Year", "mean", ...
    ["size_event", "max_magnitude", "mean_magnitude"]);

figure;
bar(annual_means.Year,annual_means.mean_size_event,.9)
ylabel('# model points')
title('All clusters together')

%% Annual mean for each cluster independently

% Group by Year AND Cluster, compute means
annual_cluster_means = groupsummary(Size_Footprints, ["Year","Cluster"], "mean", ...
    ["size_event","max_magnitude","mean_magnitude"]);

% Unique clusters
clusters = unique(annual_cluster_means.Cluster);

% Number of clusters
nClusters = numel(clusters);

colors_plot = [0.7002    0.0027    0.7006; .7 .7 .7];

% Create figure
hf = figure;
hf.Units = 'centimeters';
hf.Position = [8.0000    5   16.9502   14.7373];

ni = 3;
nj = 3;

ha = tight_subplot(nj,ni,[0 .045],[.05 0],[.08 .001]);

for i = 1:nClusters

    % Select subplot
    axes(ha(i));
    
    % Extract data for this cluster
    dataC = annual_cluster_means(annual_cluster_means.Cluster == clusters(i), :);
    
    % Plot
    % plot(dataC.Year, dataC.mean_size_event, '-o');
    bar(dataC.Year, dataC.mean_size_event, .9)
    colororder(colors_plot(1,:))
    grid on;
    
    % % Labels and title
    % xlabel('Year');
    % ylabel('Avg. Size Event');
    % title(['Cluster ' season '-', num2str(clusters(i))]);
    title(['F-', num2str(clusters(i))]);

    % Remove x/y labels by default
    ax = gca;
    ax.Position(4) = 0.28;
    % ax.XLabel.String = '';
    % ax.YLabel.String = '';

    % Show only leftmost y-ticks
    if i == 4
        ylabel('Avg. Size Event');
    else
        % ax.YTickLabel = [];
    end
    
    % Show only bottom x-ticks
    if i > 6
        % xlabel('Year');

        xticks = 1980:5:2018; % get(gca,'XTick');
        set(gca,'XTick',xticks,'XTickLabel',xticks)

    else
        xticks = 1980:5:2018; % get(gca,'XTick');
        set(gca,'XTick',xticks,'XTickLabel',xticks)
        ax.XTickLabel = [];
    end
end

% Adjust layout a little
% sgtitle('Annual Average Size per Cluster');

%% Save

% Save with specific size
hf.PaperUnits = 'centimeters';
hf.PaperPosition = [0 0 16.97 39.69];

FigName   = [fsave 'Size Evolution_' season '.png'];
exportgraphics(hf,FigName,'Resolution',500)






