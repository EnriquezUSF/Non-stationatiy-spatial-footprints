%% Assuming you have Cluster_1 ... Cluster_9 tables
close all; clc; clear

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

season = 'FullYear';

load([MF 'S7 Weather composites\Plots FullYear\Composites_' season '.mat'])

coastline = load('Coastline_North_Atlantic.mat');

fsave = [MF 'S7 Weather composites\Plots ' season '\Original scale\'];
% mkdir(fsave)

%%
Clusters = {Cluster_1, Cluster_2, Cluster_3, Cluster_4, Cluster_5, Cluster_6, Cluster_7, Cluster_8, Cluster_9};
nClusters = length(Clusters);

% Number of quantiles (assumes all clusters have same number of quantiles)
nQuantiles = height(Clusters{1});

% Determine global min/max for colormap scaling
all_msl = [];
for c = 1:nClusters
    for q = 1: nQuantiles
    all_msl = cat(3, all_msl, Clusters{c}.MSLP{q,1}');
    end
end
% zlim = [min(all_msl(:)) max(all_msl(:))];

% zlim = 1.0e+05.*([1    1.0240]); % 0.999  1.0240
% zlim = ([0.3765 2.1284]); % 0.999  1.0240 % if rescale
zlim = [100376.5 102128.4]./100; % if not rescale

for q = 1 :nQuantiles
    
    % Create figure
    hf = figure('Name', ['Quantile ' num2str(q)], 'NumberTitle','off');
    hf.Units = 'centimeters';
    hf.Position = [8.0000    2   16.9502   14.7373];

    ni = 3;
    nj = 3;

    ha = tight_subplot(nj,ni,[0.02 .025],[.08 0.05],[.004 .004]);

    for c = 1:nClusters
        % Select subplot
        axes(ha(c));

        % Extract data for this cluster and quantile
        msl = Clusters{c}.MSLP{q,1}';
        u   = Clusters{c}.U10{q,1}';
        v   = Clusters{c}.V10{q,1}';

        msl = msl./100;
        % msl = (msl-1.0e+5)/1000; % if rescale

        plot_map_subplot(msl,u,v,lon,lat,coastline,zlim); % 
                % plot_maps(msl,u,v,lon,lat,coastline); % 
        title(['F-' num2str(c)]);
    end
    cb = colorbar;
    cb.Location = 'southoutside';
    cb.Position(1) = 0.2;
    cb.Position(2) = 0.07;
    cb.Position(3) = 0.6;
    cb.Position(4) = 0.02;
end

%% Save
cd(fsave)

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = ['Fig ' num2str(get(FigHandle, 'Number')) '.png'];

    % Save with specific size
    % hf.PaperUnits = 'centimeters';
    % hf.PaperPosition = [0 0 16.97 39.69];

    exportgraphics(FigHandle,FigName,'Resolution',500)

end

%% Modified plotting function to use current axes
function plot_map_subplot(msl,u,v,lon,lat,coastline,zlim) % 
    hold on;
    
    [lonmesh,latmesh] = meshgrid(lon,lat);

    m_proj('miller','long',[min(lon) max(lon)],...
        'lat',[min(lat) max(lat)]);

    m_grid('tickdir','in','linest','none',...
        'FontName','Times','FontSize',12 ,'xticklabels',[],'yticklabels',[]);
    m_coast('patch',[.7 .7 .7],'edgecolor','k');

    m_pcolor(lon,lat,msl);
    clim(zlim);

    load('vik');  % your colormap
    colors = vik;
    colormap(colors);

    % reduce resolution for wind arrows
    [nrows,ncols] = size(msl);
    red = 16;
    uA = imresize(u, [nrows/red, ncols/red]);
    vA = imresize(v, [nrows/red, ncols/red]);
    y_red = imresize(latmesh, [nrows/red, ncols/red]);
    x_red = imresize(lonmesh, [nrows/red, ncols/red]);

    qp = m_quiver(x_red,y_red,uA,vA,'k');
    % set(qp,'LineWidth',.5,'MaxHeadSize',.1,...
    %     'AutoScaleFactor',2,'Color', [.2 .2 .2]);
    set(qp,'LineWidth',0.5,'MaxHeadSize',0.1,'AutoScaleFactor',2,'Color',[0.2 0.2 0.2]);

    m_line(coastline.lonlat(:,1),coastline.lonlat(:,2),...
        'Marker','o','MarkerFace','k','MarkerEdge','k',...
        'Linest','none','markersize',.5);

    set(gca,'FontSize',12,'FontName','Times','FontWeight','normal');

    % cb = colorbar;
    % cb.Location = 'southoutside';
    % cb.Position(2) = cb.Position(2) - 0.06;
    % cb.Position(4) = 0.01;

end


