clear; close all; 
clc

% data
cd([MF 'S4 Climate indices\S2 Climate indices\climate indices'])

fsave = [MF 'S4 Climate indices\S2 Climate indices\climate indices mat\'];
mkdir(fsave)

%% Read data

fname = 'nina34.anom.data.txt';

fid = fopen(fname);
C   = textscan(fid,'%s','delimiter','\n');
fclose(fid);

C = C{1,1};

a   = C{1,:};
val = sscanf(a,'%f');

nyears = val(2) - val(1) + 1;

years= nan(nyears,1);
data = nan(nyears,12);

C = C(2:end,:);

for i = 1: nyears

    a   = C{i,:};
    val = sscanf(a,'%f');

    if val(1) == -99.99
        break
    end

    years(i)  = val(1);
    data(i,:) = val(2:end)';

end

data = data';
data = data(:);

%%

time = nan(nyears,12);

for i = 1: length(years)

    for ii = 1:12
        time(i,ii) = datenum([years(i) ii 1 1 1 1]);
    end

end

time = time';
time = time(:);

data(data<= -99.9) = NaN;

%%

x9 = time;
y9 = data;

above = y9;
below = y9;
above = above .* (above >= 0);
below = below .* (below <= 0);

figure('Position',1.0e+03 *[0.0010    0.0410    1.5360    0.7488]);
a1 = area(x9, above, 'FaceColor', 'r','EdgeColor',[.7 .7 .7]);
hold on;
area(x9, below, 'FaceColor', 'b','EdgeColor',[.7 .7 .7]);

% xlim([datenum([1984 12 1 1 1 1]) max(time)])
datetickzoom('x','KeepLimits')

% ylim([-5 5])

grid minor
grid on

title(fname)

%% save

CI_time = time;
CI_data = data;

save([fsave fname '.mat'],'CI_time','CI_data','-mat')











