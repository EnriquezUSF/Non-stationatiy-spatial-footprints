clear; close all; clc

% Main folder
MF = [pwd 'Seasonal variations 4\'];
addpath(genpath([MF 'toolbox']))

% time window (years)
tw = 10;

fsave = [MF '\S8 Decadal changes\S8_1_Time_Windows\'];
mkdir(fsave)

load([MF 'S3 Extremes\NTR_Extr.mat']);
data = NTR_Extr;
time = Time_extr;

clear NTR_Extr Time_extr

%% Time Windows

dates = datevec(time);
years = unique(dates(:,1));

shift = 10; % year

% number of time windows
Ntw     = round(length(years)/shift);

idtw    = {};
c       = 1;

surge_tw = {};
time_tw  = {};

for i = 1: Ntw    

    % keep years within time window
    idtw{i,1} = years(c:c+tw-1);

    % locations for those years
    f = [];
    for ii = 1: length(idtw{i,1})
        fii = find(dates(:,1) == idtw{i,1}(ii));
        f = cat(1,f,fii);
    end

    surge_tw{i,1} = data(:,f);
    time_tw{i,1}  = time(f);

    c = c+shift;
end

clear ii fii f i c Ntw shift

%% last time window (can be of different size when Ntw is rounded)
fend = idtw{end,1}(end);
if fend< max(years)

    idtw{size(idtw,1)+1,1} = years(c:end);

    f = [];
    for ii = 1: length(idtw{end,1})
        fii = find(dates(:,1) == idtw{end,1}(ii));
        f = cat(1,f,fii);
    end

    surge_tw{end+1,1} = POT_gentime(:,f);
    time_tw{end+1,1}  = time(f);

end

save([fsave 'Time_windows_independent_' num2str(tw) '_yr.mat'],...
    'surge_tw','time_tw','coordinates','idtw','-v7.3')











