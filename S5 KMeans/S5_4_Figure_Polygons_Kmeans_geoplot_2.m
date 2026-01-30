clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\]';
addpath([MF 'toolbox'])

fsave = [MF 'S5 KMeans\Polygons\Figures\'];
mkdir(fsave)
cd(fsave)

load([MF '\S5 KMeans\Kmeans NOC9 - Organized\KMeans_sorted.mat'])

load([MF '\S5 KMeans\Polygons\Polygons_TC.mat'])
load([MF '\S5 KMeans\Polygons\Polygons_ETC.mat'])
load([MF '\S5 KMeans\Polygons\Polygons_FullYear.mat'])

%%
titles      = {'TC season','ETC season','Full year'};
NCentroids  = length(unique(coordinates_all(:,3)));

% markers
mks = {'o','o','square','square'};
mks = repmat(mks,1,NCentroids);

for ii = 1:3

    if ii== 1
        data = Polygons_TC;
    elseif ii== 2
        data = Polygons_ETC;
    elseif ii== 3
        data = Polygons_FullYear;
    end

    centroids   = data.Centroid;

    fig = figure;
    fig.Units = 'centimeters';
    fig.Position(3) = 9.5;
    fig.Position(4) = 10;

    gx = geoaxes;

    geobasemap grayland

    geolimits([min(coordinates_all(:,2)),...
        max(coordinates_all(:,2))],[min(coordinates_all(:,1)),...
        max(coordinates_all(:,1))]);

    hold on

    for i = 1: NCentroids

        % points
        poly = data.Polygon(i,1).Vertices;

        hh = geoplot(poly(:,2),poly(:,1),mks{i},'MarkerFaceColor',data.Color(i,:),...
            'MarkerEdgeColor',data.Color(i,:),'markersize',4);

        if mod(i, 2) == 0
            hh.MarkerEdgeColor = 'k';
            hh.LineWidth = 0.1;
        else
        end

    end

    % centroid
    geoplot(centroids(:,2),centroids(:,1),'MarkerFaceColor',...
        'none','Marker','.','LineWidth',1.5,...
        'Linest','none','markersize',30,'MarkerEdgeColor','k');

    set(gca,'FontSize',12,'FontName','Times')
    title(titles{ii},'FontSize',12,'FontWeight','normal')

    gx.LatitudeAxis.TickLabels = {};
    gx.LongitudeAxis.TickLabels = {};

    gx.LatitudeLabel.String = '';
    gx.LongitudeLabel.String = '';

    gx.Scalebar.Visible = "off";

    grid off

    exportgraphics(fig,...
        [fsave 'Figure_polygons_KMeans_geoplot_' titles{ii} '.jpg'],...
        'Resolution',500)


end

%% subplots

fig = figure;
fig.Units = 'centimeters';
fig.Position(1) = 5;
fig.Position(3) = 30;
fig.Position(4) = 10;
hold on

t = tiledlayout(1,3);

for ii = 1:3

    if ii== 1
        data = Polygons_TC;
    elseif ii== 2
        data = Polygons_ETC;
    elseif ii== 3
        data = Polygons_FullYear;
    end

    centroids   = data.Centroid;

    gx = geoaxes(t);
    %     gx = geoaxes;
    gx.Layout.Tile = ii;
    geobasemap grayland

    geolimits([min(coordinates_all(:,2)),...
        max(coordinates_all(:,2))],[min(coordinates_all(:,1)),...
        max(coordinates_all(:,1))]);

    grid off

    hold on

    for i = 1: NCentroids

        % points
        poly = data.Polygon(i,1).Vertices;

        geoplot(poly(:,2),poly(:,1),'o','MarkerFaceColor',data.Color(i,:),...
            'MarkerEdgeColor',data.Color(i,:),'markersize',2)

        % centroid
        geoplot(centroids(i,2),centroids(i,1),'MarkerFaceColor',...
            'none','Marker','.','LineWidth',1.5,...
            'Linest','none','markersize',10,'MarkerEdgeColor','k');

    end


    set(gca,'FontSize',12,'FontName','Times')
    title(titles{ii},'FontSize',12,'FontWeight','normal')

    gx.LatitudeAxis.TickLabels = {};
    gx.LongitudeAxis.TickLabels = {};

    gx.LatitudeLabel.String = '';
    gx.LongitudeLabel.String = '';

    gx.Scalebar.Visible = "off";

end

exportgraphics(fig,...
    [fsave 'Subplot_KMeans_geoplot_' titles{ii} ' 2.jpg'],...
    'Resolution',500)


