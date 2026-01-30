
clear; close all; clc

MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S9 Climate indices at sizes\S3 Test significance climate indices\'];
season = 'FullYear';
fsave2 = [fsave season '\'];
mkdir(fsave2)

CI_NAMES = {'MEI','NAO','ONI'};

% Load data
load([MF 'S9 Climate indices at sizes\S2 Org data climate indices\SF_Q_CI_' season '.mat']);

% Prepare one big figure (9 clusters × 3 indices)
fig = figure;
fig.Units = 'centimeters';
fig.Position = [5 2 30 35]; % wide & tall

ha = tight_subplot(9,3,[0.02 0.04],[0.05 0.05],[0.08 0.02]); % 9 rows, 3 cols
% ha = tight_subplot(9,3,[0.02 0.04],[0.08 0.05],[0.08 0.02]);  

plot_id = 1;

for ii = 1:9
    eval(['x = Clusters.Cluster_' num2str(ii) ';']);

    categories = {'NoEvent','Q1','Q2','Q3','Q4'};
    quantile_group = categorical(repmat("",height(x),1));
    Qcols = {'Q1','Q2','Q3','Q4'};

    for q = 1:4
        quantile_group(x.(Qcols{q})==1) = Qcols{q};
    end
    noEventIdx = all(x{:,Qcols}==0,2);
    quantile_group(noEventIdx) = 'NoEvent';

    ci_names = x.Properties.VariableNames(11:end);

    % Loop climate indices (first, second, seventh variable in your dataset)
    id = 1;
    for iii = [1 2 7]
        ci = x.(ci_names{iii}); % climate index
        ax = ha(plot_id);
        axes(ax);

        boxplot(ci, quantile_group, 'Labels', categories);

        hold on;
        for k = 1:length(categories)
            ci_cat = ci(quantile_group==categories{k});
            x_jitter = randn(size(ci_cat))*0.05 + k; % small horizontal jitter
            scatter(x_jitter, ci_cat, 10, 'filled');
        end

        boxplot(ci, quantile_group, 'Labels', categories);

        % Column titles only on top row
        if ii == 1
            title(CI_NAMES{id}, 'FontSize',12,'FontWeight','bold','FontName','Times');
            as1 = get(gca,'Position');
        end

        % x-axis labels only at bottom row
        if ii == 9
            as2 = get(gca,'Position');
            set(gca,'Position',[as2(1:2) as1(3) as1(4)+0.005]);

        else
            set(gca,'XTickLabel',[]);
        end

        % Left column: add cluster label
        if iii == 1
            ylabel(sprintf('F- %d',ii), ...
                'FontSize',10,'FontName','Times');

        else
            ylabel('');
        end

        set(gca,'FontSize',12,'FontName','Times')

        id = id+1;
        plot_id = plot_id+1;
    end
end

exportgraphics(fig,[fsave2 'AllClusters_' season '_WithNumbers.jpg'],'Resolution',500);

