% Evaluate Policy
function [R, A] = EvaluatePolicy(policy_ind,MDP,NUM_ITERATIONS)
    R = 0; % cumulative reward
    A = 0; % number of police allocated
    state = Initialize(MDP.sim,MDP.num_police,MDP.num_driver,MDP.feature_dist); % initialize new state
    s = state_to_index(state,MDP.num_police_wait,MDP.num_driver_infractions);
    
    % Run simulator for fixed number of iterations, accumulating reward
    for i = 1:NUM_ITERATIONS
        action_ind = policy_ind(s);
        [state,reward] = MDP.sim.Run(state,action_ind-1);
        R = R + reward;
        A = A + (action_ind-1);
        s = state_to_index(state,MDP.num_police_wait,MDP.num_driver_infractions);
    end
end