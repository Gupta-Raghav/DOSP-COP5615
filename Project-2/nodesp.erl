-module(nodesp).

-export([start_g/2,start_sp/5]).


start_sp(Neighbour_list,S,W,Flag,Count) ->
        receive
                {populate,Neighbour_list}->
                        start_sp(Neighbour_list,S,W,Flag,Count)
        end.

start_g(Neighbour_list,Count)->
        receive
                {populate,Neighbour_list}->
                        start_g(Neighbour_list,Count);
                {rumour} ->
                        X = rand:uniform(length(Neighbour_list)),
                        Next_PID = lists:nth(X, Neighbour_list),
                       if Count /= 10 ->
                        Next_PID ! {rumour},
                        start_g(Neighbour_list,Count+1);
                        true->
                        listener ! {done},
                        start_g(Neighbour_list,Count)
                   
                       end;
                kill ->
                        exit("kill")
        end.

% populate_Neighbours()->
%         populate.    


% start_Rumour(PID)->
%         rumour.
% May be we will have to create a funciton where the first node value will be different for this weight will be 1.
% And all other nodes can have the value 1 for the weight.
% This can be a neat wau to have an actor inside the PIDList.