clear; close all; clc

% Main folder
MF = 'C:\Users\enriqueza\Documents\Seasonal variations 4\S8 Decadal changes\';
addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S8_2_KMeans\'];
% mkdir(fsave)

% Number of clusters
NC = 9;

tw = 10;

load([MF 'S8_1_Time_Windows\Time_windows_independent_'...
    num2str(tw) '_yr.mat']);

%% KMeans
c = 1;
R = {};
for j = 1: length(surge_tw)

    disp(j)

    data = surge_tw{j};
    time = time_tw{j};

    % Preprocessing
    data(isnan(data)) = 0;

    rng(1);
    opts = statset('Display','off');

    % KMeans
    [idx,C,sumd,D]= kmeans(data,NC,'Distance','correlation',...
        'Replicates',50,'Options',opts,'OnLinePhase','on');

    cidx = [coordinates,idx];

    % centroids
    poscentr = nan(NC,1);
    for i = 1: NC
        fi = find(abs(D(:,i))== min(abs(D(:,i))));
        poscentr(i) = fi(1);
    end
    centr = coordinates(poscentr,:);

    R{c,1} = cidx;
    R{c,2} = [centr poscentr (1:1:length(centr))'];

    c = c+1;

    % Plot
    figure
    plot_map_markers(cidx,centr)

    for ii = 1: size(centr,1)
        h= m_text(centr(ii,1),centr(ii,2),num2str(ii),...
            'FontSize',16,'FontName', 'Times','Color','k',...
            'BackgroundColor','none','FontWeight','bold','LineWidth',2,...
            'EdgeColor','none');
    end

    yy = datevec(time);
    yy = [min(yy(:,1)) max(yy(:,1))];

    title([num2str(yy(1)) ' to ' num2str(yy(2))])
end

%% Save figures
figsave = [fsave 'figures\'];
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
R = [N,R];

heads = {};
for i = 1: length(surge_tw)
    heads{i} = ['TW_' num2str(i)];
end

KMeans = cell2table(R,'VariableNames',['Data',heads]);

save([fsave 'KMeans.mat'], 'KMeans', 'time_tw', '-mat');

close all;

clearvars -except fsave MF tw NC




