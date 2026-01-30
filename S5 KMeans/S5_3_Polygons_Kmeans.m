clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath([MF 'toolbox'])

load([MF '\S5 KMeans\KMeans NOC9 - Organized\KMeans_sorted.mat'])

fsave = [MF 'S5 KMeans\Polygons\'];
mkdir(fsave)


%% Areas using the full period

Var = KMeans.Properties.VariableNames;

for ii = 1: 3 % TC (1) and ETC (2) seasons

    coordinates_all = KMeans.(Var{ii+1}){1};
    centroids_all   = KMeans.(Var{ii+1}){2};

    NCentroids = length(unique(coordinates_all(:,3)));

    Polygons = {};

    for i = 1 : NCentroids % through number of clusters

        % find cluster
        fc = find(coordinates_all(:,3)== i);

        x = coordinates_all(fc,1);
        y = coordinates_all(fc,2);

        % find centroid
        fc = find(centroids_all(:,4)== i);
        centri = centroids_all(fc,1:2);

        % polygon
        cx = mean(x);
        cy = mean(y);

        a = atan2(y - cy, x - cx);

        [~, order] = sort(a);

        x = x(order);
        y = y(order);

        pgon = polyshape(x,y);
        Polygons{i,2} = pgon;
        Polygons{i,3} = [x y];
        Polygons{i,4} = centri;

    end

    %% Plot to save colors based on latitude
    figure
    hold all
    for i = 1: NCentroids
        Polygons{i,1} = i;

        h1 = plot(Polygons{(i),2});

        hold on;

        text(Polygons{i,4}(1,1), Polygons{i,4}(1,2), num2str(i), ...
            'FontSize', 40, 'Color', 'k', 'HorizontalAlignment', 'center');

        Polygons{i,5} = h1.FaceColor;
    end

    %% Save

    Polys = cell2table(Polygons,'VariableNames',...
        {'NCluster','Polygon','Cluster','Centroid','Color'});

    eval(['Polygons_' Var{ii+1} '= Polys;'])

    save([fsave 'Polygons_' Var{ii+1} '.mat'],...
        ['Polygons_' Var{ii+1}],'coordinates_all','-mat')


    clc

end








