-module(nodesp).

-export([start_g/2,start_sp/5,continue/3,gossip_line/2]).


start_sp(Neighbour_list,S,W,Prev_ratio,Count) ->
        receive
                {populate,Nehboulist}->
                        start_sp(Nehboulist,S,W,Prev_ratio,Count);
                {S1, W1}->
                        if
                                Count /=3 ->
                                        S2 = S + S1,
                                        W2 = W + W1,
                                        X = rand:uniform(length(Neighbour_list)),
                                        Next_PID = lists:nth(X, Neighbour_list),
                                        S3 = S2/2,
                                        W3 = W2/2,
                
                                        Next_PID ! {S3,W3},
                                        Curr_ratio = S2/W2,
                                        Diff = math:pow(10,-10),
                                        if
                                        abs(Curr_ratio - Prev_ratio) < Diff ->
                                                start_sp(Neighbour_list,S3,W3,Curr_ratio,Count+1);
                                        true ->
                                                start_sp(Neighbour_list,S3,W3,Curr_ratio,Count) %0
                                                
                                        end;
                                true ->
                                        io:format("Ho gaya bhaiya apna toh aur apun ka sum ~p\n",[S]),
                                        listener ! {done}       
                        end
                        
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