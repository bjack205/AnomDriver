%Evaluate random policy
function [utility] = randomPolicy()
% Parmaters for simulator
num_drivers = 2;
num_police = 2;
timeSteps = 1000;
utility = 0;

sim = Simulator;
load('feaDistributions.mat')
state = Initialize(sim,num_police,num_drivers,feature_dist);

for i=1:timeSteps
    avail_police = find(state.Police==0);
    max_action = length(avail_police);
    action = randi(max_action+1)-1;
    [new_state,reward] = sim.Run(state,action);
    utility = utility + reward;
    state = new_state;
end

end