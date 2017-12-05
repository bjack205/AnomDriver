% Evaluate Policy
function R = EvaluatePolicy(policy_ind,MDP,NUM_ITERATIONS)
    R = 0;
<<<<<<< HEAD
    state = Initialize(MDP.sim,MDP.num_police,MDP.num_driver,MDP.feature_dist); % initialize new state
    s = state_to_index(state,MDP.num_police_wait,MDP.num_driver_infractions);
=======
    
    % Initialize Simulator
    load('feaDistributions.mat')
    state = sim.Initialize(NUM_POLICE,NUM_DRIVER,feature_dist);
    s = state_to_index(state,mean(sim.police_wait)+1,size(sim.citations,1));
>>>>>>> da83a903d577455478f0dcbc628e8071cea59200
    
    % Run simulator for fixed number of iterations, accumulating reward
    for i = 1:NUM_ITERATIONS
        action_ind = policy_ind(s);
        [state,reward] = MDP.sim.Run(state,action_ind-1);
        R = R + reward;
        s = state_to_index(state,MDP.num_police_wait,MDP.num_driver_infractions);
    end
end