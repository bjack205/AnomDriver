% Taylor Howell
% AnomDriver
% tests of simulator for MDP solver implementation

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
num_driver_infractions = min(4,size(sim.citations,1)); % number of unique infractions a driver can be guilty of
%%%
num_police_wait = sim.police_wait.ParameterValues(1)+1; % number of values each police can be in
num_actions = num_police + 1; % number of availabe actions 
num_states = (num_police_wait^num_police)*(num_driver_infractions^num_driver); % cardinality of state space

% initialize counts
N = ones(num_states, num_actions, num_states); % count for N(s,a,s')
rho = zeros(num_states, num_actions); % count for rho(s,a)

% initialize MDP
U = zeros(num_states,1); 
T = 1/num_states*ones(num_states, num_actions, num_states); % transition probability T(sp|s,a) -> T(s,a,sp)
R = zeros(num_states, num_actions);

%% state to state index (state_ind)
state_ind = state_to_index( state,num_police_wait,num_driver_infractions )

action = eps_greedy(U,state_ind,num_states,num_actions,T,R,gamma,eps)
    



