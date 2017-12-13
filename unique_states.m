function [ lookuptable ] = unique_states(state_to_index,num_police,num_driver,num_police_wait,num_driver_infractions )
    u_ind = [];
    lookuptable = [];
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
            if issorted(fliplr(state.Driver))
                state_ind = state_to_index(state,num_police_wait,num_driver_infractions);
                if sum(ismember(u_ind,state_ind)) == 0
                    u_ind = cat(1,u_ind,state_ind);
                    States(state_ind).Driver = state.Driver;
                    States(state_ind).Police = state.Police;
                    
                end
            end
        end
    end
    lookuptable = table2array(struct2table(States(sort(u_ind))));

    %u = sort(u);
end