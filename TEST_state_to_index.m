% test state_to_index function

clear;clc;close all;

clear;clc;close all;
%%% Variables we can change

% determine size of state space
num_police = 2; % number of police
num_driver = 4; % number of anomalous 

gamma = 0.9;
eps = 0.1;

tolerance=0.01;

NO_LEARNING_THRESHOLD = 20;
NOCLT = 0;

%%%

% create an instance of the simulator
sim = Simulator; 
% initialize state
state = Initialize(sim,num_police,num_driver);

%%FIX ONCE SIMULATOR IS UPDATED
num_driver_infractions = size(sim.citations,1); % number of unique infractions a driver can be guilty of
%%%
num_police_wait = sim.police_wait.ParameterValues(1)+1; % number of values each police can be in
num_actions = num_police + 1; % number of availabe actions 
num_states = (num_police_wait^num_police)*(num_driver_infractions^num_driver); % cardinality of state space

IND = []
for i = 0:num_police_wait-1;
    for j = 0:num_police_wait-1;
        for k = 1:num_driver_infractions
            for l = 1:num_driver_infractions
                for m = 1:num_driver_infractions
                    for n = 1:num_driver_infractions
                        state.Police = [i j];
                        state.Driver = [k l m n];
                        IND = cat(1,IND,state_to_index( state,num_police_wait,num_driver_infractions));
                    end
                end
            end
        end
    end
end

length(unique(IND))