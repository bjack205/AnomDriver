%READH5DATA
% ReadH5Data Script
%   OVERVIEW:
%   Reads the smoothed NGSIM data provided by Blake Wulfe
%   Generates a sample set by averaging data over set intervals of time (15 seconds by default)
%   Does not compute sample that do have data for the entire interval
%
%   IMPORTANT VARIABLES:
%   'X': output array of samples
%   'features': structure containing info about the features extracted for each sample

n_samples = 0;
num_IDs = 0;

% Parameters
lane_change_threshold = 3;  % meters
ts = 0.1;                   % sample time (s)
t_int = 15;                 % time interval (s)
t_win = 5;                  % time window step (s)
s_int = t_int/ts;           % timestep interval
s_win = t_win/ts;            
datasets = 1:3;             % specify which dataset to read from H5 file
savedata = 0;               % flag to save data

% Read Smoothed Data
filename = 'C:\Users\bjack\Documents\NGSIM Data\ngsim_feature_trajectories.h5';
info = h5info(filename);

% Loop over datasets in the h5 file
for dataset = 1:3
    
    % Avoid unnecessary data loading
    if ~exist('data','var')
        data = h5read(filename,sprintf('/%d',dataset));
        
        % Rearrange data
        data = permute(data,[2,3,1]);
    end
    
    % Get array size
    n_features = size(data,3);
    n_timesteps = size(data,1);
    n_vehicles = size(data,2);
    
    % Feature names
    feature_names = info.Attributes.Value;
    feature_inds = containers.Map(feature_names,1:n_features);
    
    % Get data lengths
    len = zeros(1,n_vehicles);
    for i = 1:n_vehicles
        lastind = find(data(:,i,1),1,'last');
        if isempty(lastind)
            lastind = n_timesteps;
        end
        len(i) = lastind;
    end
    
    % Create samples
    %intervals = 0:s_int:n_timesteps;
    start_times = 0:s_win:n_timesteps-s_int;
    n_samples_dataset = n_samples;
    for i = 1:length(start_times)
        %inds = intervals(i)+1:intervals(i+1);
        inds = start_times(i)+1:start_times(i)+s_int;
        full_sample = len>inds(end);
        subdata = data(inds,full_sample,:);
        n_subsamples(i,dataset) = size(subdata,2);
        if n_subsamples(i,dataset) == 0
            a = 1;
        end
        
        v_idx = find(full_sample);
        n_lane_changes = sum(abs(diff(subdata(:,:,1)))>lane_change_threshold);
        avg_vel = sum(subdata(:,:,feature_inds('velocity')))/s_int;
        max_vel = max(subdata(:,:,feature_inds('velocity')));
        avg_acc = sum(subdata(:,:,feature_inds('accel')))/s_int;
        avg_pos = sum(subdata(:,:,feature_inds('relative_offset')))/s_int;
        std_pos = sum(subdata(:,:,feature_inds('relative_offset')));
        
        X(n_samples+1:n_samples+n_subsamples(i,dataset),:) = [v_idx;n_lane_changes; avg_vel; max_vel; avg_acc; avg_pos; std_pos]';
        n_samples = size(X,1);
    end
    
    % Assign sequential vehicle id's
    [dataset_IDs,ia,ic] = unique(X(n_samples_dataset+1:end,1));
    num_IDs_dataset = length(dataset_IDs);
    seq_IDs = (1:num_IDs_dataset)'+num_IDs;
    seq_IDs = seq_IDs(ic);
    X(n_samples_dataset+1:end,1) = seq_IDs;
    num_IDs = num_IDs+num_IDs_dataset;
    
    if length(datasets)>1
        clear data
    end
end

% Document Feature Set
n_features = size(X,2);
feature_names = {'v_idx','n_lane_changes','average_velocity','maximum_velocity','average_accel','average_position','std_position'};
feature_descriptions = {...
    'Unique Vehicle ID. Re-assigned to be sequential for the current data set',...
    'Number of lane changes during the sample period. Detected when there is a jump in lane position of more than lane_change_threshold.',...
    'Average velocity of the vehicle',...
    'Maximum velocity of the vehicle',...
    'Average acceleration of the vehicle',...
    'Average deviation from lane center'...
    'Standard deviation of the deviation from lane center'};
feature_units = {'','','m/s','m/s','m/s/s','m','m'};
for i = 1:n_features
    features(i).names = feature_names{i};
    features(i).units = feature_units{i};
    features(i).description = feature_descriptions{i};
end
clear feature_names feature_descriptions feature_units

if savedata
    save('trainingdata_1sec_window','X','features')
end