classdef CarModel
    %CARMODEL Creates distributions of vehicle features
    %   Class for generating new vehicle samples
    %   Distributions defined in the constructor
    %   Uses features from feature structure in trainingdata.mat
    
    properties
        features;
        distributions;
        ColNames;
        header_cols = 3;
    end
    
    methods
        function obj = CarModel
            % Probability distribution
            obj.distributions = {...
                0;...                                       vehicle id
                0;...                                       state
                makedist('norm','mu',5,'sigma',0);...       time steps
                makedist('exponential','mu',2);...          n_lange_changes
                makedist('norm','mu',30,'sigma',5);...      avg_velocity
                makedist('norm','mu',35,'sigma',5);...      max velocity
                makedist('norm','mu',1,'sigma',0.1);...     avg acceleration
                makedist('norm','mu',0,'sigma',0.2);...     lane deviation
                makedist('norm','mu',0.2,'sigma',0.2);...   std lane deviation
                };
            
            % Populate cols
            features = load('trainingdata.mat','features');
            features = features.features;
            obj.ColNames{1} = 'ID';     % Assigned by Simulator
            obj.ColNames{2} = 'State';  % Assigned by Simulator
            obj.ColNames{3} = 'Time';   % Time in frame. Initialized by model, updated by Simulator.
            for i = 2:length(features)
                obj.ColNames{i+obj.header_cols-1} = features(i).names;
            end
        end
        
        % Return Column number
        function col = Col(obj,name)
            col = find(strcmp(name,obj.ColNames));
        end
        
        % Number of features
        function n = n_features(obj)
            n = length(obj.ColNames);
        end
        
        % Mean time vehicles are in frame (used when initializing Sim)
        function t = mean_time(obj)
            t = mean(obj.distributions{obj.Col('Time')});
        end
        
        % Generate new samples from distribution
        function vehicles = NewVehicle(obj,start_id,n_vehicles)
            vehicles = zeros(n_vehicles,obj.n_features);
            
            % Sample from distributions
            for i = obj.header_cols:obj.n_features
                vehicles(:,i) = obj.distributions{i}.random(n_vehicles,1);
            end
            
            % Assign ids
            vehicles(:,1) = (start_id:start_id+n_vehicles-1)';
            
            
        end
    end
    
end

