%%% Calucalting extremes based on a threshold

clear; close all; clc

% Main folder
MF = 'D:\Temporal variations SF\Seasonal variations 4\';

% Directories
fsave = ([MF 'S3 Extremes\']);
mkdir(fsave)

load ([MF 'S2 NTR\NTR_det.mat'])

coordinates = lonlat;
clear lonlat

%% Same quantile for tropical and no-tropical season
% data has been yearly detrended when calculating the skew surges

% Criteria to define extremes: 95th
th = 99;

Qs = nan(length(coordinates),1);

for i = 1: length(coordinates)
    Qs(i) = quantile(NTR(i,:),th/100);
end

figure; plot_map([coordinates,Qs]);
colorbar
title('99th quantile, hourly data')

%% POT
NTR_POT = nan(size(NTR));

for i = 1: size(coordinates,1) % through each model point

    disp(i)

    ts = NTR(i,:);
    qi = Qs(i);

    ts(ts<qi) = nan;

    % Independency between events
    [~,Pos] = Ind_cond([time, ts']);

%     figure; hold all
%     h2 = plot(time,NTR(i,:),'.-','Color',rgb('DarkRed')); % 'DarkBlue
%     datetickzoom
%     plot(time,repmat(qi,length(time),1),'--k','LineWidth',2)
%     plot(time(Pos),ts(Pos),'s','Color',rgb('DarkRed'))
% 
%     ylabel('NTR (m)')
%     set(gca,'FontSize',12,'FontName','Times')

    NTR_POT(i,Pos) = ts(Pos);

end


%% Remove dates without data
NTR_Extr = NTR_POT;

NTR_Extr(isnan(NTR_Extr)) = zeros;
NTR_Extr(NTR_Extr~= 0)    = ones;

nevents = sum(NTR_Extr,1);

% dates without events anywhere
fout = find(nevents== 0);

% remove times when nowhere exceeded the threshold
Time_extr       = time;
Time_extr(fout) = [];
NTR_Extr        = NTR_POT;
NTR_Extr(:,fout)= [];

%% Save

save([fsave 'NTR_POT.mat'],...
    'NTR_POT','time','coordinates','-v7.3')

save([fsave 'NTR_Extr.mat'],...
    'NTR_Extr','Time_extr','coordinates','-v7.3')








