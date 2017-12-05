%Evaluate random policy
function [reward] = randomPolicy()
% Parmaters for simulator
num_drivers = 2;
num_police = 2;
timeSteps = 1000;

sim = Simulator;
state = sim.Initialize(sim,num_police,num_drivers,feature_dist);

for i=1:timeSteps
    avail_police = find(state.Police==0);
    max_action = length(avail_police);
    action = randi(max_action+1)-1;
    [new_state,reward] = Run(state,action);
    R = R + reward;
    state = new_state;
end

end