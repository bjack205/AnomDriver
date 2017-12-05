function [ T ] = indexed_states(state_to_index,U,num_police,num_driver,num_police_wait,num_driver_infractions )
    state = struct();
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
       
    for i = 1:size(Pfull,1)
        state.Police = Pfull(i,:);
        for j = 1:size(Dfull,1)
            state.Driver = Dfull(j,:);
            state_ind = state_to_index(state,num_police_wait,num_driver_infractions);
            States(state_ind).Driver = state.Driver;
            States(state_ind).Police = state.Police;
            States(state_ind).U = U(state_ind);
        end
    end
    
    T = struct2table(States);

end

