function [ policy_ind ] = randomAllocatePolicy(state_to_index,num_police,num_driver,num_police_wait,num_driver_infractions )
    % if policy are available, always allocate
    state = struct();
    
    %enumerate all possible police and driver states
    P = combnk(0:num_police_wait-1,num_police);
    Pfull = [];
    for i = 1:size(P,1)
        Pfull = cat(1,Pfull,perms(P(i,:)));
    end
    for i = 0:num_police_wait-1
        Pfull = cat(1,Pfull,i*ones(1,num_police));
    end
    
    Dfull = [];
    D = combnk(1:num_driver_infractions,num_driver);
    for i = 1:size(D,1)
        Dfull = cat(1,Dfull,perms(D(i,:)));
    end
    for i = 1:num_driver_infractions
        Dfull = cat(1,Dfull,i*ones(1,num_driver));
    end
       
    % evaluate each state
    for i = 1:size(Pfull,1)
        state.Police = Pfull(i,:);
        for j = 1:size(Dfull,1)
            state.Driver = Dfull(j,:);
            state_ind = state_to_index(state,num_police_wait,num_driver_infractions);
            if sum(state.Police == 0) > 0
                policy_ind(state_ind) = randi([1 sum(state.Police==0)+1]);
            else
                policy_ind(state_ind) = 1;
            end
        end
    end
end