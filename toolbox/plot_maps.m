function plot_maps(msl,u,v,lon,lat,coastline)

figure;

[lonmesh,latmesh] = meshgrid(lon,lat);

hold on
m_proj('miller','long',[min(lon) max(lon)],...
    'lat',[min(lat) max(lat)]);

m_grid('tickdir','in','linest','none',...
    'FontName','Times','FontSize',12 ,'xticklabels',[],'yticklabels',[]);
m_coast('patch',[.7 .7 .7],'edgecolor','k');

hold on;
m_pcolor(lon,lat,msl);

load('vik');
colors = vik;
colormap(colors);

% wind ------------------------------------
% reduce resolution to plot
[nrows,ncols]= size(msl);

red     = 8;
uA      = imresize(u, [nrows/red, ncols/red]);
vA      = imresize(v, [nrows/red, ncols/red]);
y_red   = imresize(latmesh, [nrows/red, ncols/red]);
x_red   = imresize(lonmesh, [nrows/red, ncols/red]);

qp = m_quiver(x_red,y_red,uA,vA,'k');
set(qp,'LineWidth',.5,'MaxHeadSize',.1,...
    'AutoScaleFactor',2,'Color', [.2 .2 .2]) % [.2 .2 .2]

hs= m_line(coastline.lonlat(:,1),coastline.lonlat(:,2),...
    'Marker','o','MarkerFace','k','MarkerEdge','k',...
    'Linest','none','markersize',.5);

set(gca,'FontSize',12,'FontName','Times','FontWeight','normal')

cb = colorbar;
cb.Location = 'southoutside';
% cb.Position(1) = 0.025;
% cb.Position(2) = 0.035;
% cb.Position(3) = .95;



