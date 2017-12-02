% Taylor Howell
% Machine Learning CS229
% AnomDriver 
% Simple MDP

clear;clc;closeall;

np = 2; % number of police
nd = 5; % number of anomalous drivers detected
nc = 5; % number of unique citations

td = 3; % number of time steps before police car returns

% initialize state
s = struct(police,zeros(1,np),drivers,randi(nc,1,nd)); 

% select an action at random (0 = stay, 1 = cite)
a = randi([0 1],1,nd); % initialize action array

% evaluate actions 
for i = 1:np
    if s.police(i) ~= 0
        a(i) = 0; % modify actions to set invalid actions (ie, cite when no police are available)
    end        
end
% reward is linear combination of (modified) police action and driver
% state
r = a.*s.drivers

% next driver state is random
s.drivers = randi(nc,1,nd);

% update police state
for i = 1:np
    if a(i) ~= 0 && s.police(i)
        a(i) = 0;
    end        
end

