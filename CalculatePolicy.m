function [policy_ind,Ustar] = CalculatePolicy(U,T,R,gamma)
% CALCULATEPOLICY CalculatePolicy(U,T,R,gamma)
%   Returns the policy given the value function and the model (T and R)
%   
%   INPUTS:
%       U: Sx1 matrix of optimal value function (S is the number of states)
%       T: SxAxS matrix of transition probability, given as T(s,a,sp),
%       where sp is the next state and A is the number of actions
%       R: SxA matrix of rewards
%       gamma: discout factor
%
%   OUTPUT:
%       policy: Sx1 vector of actions for the given policy
%       Ustar: The optimal value function. Should be very close to U if U
%       has converged

    num_states = length(U);
    num_actions = size(T,2);
    
    % Initialize Variables
    Ustar = zeros(size(U));
    policy_ind = zeros(size(U));
    
    % Loop over all states
%     for s = 1:num_states
%         U = zeros(1,num_actions);
%         for a = 1:num_actions
%             for sp = 1:num_states
%                 U(a) = U(a) + T(s,a,sp)*U(sp);
%             end
%             U(a) = R(s,a) + gamma*U(a);
%         end
%         [Ustar(s),policy(s)] = max(U(a));
%     end
        temp = zeros(1,num_actions);
        for i = 1:num_states;
            temp = squeeze(T(i,:,:))*U;
            [Ustar(i),policy_ind(i)] = max(R(i,:) + gamma*temp');
        end
end