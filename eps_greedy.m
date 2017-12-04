function [ action_ind ] = eps_greedy(U,state_ind,num_states,num_actions,T,R,gamma,eps,decay)
% epsilon-greedy policy solver
% action_ind is the action + 1;

if rand(1) < eps
    action_ind = randi(num_actions); % randomly select an action
else
    temp = zeros(1,num_actions);
%     for sp = 1:num_states
%         temp = temp + T(state_ind,:,sp).*U(sp);
%     end
    temp = squeeze(T(state_ind,:,:))*U;
    
    temp = R(state_ind,:) + gamma*temp';
    
    % if action are all equally good then random actions, else pick best
    % action
    if length(unique(temp)) == 1
        action_ind = randi(num_actions);
    else
        [~, action_ind] = max(temp);
    end
end

end

