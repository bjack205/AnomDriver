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

cache = 1; %boolean determines if we store MDP every 'backup' epochs 
tic;
solution = MDPsolver(MDP, params,cache);
toc;

%% save model
U = solution(end).U;
T = solution(end).T;
R = solution(end).R;
gamma = params.gamma;
save('mdp_solution','T','R','U','gamma');
state_table = indexed_states(@state_to_index,U,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);

%% Plot cumulative reward over epochs
NUM_ITERATIONS = 1000; % number of timesteps to evaluate a policy
NUM_EVALS = 5; % number of times to evaluate each policy on a newly initialized scene

% initialize policy evaluation metrics
R = zeros(size(solution,1),NUM_EVALS);
A = zeros(size(solution,1),NUM_EVALS);
R_naive = zeros(NUM_EVALS,1);
A_naive = zeros(NUM_EVALS,1);
R_random = zeros(NUM_EVALS,1);
A_random = zeros(NUM_EVALS,1);

% generate comparative policies
naivePolicy_ind = NaivePolicy(@state_to_index,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);
randomPolicy_ind = randomAllocatePolicy(@state_to_index,MDP.num_police,MDP.num_driver,MDP.num_police_wait,MDP.num_driver_infractions);

% evaluate policies
for i = 1:max(size(solution))
    [policy_ind,~] = CalculatePolicy(solution(i).U,solution(i).T,solution(i).R,params.gamma);
    for j = 1:NUM_EVALS
        [R(i,j), A(i,j)] = EvaluatePolicy(policy_ind,MDP,NUM_ITERATIONS);
        if i == 1
            [R_naive(j), A_naive(j)] = EvaluatePolicy(naivePolicy_ind,MDP,NUM_ITERATIONS);
            [R_random(j), A_random(j)] = EvaluatePolicy(randomPolicy_ind,MDP,NUM_ITERATIONS);
        end
    end
end
%%
figure
hold on
mean_R_per_allocation = mean(R./A,2);
std_R_per_allocation = std(R./A,0,2);
errorbar(log10([solution.epoch]),mean_R_per_allocation,std_R_per_allocation);
plot(log10(linspace(1,solution(end).epoch,100)),mean(R_naive./A_naive)*ones(1,100))
plot(log10(linspace(1,solution(end).epoch,100)),mean(R_random./A_random)*ones(1,100))
%title('Cumulative Reward v Training Epochs')
xlabel('log_{10}(epoch)')
ylabel(sprintf('Average Cumulative Reward\n per Allocation'));
legend('Optimal Policy','Always Send Policy','Random Policy')

% compare policies
state_table.policy = policy_ind-1;
state_table.naive_Policy = naivePolicy_ind'-1;
state_table.random_Policy = randomPolicy_ind'-1;

critical_states = state_table(state_table.Police==0,:);
save('table_solution','state_table');

%% output table of policies
output_policy= critical_states((critical_states.Driver(:,1)>=critical_states.Driver(:,2)),:);
% Now use this table as input in our input struct:
% LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
% Age = [38;43;38;40;49];
% Height = [71;69;64;67;64];
% Weight = [176;163;131;133;119];
% T = table(Age,Height,Weight,'RowNames',LastName);

input.data = table2array(output_policy);
input.dataFormat = {'%g'};
input.tableColumnAlignment = 'c';
input.tableBorders = 1;
input.makeCompleteLatexDocument = 1;
latex = latexTable(input)

save('output_policy','output_policy')