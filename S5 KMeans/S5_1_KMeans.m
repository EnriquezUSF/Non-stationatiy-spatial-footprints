clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath([MF 'toolbox'])

fsave = [MF 'S5 KMeans\'];

load([MF '\S4 Seasons\Ext_NTR_Season.mat'])

data = Ext_NTR_Season;

%% Number of clusters
% close all
clc
c = 1;
NC = 9; % 9:12

figure(c)
set(gcf,'Position',[1          49        1920         955])
figure(c+1)
set(gcf,'Position',[1          49        1920         955])

c = c+2;

% KMeans
R = {};

for j = 1:3 %  size(data,2)

    disp(j)

    %% Data

    data_j = data{2,j};
    time   = Time{2,j};

    % Preprocessing
    data_j(isnan(data_j)) = 0;

    %% KMeans

    rng(1);
    opts = statset('Display','off');

    % KMeans
    [idx,C,sumd,D]= kmeans(data_j,NC,'Distance','correlation',...
        'Replicates',50,'Options',opts,'OnLinePhase','on');

    cidx = [coordinates,idx];

    % centroids
    poscentr = nan(NC,1);
    for i = 1: NC
        fi = find(abs(D(:,i))== min(abs(D(:,i))));
        poscentr(i) = fi(1);
    end
    centr = coordinates(poscentr,:);

    figure(1);
    subplot(1,3,j);
    plot_map_text([centr,(1:1:length(centr))']);
    title(data{1,j})

    R{j,1} = cidx;
    R{j,2} = [centr poscentr (1:1:length(centr))'];

    % Plot
    figure(2);
    subplot(1,3,j)
    plot_map_markers(cidx,centr);

    title([data{1,j} ', ' num2str(NC) ' clusters'])


end


%% Save figures
figsave = [fsave 'NoC ' num2str(NC) '\'];
mkdir(figsave)
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

for iFig = 1:length(FigList)

    FigHandle = FigList(iFig);

    FigName   = ['Fig ' num2str(get(FigHandle, 'Number')) '.png'];

    exportgraphics(FigHandle,fullfile(figsave, FigName))

end

%% Save results

R = R';
N = {'Idx';'Centroids_Lon_Lat_pos_ID'};
R2 = [N,R];

heads = data(1,:);

KMeans = cell2table(R2,'VariableNames',['Data',heads]);

save([fsave 'KMeans_' num2str(NC) 'clusters.mat'], 'KMeans', '-mat');

close all
% beep

