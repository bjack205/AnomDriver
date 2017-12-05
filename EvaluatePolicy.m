% Evaluate Policy
function R = EvaluatePolicy(policy)
    sim = Simulator;
    
    % Parameters
    NUM_ITERATIONS = 1000;
    NUM_POLICE = 2;
    NUM_DRIVER = 4;
    
    % 
    R = 0;
    
    % Initialize Simulator
    load('feaDistributions.mat')
    state = sim.Initialize(NUM_POLICE,NUM_DRIVER,feature_dist);
    s = state_to_index(state,mean(sim.police_wait)+1,size(sim.citations,1));
    
    % Run simulator for fixed number of iterations, accumulating reward
    for i = 1:NUM_ITERATIONS
        action = policy(s);
        [state,reward] = sim.Run(state,action);
        R = R + reward;
        s = state_to_index(state,mean(sim.police_wait)+1,size(sim.citations,1));
    end
end