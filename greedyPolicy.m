% Evaluate greedy policy
function [utility] = greedyPolicy()
% Parmaters for simulator
num_drivers = 2;
num_police = 2;
timeSteps = 1000;
utility = 0;

sim = Simulator;
load('feaDistributions.mat')
state = sim.Initialize(num_police,num_drivers,feature_dist);

for i=1:timeSteps
    avail_police = find(state.Police==0);
    action = length(avail_police);
    [new_state,reward] = sim.Run(state,action);
    utility = utility + reward;
    state = new_state;
end

end