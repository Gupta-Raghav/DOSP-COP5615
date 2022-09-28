-module(node).

-export([start/2]).

start(numNodes,algorithm) ->
    if algorithm == 'gossip' ->
        neighbour_list =[],
        Count = 0; %we will have to change this IDK
    algorithm == 'push-sum' ->
        neighbour_list = [],
        state_sw = {s,1},
        counter =0;
    true ->
        io:format("ERROR:UNDEFINED.\n")
    end.
