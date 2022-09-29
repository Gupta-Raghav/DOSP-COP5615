-module(nodesp).

-export([start_sp/1,start_g/1]).


start_sp(S) ->
        Neighbour_list = [],
        State_sw = {S,1},
        Flag = true,
        Counter =0.

start_g(Count)->
        Neighbour_list = [],
        Counter =Count.



% May be we will have to create a funciton where the first node value will be different for this weight will be 1.
% And all other nodes can have the value 1 for the weight.
% This can be a neat wau to have an actor inside the PIDList.