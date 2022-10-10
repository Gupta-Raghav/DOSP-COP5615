-module(nodesp).

-export([start_g/2, start_sp/5, continue/3]).

start_sp(Nr_list, S, W, Prev_ratio, Count) ->
        if length(Nr_list) == 0 ->
                   listener ! {done};
           true ->
                   ok
        end,
        receive
                {nDone, Pid} ->
                        start_sp(lists:delete(Pid, Nr_list), S, W, Prev_ratio, Count);
                {populate, Nehboulist} ->
                        % io:format("~p,~p\n", [self(), Nehboulist]),
                        start_sp(Nehboulist, S, W, Prev_ratio, Count);
                {S1, W1} ->
                        if Count /= 3 ->
                                   S2 = S + S1,
                                   W2 = W + W1,
                                   X = rand:uniform(length(Nr_list)),
                                   Next_PID = lists:nth(X, Nr_list),
                                   S3 = S2 / 2,
                                   W3 = W2 / 2,

                                   Next_PID ! {S3, W3},
                                   Curr_ratio = S2 / W2,
                                   Diff = math:pow(10, -10),
                                   if abs(Curr_ratio - Prev_ratio) < Diff ->
                                              start_sp(Nr_list, S3, W3, Curr_ratio, Count + 1);
                                      true ->
                                              start_sp(Nr_list, S3, W3, Curr_ratio, 0)
                                   end;
                                Count == 3->
                                        listener ! {done},
                                        Next_PID = lists:nth( rand:uniform(length(Nr_list)), Nr_list),
                                        Next_PID ! {S,W},
                                        start_sp(Nr_list, S, W, Prev_ratio, Count + 1);
                                        
                                Count >3 ->
                                Next_PID = lists:nth( rand:uniform(length(Nr_list)), Nr_list),
                                Next_PID = {S,W},
                                start_sp(Nr_list, S, W, Prev_ratio, Count)
                        end;
                kill ->
                        exit("kill")
        end.

% gossip part.
start_g(Neighbour_list, Count) ->
        receive
                {populate, Nist} ->
                        % io:format("~p,~p\n",[self(),Nist]),
                        start_g(Nist, Count);
                {rumour} ->
                        continue(rumour, Neighbour_list, Count);
                kill ->
                        exit("kill")
        end.

send_rumour(Nlist, Count) ->
        % io:format("\t~p~n",[Nlist]),
        if length(Nlist) == 0 ->
                   listener ! {done};
           true ->
                X = rand:uniform(length(Nlist)),
                Next_PID = lists:nth(X, Nlist),
                if Count /= 10 ->
                           Next_PID ! {rumour},
                           continue(rumour, Nlist, Count);
                   true ->
                           lists:foreach(fun(Node) -> Node ! {nDone, self()} end, Nlist),
                           listener ! {done}
                end
        end.

continue(rumour, Nbourlist, Count) ->
        if length(Nbourlist) == 0 ->
                   listener ! {done};
           true ->
                   ok
        end,
        receive
                {rumour} ->
                        send_rumour(Nbourlist, Count + 1);
                {nDone, Pid} ->
                        continue(rumour, lists:delete(Pid, Nbourlist), Count)
        after 2 ->
                send_rumour(Nbourlist, Count)
        end.
