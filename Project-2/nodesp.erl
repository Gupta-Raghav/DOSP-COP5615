-module(nodesp).

-export([start_g/2,start_sp/5,continue/3,gossip_line/2]).


getRandomNeighbor(Nlist) ->
        Num =rand:uniform(Nlist),
        io:format("Num~w\n",Num),
        Num.

start_sp(Neighbour_list,S,W,Flag,Count) ->
        receive
                {populate,Neighbour_list}->
                        start_sp(Neighbour_list,S,W,Flag,Count)
        end.

start_g(Neighbour_list,Count)->
        % io:format("spawned~p~n",[self()]),
        receive
                {populate,Nist}->
                
                        % io:format("AAAAAAAAAAAAAA~p~n",[Nist]),
                        start_g(Nist,Count);
                {rumour} ->
                        % io:format("~p~n",[Neighbour_list]),
                        continue(rumour,Neighbour_list,Count); 
                        
                kill ->
                        exit("kill")
        end.
        
send_rumour(Nlist,Count)->
        io:format("~p\t~p~n",[self(),Count]),
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
        


gossip_line(Nlist,Count) ->
        receive
                {rumour,Pos,List} ->
                        io:format("here~n"),
                        NextPID=0,
                        io:format("Nlist~w~n",[List]),
                        Len = length(List),
                        List = [Pos+1],
                        if
                                Count /=10 ->
                                       NextRandom = getRandomNeighbor(List), 
                                       if
                                        NextRandom == 1 ->
                                                NextPID = Pos+1, %lists:nth() can be handy for this conditon
                                                io:format("NextPid inc~w~n",[NextPID]);
                                        true ->
                                                NextPID = Pos-1,
                                                io:format("NextPid depre~w~n",[NextPID])
                                       end;
                                true ->
                                 ok       
                        end,
                        NextPID ! {rumour,NextPID},
                        gossip_line(Nlist,Count+1)
                end.


















% populate_Neighbours()->
%         populate.    


% start_Rumour(PID)->
%         rumour.
% May be we will have to create a funciton where the first node value will be different for this weight will be 1.
% And all other nodes can have the value 1 for the weight.
% This can be a neat wau to have an actor inside the PIDList.