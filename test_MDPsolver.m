% Taylor Howell
% AnomDriver
% tests of simulator for MDP solver implementation

clear;clc;close all;
%%% Variables we can change
num_police = 1; % number of police
num_driver = 2; % number of anomalous 

gamma = 0.9;
eps = 0.1;
decay = 0; % rate of decay for eps
policy = 'eps_greedy'; % specify exploration strategy *NOTE: add decaying eps-greedy policy option

tolerance=0.01;
num_update = 50; % number of iterations before updating the MDP model
NO_LEARNING_THRESHOLD = 20;
NOCLT = 0; % count for consecutive value iterations requiring 1 iteration

epoch = 0;
%%%

% create an instance of the simulator and initialize state
sim = Simulator; 
state = Initialize(sim,num_police,num_driver);

% find state and action spaces
num_driver_infractions = size(sim.citations,1); % number of unique infractions a driver can be guilty of
num_police_wait = sim.police_wait.ParameterValues(1)+1; % number of values each police can be in
num_actions = num_police + 1; % number of availabe actions 
num_states = (num_police_wait^num_police)*(num_driver_infractions^num_driver); % cardinality of state space

% initialize counts
N = ones(num_states, num_actions, num_states); % count for N(s,a,s')
rho = zeros(num_states, num_actions); % count for rho(s,a)
Nsp = zeros(num_states,1); 
% initialize MDP
U = 0.1*randn(num_states,1); 
T = 1/num_states*ones(num_states, num_actions, num_states); % transition probability T(sp|s,a) -> T(s,a,sp)
R = zeros(num_states, num_actions);


% MDP solver
while (NOCLT < NO_LEARNING_THRESHOLD) %;&& attempts < max_attempts
    
    % gain experience 'num_update' times before updating MDP model
    for i = 1:num_update
        % query simulator 
        state_ind = state_to_index(state,num_police_wait,num_driver_infractions);
        action = feval(policy,U,state_ind,num_states,num_actions,T,R,gamma,eps,decay);
        [new_state, reward] = Run(sim,state,action);
        new_state_ind = state_to_index(new_state,num_police_wait,num_driver_infractions);

        % update counts
        N(state_ind,action,new_state_ind) = N(state_ind,action,new_state_ind) + 1;
        rho(state_ind,action) = rho(state_ind,action) + reward;
        
        % increment the state
        state = new_state;
    end
    
    % update MDP model [vectorized]
    T = N./repmat(sum(N,3),1,1,num_states);
    R = rho./sum(N,3);
% %     for i = 1:num_states
% %         for j = 1:num_actions
% %             sumN = sum(N(i,j,:));
% %             R(i,j) = rho(i,j)/sumN;
% %             for k = 1:num_states
% %                 T(i,j,k) = N(i,j,k)/sumN;
% %             end
% %         end
% %     end
    
    % Value Iteration
    iteration = 0;
    max_abs_diff = tolerance + 1;
    while max_abs_diff > tolerance && iteration < 10
        Uold = U;
        for i = 1:num_states;
            temp = zeros(1,num_actions);
            for k = 1:num_states
                temp = temp + T(i,:,k)*U(k);
            end
            U(i) = max(R(i,:) + gamma*temp);
        end
        iteration = iteration + 1;
        max_abs_diff = max(abs(U-Uold));
    end
    
    if iteration == 1
        NOCLT = NOCLT + 1;
    else
        NOCLT = 0;
    end
    epoch = epoch + 1;

    % print number of epochs
    if rem(epoch,100) == 0
        fprintf('Epoch: %i\n',epoch)
    end
end




    



