function [ ind ] = state_to_index( state,num_police_wait,num_driver_infractions )
% returns the index for a state

ind = 1;
R = 1;
for i = 1:length(state.Police)
    if i == 1
        ind = ind + (state.Police(i));
    else
        ind = ind + (state.Police(i))*R;
    end
    R = R*num_police_wait;
end
for i = 1:length(state.Driver)
    ind = ind + (state.Driver(i)-1)*R;
    R = R*num_driver_infractions;
end

end

