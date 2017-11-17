% Read 101 data
addpath('data')
filename = 'i101_trajectories-0750am-0805am.txt';
if ~exist('data','var')
    data = dlmread(filename);
end

return;

tstart = min(data(:,4));
time = (data(:,4)-tstart)/1000; % Scale to seconds and start at t=0
tfinal = max(time);

int_time = 30; % Interval time, in seconds

intervals = 0:int_time:tfinal;

for i = 1:length(intervals-1)
    data_segment = data(time>intervals(i) & time<=intervals(i+1),:);
    car_ids = unique(data_segment(:,1));
    for j = 1:length(car_ids)
        inds = data_segment(:,1) == car_ids(j);
        ID = car_ids(j);
        vel = mean(data_segment(inds,12)); % 
        len = mean(data_segment(inds,9)); % Vehicle length
        
    end
end