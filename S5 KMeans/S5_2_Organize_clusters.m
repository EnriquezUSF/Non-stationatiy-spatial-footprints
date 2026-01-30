clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath([MF 'toolbox'])

fsave = [MF 'S5 KMeans\KMeans NOC9 - Organized\'];
mkdir(fsave)

load([MF '\S5 KMeans\KMeans_9clusters.mat'])

a = [537         164        1314         650];

%%
heads = KMeans.Properties.VariableNames;

figure%('Position',a)
for i = 2: length(heads)

    subplot(1,length(heads)-1,i-1); plot_map_text(...
        [KMeans.(heads{i}){2,1}(:,1:2), KMeans.(heads{i}){2,1}(:,4)]);
    title(heads{i})

end

%% Sort by lat

for j = 2: length(heads)

    idx   = KMeans.(heads{j}){1,1}(:,3);
    centr = KMeans.(heads{j}){2,1}(:,4);

    [~,is] = sort(KMeans.(heads{j}){2,1}(:,2)); % sort by lat

    % current name, changed name
    cn = [is, (1:1:size(is,1))'];

    for i = 1: size(cn,1)

        pos = find(idx == cn(i,1));

        KMeans.(heads{j}){1,1}(pos,3) = cn(i,2);

        pos = find(centr == cn(i,1));
        KMeans.(heads{j}){2,1}(pos,4) = cn(i,2);
    end

    [~,is] = sort(KMeans.(heads{j}){2,1}(:,2));
    KMeans.(heads{j}){2,1} = KMeans.(heads{j}){2,1}(is,:);

end

figure%('Position',a)
for i = 2: length(heads)
    subplot(1,length(heads)-1,i-1); plot_map_text(...
        [KMeans.(heads{i}){2,1}(:,1:2), KMeans.(heads{i}){2,1}(:,4)]);
    title(heads{i})

end

figure;%('Position',a)
for i = 2: length(heads)
    subplot(1,length(heads)-1,i-1); 
    plot_map_markers(...
        KMeans.(heads{i}){1,1},KMeans.(heads{i}){2,1});
    title(heads{i})
end


clear cn i j is pos centr idx ans


%% Manual correction if needed

% which season? j= 3 is ETC, j= 4 is full year
j = 3; 

% current name, changed name
cn = [2,3
    3,2
    4,6
    6,5
    5,4];

noHurr = KMeans.(heads{j}){1,1}(:,3);
noHurr2= KMeans.(heads{j}){2,1}(:,4);

for i = 1: size(cn,1)

    pos = find(noHurr == cn(i,1));

    KMeans.(heads{j}){1,1}(pos,3) = cn(i,2);

    pos = find(noHurr2 == cn(i,1));
    KMeans.(heads{j}){2,1}(pos,4)   = cn(i,2);
end

figure%('Position',a)
for i = 2: length(heads)
     subplot(1,length(heads)-1,i-1); plot_map_text(...
        [KMeans.(heads{i}){2,1}(:,1:2), KMeans.(heads{i}){2,1}(:,4)]);
    title(heads{i})
end

figure;%('Position',a)
for i = 2: length(heads)
    subplot(1,length(heads)-1,i-1); 
    plot_map_markers(...
        KMeans.(heads{i}){1,1},KMeans.(heads{i}){2,1});
    title(heads{i})
end

%% Plot

close all
figure%('Position',a)
for i = 2: length(heads)

     subplot(1,length(heads)-1,i-1); plot_map_text(...
        [KMeans.(heads{i}){2,1}(:,1:2), KMeans.(heads{i}){2,1}(:,4)]);
    title(heads{i})

end

figure%('Position',a)
for i = 2: length(heads)

    subplot(1,length(heads)-1,i-1);
    plot_map_markers(KMeans.(heads{i}){1,1},KMeans.(heads{i}){2,1}(:,1:2));
    title(heads{i})

end

%%

[~,is] = sort(KMeans.('ETC'){2,:}(:,4));
KMeans.('ETC'){2,:} = KMeans.('ETC'){2,:}(is,:);

[~,is] = sort(KMeans.('TC'){2,:}(:,4));
KMeans.('TC'){2,:} = KMeans.('TC'){2,:}(is,:);

[~,is] = sort(KMeans.('FullYear'){2,:}(:,4));
KMeans.('FullYear'){2,:} = KMeans.('FullYear'){2,:}(is,:);


%% Save

save([fsave 'KMeans_sorted.mat'], 'KMeans', '-mat');

figsave = [fsave 'figures sorted\'];
mkdir(figsave)
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = ['Fig ' num2str(get(FigHandle, 'Number')) '.png'];
    exportgraphics(FigHandle,fullfile(figsave, FigName))
end









