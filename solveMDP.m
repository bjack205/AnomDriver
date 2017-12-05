clear;clc;close all;

%% solve MDP
load('feaDistributions.mat')

% MDP parameters
MDP.num_police = 1; % number of police
MDP.num_driver = 2; % number of anomalous 
MDP.sim = Simulator; % create an instance of the simulator
MDP.num_driver_infractions = size(MDP.sim.citations,1); % number of unique infractions a driver can be guilty of
MDP.num_police_wait = MDP.sim.police_wait.ParameterValues(1)+1; % number of values each police can be in
MDP.num_actions = MDP.num_police + 1; % number of availabe actions 
MDP.num_states = (MDP.num_police_wait^MDP.num_police)*(MDP.num_driver_infractions^MDP.num_driver); % cardinality of state space
MDP.feature_dist = feature_dist;
MDP.s0 = Initialize(MDP.sim,MDP.num_police,MDP.num_driver,MDP.feature_dist); % initial state

% solver parameters
params.gamma = 0.9; % discount factor
params.eps = 0.1; % exploration factor
params.decay = 0; % rate of decay for eps
params.policy = 'eps_greedy'; % specify exploration strategy *NOTE: add decaying eps-greedy policy option
params.tolerance=0.01; % value iteration convergence criteria
params.num_update = 50; % number of iterations before updating the MDP model
params.NO_LEARNING_THRESHOLD = 10; % number of consecutive 1-iteration convergence of value function 
params.backup = 1000; % number of iterations before storing value function again

tic;
solution = MDPsolver(MDP, params);
toc;

%% save model
U = solution(end).U;
T = solution(end).T;
R = solution(end).R;
gamma = params.gamma;
save('mdp_solution','T','R','U','gamma');
state_table = indexed_states(@state_to_index,U,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);

%% Plot cumulative reward over epochs
NUM_ITERATIONS = 500; % number of timesteps to evaluate a policy
NUM_EVALS = 5; % number of times to evaluate each policy on a newly initialized scene
R = zeros(size(solution,1),NUM_EVALS);
R_naive = zeros(size(solution,1),NUM_EVALS);
R_random = zeros(size(solution,1),NUM_EVALS);
naivePolicy_ind = NaivePolicy(@state_to_index,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);
randomPolicy_ind = randi([1 MDP.num_actions],1,MDP.num_states);

figure
hold on
for i = 1:max(size(solution))
    [policy_ind,~] = CalculatePolicy(solution(i).U,solution(i).T,solution(i).R,params.gamma);
    for j = 1:NUM_EVALS
        R(i,j) = EvaluatePolicy(policy_ind,MDP,NUM_ITERATIONS);
        R_naive(i,j) = EvaluatePolicy(naivePolicy_ind,MDP,NUM_ITERATIONS);
        R_random(i,j) = EvaluatePolicy(randomPolicy_ind,MDP,NUM_ITERATIONS);
    end
end

errorbar([solution(2:end).epoch],mean(R(2:end,:),2)./NUM_ITERATIONS,std(R(2:end,:),0,2)./NUM_ITERATIONS);
errorbar([solution(2:end).epoch],mean(R_naive(2:end,:),2)./NUM_ITERATIONS,std(R_naive(2:end,:),0,2)./NUM_ITERATIONS);
errorbar([solution(2:end).epoch],mean(R_random(2:end,:),2)./NUM_ITERATIONS,std(R_random(2:end,:),0,2)./NUM_ITERATIONS);

title('Cumulative Reward v Training Epochs')
xlabel('Epochs')
ylabel('Average Cumulative Reward per Time Step')
legend('* Policy','Always Send Policy','Random Policy')

%% 
state_table.policy = policy_ind-1;
state_table.naive_Policy = naivePolicy_ind'-1;
state_table.random_Policy = randomPolicy_ind'-1;

critical_states = state_table(state_table.Police==0,:);