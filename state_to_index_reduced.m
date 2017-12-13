function [ ind ] = state_to_index_reduced( state,lookuptable)
    ind = find(ismember(lookuptable,[state.Driver' state.Police'],'rows') == 1);
end

