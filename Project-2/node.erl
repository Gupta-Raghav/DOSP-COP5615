-module(node).

-export([start/2]).

-record(PID,{
    neighbour_list =[],
    count =0,
})



start(numNodes,algorithm) ->
    if algorithm == 'gossip' ->
        neighbour_list =[],
        count = 0; %we will have to change this IDK

    algorithm == 'push-sum' ->
        neighbour_list = [],
        state_sw = {s,1},
        Sum = 0,
        counter =0;
    true ->
        io:format("ERROR:UNDEFINED.\n")
    end.


% May be we will have to create a funciton where the first node value will be different for this weight will be 1.
% And all other nodes can have the value 1 for the weight.
% This can be a neat wau to have an actor inside the PIDList.