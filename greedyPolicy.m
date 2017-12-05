% Evaluate greedy policy
function [reward] = greedyPolicy()
% Parmaters for simulator
num_drivers = 2;
num_police = 2;
timeSteps = 1000;

sim = Simulator;
state = sim.Initialize(sim,num_police,num_drivers,feature_dist);

for i=1:timeSteps
    avail_police = find(state.Police==0);
    action = length(avail_police);
    [new_state,reward] = Run(state,action);
    R = R + reward;
    state = new_state;
end

end