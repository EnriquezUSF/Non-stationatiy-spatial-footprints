function [detrended_data, trend] = det_year_running_window(sl)
% Detrends a time series.
%
% Inputs: sl (hourly sea level data, no NaNs), no time
% Outputs: detrended data (detrended sea level data) and trend (same length
% as detrended data)
%
% Length of time window (year at hourly resolution)
time_window = 365*24;

values = sl;

% Moving average detrending

% Calculate moving average
half_width = floor(time_window/2);
trend = movmean(values, time_window, 'Endpoints', 'shrink');

% Handle endpoints
if length(values) > time_window
    % Beginning of series
    for i = 1:half_width
        trend(i) = mean(values(1:(i+half_width)));
    end

    % End of series
    for i = (length(values)-half_width+1):length(values)
        trend(i) = mean(values((i-half_width):end));
    end
end

% Detrend by removing moving average and adding present day average
detrended_data = values - trend;

