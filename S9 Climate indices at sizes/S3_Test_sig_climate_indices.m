%% Test significance: Climate indices as response across size quantiles including NoEvent

clear; close all; clc

MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

fsave = [MF 'S9 Climate indices at sizes\S3 Test significance climate indices\'];
season = 'FullYear';
fsave2 = [fsave season '\'];
mkdir(fsave2)

% Load data
load([MF 'S9 Climate indices at sizes\S2 Org data climate indices\SF_Q_CI_' season '.mat']);

Tsave_rev = [];

for ii = 1:9
    
    eval(['x = Clusters.Cluster_' num2str(ii) ';']);
    fprintf('Cluster %d...\n', ii);

    % Get quantiles Q1-Q4
    Qcols = {'Q1','Q2','Q3','Q4'};

    % Loop through climate indices
    ci_names = x.Properties.VariableNames(11:end);
    test_results = nan(3,length(ci_names)); % rows: ANOVA, Kruskal-Wallis, Median ranksum

    for i = 1:length(ci_names)
        ci = x.(ci_names{i}); % climate index

        % Create categorical variable including NoEvent
        quantile_group = categorical(repmat("",height(x),1));

        for q = 1:4
            quantile_group(x.(Qcols{q})==1) = Qcols{q};
        end

        % Assign NoEvent to rows not in Q1-Q4 (all Q1-Q4 == 0)
        noEventIdx = all(x{:,Qcols}==0,2); % logical index
        quantile_group(noEventIdx) = 'NoEvent';

        % 1. ANOVA (parametric)
        p_anova = anovan(ci,{quantile_group},'display','off');
        test_results(1,i) = p_anova;

        % 2. Kruskal-Wallis (non-parametric)
        p_kw = kruskalwallis(ci, quantile_group,'off');
        test_results(2,i) = p_kw;

        % % 3. Mann-Whitney / ranksum
        % % Compare extremes: Q1 vs Q4, optionally NoEvent vs Q4 if needed
        % ci_Q1 = ci(quantile_group=='Q1');
        % ci_Q4 = ci(quantile_group=='Q4');
        % p_rank = ranksum(ci_Q1, ci_Q4);
        % test_results(3,i) = p_rank;
        % Extract NoEvent group
        ci_NoEvent = ci(quantile_group=='NoEvent');

        % Combine all Q groups into one
        ci_Qall = ci(quantile_group=='Q1' | ...
            quantile_group=='Q2' | ...
            quantile_group=='Q3' | ...
            quantile_group=='Q4');

        % Mann–Whitney U test (NoEvent vs all Q’s)
        p_rank_NoEvent = ranksum(ci_NoEvent, ci_Qall);
        test_results(3,i) = p_rank_NoEvent;


    end

    % Save results in table
    T = array2table(test_results,'VariableNames',ci_names);
    fakeHeader = cell2table([{'ANOVA','KruskalWallis','Ranksum'}', repmat({['Cluster_' num2str(ii)]}, 3, 1)]);
    fakeHeader.Properties.VariableNames = {'Test','Cluster_id'};

    T = [fakeHeader, T];
    Tsave_rev = [Tsave_rev;T];
end

%% Save to Excel
writetable(Tsave_rev,[fsave2 season '-Cluster_Stats.xlsx'],'WriteRowNames',true);

%% Figure

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

    figure;

    for iii = 1:length(ci_names)

        ci = x.(ci_names{iii}); % climate index

        subplot(2,4,iii)

        hold on;
        for k = 1:length(categories)
            ci_cat = ci(quantile_group==categories{k});
            x_jitter = randn(size(ci_cat))*0.05 + k; % small horizontal jitter
            scatter(x_jitter, ci_cat, 30, 'filled');
        end

        boxplot(ci, quantile_group, 'Labels', categories);
        ylabel([ci_names{iii} ' Index']);
        % xlabel('Storm Surge Category');
    end

    % Use last subplot for cluster & season info
    subplot(2,4,8)
    axis off  % remove axes
    text(0.5,0.5, sprintf('Cluster %d\nSeason: %s', ii, season), ...
        'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold');

end

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = ['Fig ' num2str(get(FigHandle, 'Number')) '.png'];
    saveas(FigHandle, fullfile(fsave2, FigName));
end


%% INTERPRETATION
% 
% 1️⃣ ANOVA (parametric)
% 
% Purpose: Compare the mean climate index across all categories (NoEvent, Q1–Q4).
% 
% Null hypothesis (H0): The mean climate index is the same across all size categories.
% 
% Alternative hypothesis (H1): At least one category has a different mean.
% 
% Interpretation:
% 
% If p_anova < 0.05: There is a statistically significant difference in mean climate index between at least two categories.
% 
% Example: Q4 months have higher NAO than NoEvent months → extreme surges tend to occur when NAO is high.
% 
% Notes:
% 
% Parametric → assumes roughly normally distributed climate index in each category.
% 
% Sensitive to outliers.
% 
% 2️⃣ Kruskal-Wallis (non-parametric ANOVA)
% 
% Purpose: Compare the distributions of climate index across categories, without assuming normality.
% 
% Null hypothesis (H0): The distribution of the climate index is the same across all categories.
% 
% Alternative hypothesis (H1): At least one category differs in distribution.
% 
% Interpretation:
% 
% If p_kw < 0.05: The climate index distribution differs among categories (not just mean).
% 
% More robust than ANOVA if CI is skewed or has outliers.
% 
% Useful to confirm ANOVA results in case normality is questionable.
% 
% 3️⃣ Mann–Whitney U test (Ranksum)
% 
% Purpose: Compare the distribution of climate index between two categories.
% 
% In your code: Q1 vs Q4 (smallest vs largest surges).
% 
% Can also be adapted to Q4 vs NoEvent to see if extreme surges occur under distinct climate conditions.
% 
% Null hypothesis (H0): The two distributions are identical (medians are the same).
% 
% Alternative hypothesis (H1): The distributions differ.
% 
% Interpretation:
% 
% If p_rank < 0.05: The two categories have significantly different climate index values.
% 
% Example: NAO is significantly higher during Q4 months compared to Q1 → extreme surges occur during positive NAO phases.
% 
% Notes:
% 
% Non-parametric → robust to skewed data and outliers.
% 
% Only compares two categories at a time, unlike ANOVA/Kruskal-Wallis.
% 
% 🔹 Putting them together
% Scenario	Interpretation
% Only ANOVA significant	Means differ, but differences might be subtle, check post-hoc for which categories.
% Only Kruskal-Wallis significant	Distributions differ, possibly due to skewness or outliers, not just mean.
% Only Ranksum significant	Extreme differences exist between two selected categories (e.g., Q1 vs Q4).
% All three significant	Strong evidence that the climate index varies systematically across size categories, including NoEvent.

