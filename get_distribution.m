function [feature_dist] = get_distribution(feature_data)
% create distribution for simulator
num_features_dist = 6;
feature_dist = cell(num_features_dist,1);
for i=2:7
    if i==5
        % use theoretically optimal bandwidth
        feature_dist{i-1} = fitdist(feature_data(:,i),'kernel');
    else        
        feature_dist{i-1} = fitdist(feature_data(:,i),'kernel','Bandwidth',1);
    end
end
end