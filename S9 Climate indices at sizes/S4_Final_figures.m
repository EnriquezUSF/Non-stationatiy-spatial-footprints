%% Test significance: Climate indices as response across size quantiles including NoEvent

clear; close all; clc

MF = 'C:\Users\enriqueza\OneDrive - University of South Florida\Working papers\Paper spatial footprints\Seasonal variations 4\';
addpath(genpath('C:\Users\enriqueza\OneDrive - University of South Florida\matlab_toolboxes'))
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S9 Climate indices at sizes\S3 Test significance climate indices\'];
season = 'FullYear';
fsave2 = [fsave season '\'];
mkdir(fsave2)

CI_NAMES = {'MEI','NAO','ONI'};

% Load data
load([MF 'S9 Climate indices at sizes\S2 Org data climate indices\SF_Q_CI_' season '.mat']);

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

    fig = figure;
    fig.Units = 'centimeters';
    % fig.Position(1) = 5;
    % fig.Position(3) = 30;
    fig.Position(4) = 8;

    ha = tight_subplot(1,3,[0 .045],[.05 0.1],[.08 .001]);

    id = 1;
    for iii = [1 2 7]

        ci = x.(ci_names{iii}); % climate index

        % subplot(1,3,id)
        axes(ha(id));

        hold on;
        for k = 1:length(categories)
            ci_cat = ci(quantile_group==categories{k});
            x_jitter = randn(size(ci_cat))*0.05 + k; % small horizontal jitter
            scatter(x_jitter, ci_cat, 30, 'filled');
        end

        boxplot(ci, quantile_group, 'Labels', categories);
        ylabel(CI_NAMES{id});
        id = id+1;

        set(gca,'FontSize',12,'FontName','Times')

    end

    % Use last subplot for cluster & season info
    % subplot(2,4,8)
    % axis off  % remove axes
    % text(0.5,0.5, sprintf('Cluster %d\nSeason: %s', ii, season), ...
    %     'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');
    sgtitle(['Cluster ' num2str(ii) ', ' season], ...
        'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold','FontName','Times');

    % exportgraphics(fig,...
    % [fsave2 'Cluster ' num2str(ii) ', ' season '.jpg'],...
    % 'Resolution',500)

end

