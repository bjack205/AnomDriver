classdef Simulator < handle
    %SIMULATOR Class for simulating anomalous drivers
    %   Overview:
    %       This class acts as a simulator for police allocation on a
    %       highway. It maintains a "scene" of drivers, each of which are
    %       defined by a set of features. The features (and their
    %       distributions) are generated by a separate CarModel class for
    %       modularity. This class samples from the CarModel class to add
    %       new vehicles to the scene. The scene is updated by receiving
    %       state, action pairs and returns appropriate rewards.
    %
    %   Important Public Methods:
    %       [sprime, reward] = Run(state,action)
    %       Returns the next state (sprime) and reward for a given state
    %       and action. 
    %       Actions can be represented by either the number of
    %       citations (action_max=1) or a vector corresponding to the
    %       length of the driver state (action_max=0)
    %       States are represented by a structure. Use StateTemplate method
    %       for a template.
    %
    %       Reset
    %       Resets the scene and the vehicle ID count
    %
    %       n_vehicles
    %       Returns the number of vehicles currently in frame
    %
    %   Important Private Methods:
    %       [reward,action] = CalcReward(state,action)
    %       Returns the reward for a given state and action. Converts the
    %       actions (action_max flag) and checks if there are enough police
    %       cars to perform the action. Outputs only valid actions.
    %
    %       UpdateScene
    %       Removes old vehicles and adds new vehicles from according to
    %       the selected CarModel. Calls CalcDriverState on the newly added
    %       vehicles.
    %
    %       CalcDriverState(vehicles)
    %       Calculates the driver state (corresponding to the citations)
    %       for a set of vehicles.
    
    properties
        % Data
        scene = [];
        citations;
        cite_logicals;
        cmodel = CarModel; % Car Model object
        
        % Rewards and citation criteria
        zero_reward = 50;       
        speed_ticket = 100;     
        weaving_ticket = 150;   
        tailgating_ticket = 200;
        no_police_cost = 100;   
        speed_limit = 29;       % m/s (65 mph)
        weaver_limit = 3;       % number of lane changes
        tailgater_limit = 1;    % average distance
        
        % Scene generation
        num_vehicles = makedist('norm','mu',10,'sigma',0);  % Number of vehicles in the frame at any time
        cur_id = 1;                                         % Next vehicle ID
        police_wait = makedist('norm','mu',5,'sigma',0);    % Number of time steps until the police are available again
        
        % Debug vars
        action_max = 1; % (1) if action is integer of number of citations to issue
                        % (0) if action is binary vector same size as state.Driver 
        print_info = 1;
        fast_mode = 1;
        
    end
    
    methods
        % Constructor
        function sim = Simulator

            % Citation structure
            use_tailgating = 0;
            sim.RewardModel(use_tailgating);

            sim.Reset;
        end
        
        % Resets the scene
        function Reset(sim)
            
            % Initalize Scene
            sim.cur_id = 1;
            if sim.fast_mode
                sim.scene = zeros(0,sim.cmodel.n_features);
            else
                sim.scene = array2table(zeros(0,sim.cmodel.n_features));
                sim.scene.Properties.VariableNames = sim.cmodel.ColNames;
            end
            sim.UpdateScene;
            
            % Initialize scene to have a uniform distibution of time steps
            initial_time = randi(sim.cmodel.mean_time,sim.n_vehicles,1);
            if sim.fast_mode
                sim.scene(:,sim.cmodel.Col('Time')) = initial_time;
            else
                sim.scene.Time = initial_time;
            end
            
        end
        
        % Executes one time step in the simulator for a given state, action
        % pair
        function [sprime,reward] = Run(sim,state,action)
            
            num_driver = length(state.Driver);
            
            % Check if vehicle IDs are valid
            [inscene,not_inscene] = sim.InScene(state.Driver_IDs);
            if ~all(inscene)
                sim.Info(sprintf('Vehicle IDs are not valid: %d\n',not_inscene))
                state.Driver = state.Driver(inscene);
                state.Driver_IDs = state.Driver_IDs(inscene);
            end
            
            % Error checking
            if sim.action_max && action>num_driver
                error('Cant''t have more actions than drivers')
            elseif ~sim.action_max && length(action)~=num_driver
                error('Size of action space must equal driver space')
            end
            
            % Assign rewards
            [reward,action] = sim.CalcReward(state,action);
            num_citations = sum(action);
            
            % Take action
            if sim.fast_mode
                [~,action_rows] = intersect(sim.scene(:,sim.cmodel.Col('ID')),state.Driver_IDs(action));
            else
                [~,action_rows] = intersect(sim.scene.ID,state.Driver_IDs(action));
            end
            sim.scene(action_rows,:) = [];
            sim.UpdateScene;
            %sim.Info(sprintf('Citing vehicle IDs: %i',state.Driver_IDs(action)));
            
            % Update state
            sprime = state;
            
            % Decrement police state
            sprime.Police = max(sprime.Police - 1,0);
            
            % Update police wait time for dispactched police vehicles
            if num_citations > 0
                next_police = find(state.Police==0,num_citations);
                sprime.Police(next_police) = round(sim.police_wait.random(1,num_citations));
            end
            
            % Update driver states with drivers with maximum reward
            sprime = sim.UpdateDriverState(sprime);
            
        end
        
        % Resets the sim and returns the initial state
        % Inputs:
        %   num_police: number of police cars
        %   num_driver: number of drivers tracked in state.Driver
        function state = Initialize(sim,num_police,num_driver,feature_distributions)
            sim.Reset;
            state = sim.StateTemplate;
            state.Police = zeros(1,num_police);
            state.Driver = zeros(1,num_driver);
            state = sim.UpdateDriverState(state);
            sim.cmodel.distributions(end:-1:end-5) = feature_distributions(end:-1:end-5);
        end
        
        % Returns the number of vehicles currently in the scene
        function n = n_vehicles(sim)
            n = size(sim.scene,1);
        end

    end
    
    methods (Access=private)
        
        % Calculates the reward for a state, action pair. The returned
        % action is guaranteed to be "valid" (all citations can be issued)
        function [reward,action] = CalcReward(sim,state,action)
            % Process state
            police_available = sum(state.Police==0);
            num_driver = length(state.Driver);
            
            % Get rewards for each driver
            driver_rewards = sim.citations.reward(state.Driver);
            
            % Sort drivers by reward
            [~,max_rewards] = sort(driver_rewards,'descend');
            
            % Convert action
            if sim.action_max
                num_action = action;
                action = false(num_driver,1);
                action(max_rewards(1:num_action)) = true;
            end
            num_citations = sum(action);
            
            % Check if citations are possible
            if num_citations > police_available
                % Only cite the cars with maximum reward
                action = false(num_driver,1);
                action(max_rewards(1:police_available)) = true;
                
                % Assign cost to bad police allocation
                reward = -sim.no_police_cost*(num_citations-police_available);
                
                %sim.Info('Assigned more citations than available cars. Assigning penalty')
            else
                reward = 0;
            end
            
            % Calculate reward
            reward = reward + sum(driver_rewards(action));
            
        end
        
        % Updates the scene by removing old vehicles and new vehicles from
        % Car Model
        function UpdateScene(sim)
            % Decrement time steps
            if sim.fast_mode
                sim.scene(:,sim.cmodel.Col('Time')) = sim.scene(:,sim.cmodel.Col('Time')) - 1;
            else
                sim.scene.Time = sim.scene.Time - 1;
            end
            
            % Remove vehicles out of frame
            if sim.fast_mode
                sim.scene(sim.scene(:,sim.cmodel.Col('Time'))<0,:) = [];
            else
                sim.scene(sim.scene.Time<0,:) = [];
            end
            
            % Add new vehicles
            cur_num_vehicles = round(sim.num_vehicles.random);
            n_new_vehicles = cur_num_vehicles - sim.n_vehicles;
            if n_new_vehicles > 0
                % Sample from CarModel
                new_vehicles = sim.cmodel.NewVehicle(sim.cur_id,n_new_vehicles);
                % Assign vehicle state
                new_vehicles(:,sim.cmodel.Col('State')) = sim.CalcDriverState(new_vehicles);
                % Append to scene
                if ~sim.fast_mode
                    new_vehicles = array2table(new_vehicles);
                    new_vehicles.Properties.VariableNames = sim.cmodel.ColNames;
                end
                sim.scene = [sim.scene;new_vehicles];
            end
            sim.cur_id = sim.cur_id + n_new_vehicles;
            
        end
        
        % Assigns the driver state based on vehicle features
        function state = CalcDriverState(sim,vehicles)
            n_vehicles = size(vehicles,1);
            is_speeder = vehicles(:,sim.cmodel.Col('maximum_velocity'))>sim.speed_limit;
            is_weaver = vehicles(:,sim.cmodel.Col('n_lane_changes'))>sim.weaver_limit;
            is_tailgater = false(n_vehicles,1);
            for i = 1:n_vehicles
                state(i) = find(sim.cite_logicals(:,1) == is_speeder(i)...
                              & sim.cite_logicals(:,2) == is_weaver(i)...& sim.cite_logicals(:,3) == is_tailgater(i)
                              );
            end
        end
        
        % Updates a state structure with the drivers in the current scene
        % with the highest reward values
        function state = UpdateDriverState(sim,state)
            num_driver = length(state.Driver);
            
            if sim.fast_mode
                rewards = sim.citations.reward(sim.scene(:,sim.cmodel.Col('State')));
            else
                rewards = sim.citations.reward(sim.scene.State);
            end
            [~,max_reward] = sort(rewards,'descend'); 
            
            if sim.fast_mode
                state.Driver = sim.scene(max_reward(1:num_driver),sim.cmodel.Col('State'));
                state.Driver_IDs = sim.scene(max_reward(1:num_driver),sim.cmodel.Col('ID'));
            else
                state.Driver = sim.scene.State(max_reward(1:num_driver));
                state.Driver_IDs = sim.scene.ID(max_reward(1:num_driver));
            end
        end
        
        % Generates the structures for the citations and rewards
        function cite_rewards = RewardModel(sim,use_tailgating)
            cite_descriptions = {...
                'No citation';...
                'Speeding';...
                'Weaving';...
                'Tailgating';...
                'Speeding + Weaving';...
                'Speeding + Tailgating';...
                'Weaving + Tailgating';...
                'Speeding + Weaving + Tailgating'};
            
            sim.cite_logicals = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 1 1 1];
            tickets = [sim.speed_ticket; sim.weaving_ticket; sim.tailgating_ticket];
            
            if ~use_tailgating
                inds = logical(sim.cite_logicals(:,3));
                cite_descriptions(inds) = [];
                sim.cite_logicals(inds,:) = [];
            end
            cite_rewards = sim.cite_logicals*tickets;
            cite_rewards(1) = sim.zero_reward;
            
            for i = 1:length(cite_rewards)
                sim.citations(i).reward = cite_rewards(i);
                sim.citations(i).descriptions = cite_descriptions{i};
            end
            sim.citations = struct2table(sim.citations);
        end
        
        function [inscene,NotValidIDs] = InScene(sim,IDs)
            if sim.fast_mode
                inscene = ismember(IDs,sim.scene(:,sim.cmodel.Col('ID')));
            else
                inscene = ismember(IDs,sim.scene.ID);
            end
            NotValidIDs = IDs(~inscene);
        end
        
        % Debug print
        function Info(sim,message)
            if sim.print_info
                fprintf('%s\n',message);
            end
        end
    end
    
    methods (Static)
        % Returns a sample state
        function state = StateTemplate
            state.Police = [];
            state.Driver = [];
            state.Driver_IDs = [];
        end
    end
    
end