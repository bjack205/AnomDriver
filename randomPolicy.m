function [ policy_ind ] = randomPolicy(MDP)
    % always select a random action
    policy_ind = randi([1 MDP.num_actions],1,MDP.num_states);
end

