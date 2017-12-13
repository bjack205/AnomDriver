% Efficiency test
% explore only updating the states that the simulator actually produces

clear;clc;close all;

% solve MDP
load('feaDistributions.mat')

% MDP parameters
MDP.num_police = 1; % number of police
MDP.num_driver = 2; % number of anomalous 
MDP.sim = Simulator; % create an instance of the simulator
MDP.num_driver_infractions = size(MDP.sim.citations,1); % number of unique infractions a driver can be guilty of
MDP.num_police_wait = MDP.sim.police_wait.ParameterValues(1)+1; % number of values each police can be in
MDP.num_actions = MDP.num_police + 1; % number of availabe actions 
MDP.feature_dist = feature_dist;
MDP.lookup = unique_states(@state_to_index,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);
MDP.num_states = size(MDP.lookup,1); % cardinality of state space
MDP.s0 = Initialize(MDP.sim,MDP.num_police,MDP.num_driver,MDP.feature_dist); % initial state

%MDP.sim.citations.rewards = [0;10;100;1000];
% solver parameters
params.gamma = 0.9; % discount factor
params.eps = 0.1; % exploration factor
params.decay = 0; % rate of decay for eps
params.policy = 'eps_greedy'; % specify exploration strategy *NOTE: add decaying eps-greedy policy option
params.tolerance=0.005; % value iteration convergence criteria
params.num_update = 100; % number of iterations before updating the MDP model
params.NO_LEARNING_THRESHOLD = 10; % number of consecutive 1-iteration convergence of value function 
params.backup = 1000; % number of iterations before storing value function again


%%
cache = 0; %boolean determines if we store MDP every 'backup' epochs 
tic;
solution = MDPsolver_reduced(MDP, params, cache);
toc;

%% save model
U = solution(end).U;
T = solution(end).T;
R = solution(end).R;
gamma = params.gamma;

%M = indexed_states(@state_to_index,U,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions );