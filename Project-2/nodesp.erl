-module(nodesp).

-export([start_g/2,start_sp/5,continue/3,gossip_line/2]).


start_sp(Neighbour_list,S,W,Flag,Count) ->
        receive
                {populate,Neighbour_list}->
                        start_sp(Neighbour_list,S,W,Flag,Count)
        end.

start_g(Neighbour_list,Count)->
        receive
                {populate,Nist}->
                        start_g(Nist,Count);
                {rumour} ->
                        continue(rumour,Neighbour_list,Count); 
                        
                kill ->
                        exit("kill")
        end.
        
send_rumour(Nlist,Count)->
        % io:format("~p\t~p~n",[self(),Count]),
        X = rand:uniform(length(Nlist)),
        Next_PID = lists:nth(X, Nlist),
        if Count /= 10 ->
        Next_PID ! {rumour},
        continue(rumour,Nlist,Count);
        true->
        listener ! {done}
        end.

continue(rumour,Nbourlist,Count)->
        
        receive
                {rumour} ->
                        send_rumour(Nbourlist,Count+1)       
        after 2 ->
                send_rumour(Nbourlist,Count)
        end.
        


gossip_line(Neblist,Count) ->
        % io:format("Line Neighbours ~p~n",[Neblist]),
        % io:format("here\n"),
        receive
                {neg}->
                        io:format("N List ~p~n", Neblist);
                {pop,Neist}->
                        % io:format("here~n"),
                        gossip_line(Neist,Count); 
                {rumour} ->
                        continue(rumour,Neblist,Count);
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