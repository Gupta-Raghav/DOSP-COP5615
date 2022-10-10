-module(nmanager).

-import(nodeg, [start_Rumour/1]).
-import(nodesp, [start_sum/1, populate_Neigbours/3]).

-export([fullNetwork/2, line/2, grid2d/2, gspawner_Nodes/2, psspawner_Nodes/3, listener/3,
         imperfect3d/2, divider/2]).

% helper functions starts here.
divider([], _) ->
    [];
divider(List, Len) when Len > length(List) ->
    [List];
divider(List, Len) ->
    {Head, Tail} = lists:split(Len, List),
    [Head | divider(Tail, Len)].

listener(Len, PIDlist, TimeStart) when Len == 0 ->
    TimeEnd = erlang:monotonic_time()/1000,
    RunTime = TimeEnd - TimeStart,
    io:format("~p,~p~n", [length(PIDlist),RunTime]),
    erlang:halt();
listener(Len, PIDlist, TimeStart) ->
    receive
        {Leng, Pids} ->
            listener(Leng, Pids, TimeStart);
        {done} ->
            io:format("sadasd\n"),
            listener(Len - 1, PIDlist, TimeStart)
    end.

% This will spawn the "Gossip nodes".

gspawner_Nodes(0, PIDList) ->
    PIDList;
gspawner_Nodes(NumNodes, PIDList) ->
    PID = spawn(nodesp, start_g, [[], 0]),
    gspawner_Nodes(NumNodes - 1, [PID | PIDList]).

% This will spawn the "push sum nodes".
psspawner_Nodes(0, PIDList, _) ->
    PIDList;
psspawner_Nodes(NumNodes, PIDList, X) ->
    PID = spawn(nodesp, start_sp, [[1], X, 1, X, 0]),
    psspawner_Nodes(NumNodes - 1, [PID | PIDList], X + 1).

gridmaker(PIDList, Total, Rows, Otherlists) ->
    % io:format("~p~n", [Otherlists]),
    lists:foreach(fun(Elem) ->
                     Ind = string:str(PIDList, [Elem]),
                     Mod = Ind rem Rows,
                     Random =
                         lists:nth(
                             rand:uniform(length(Otherlists)), Otherlists),
                     if Ind =< Rows -> %For all the bottom elements
                            if Mod == 1 -> %left most value
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind + Rows + 1, PIDList),
                                       Random]};
                               Mod == 0 -> %right most
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind + Rows - 1, PIDList),
                                       Random]};
                               true -> %middle values
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind + Rows - 1, PIDList),
                                       lists:nth(Ind + Rows + 1, PIDList),
                                       Random]}
                            end;
                        Total - Ind < Rows -> %For all top elements
                            if Mod == 1 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       lists:nth(Ind - Rows + 1, PIDList),
                                       Random]};
                               Mod == 0 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       lists:nth(Ind - Rows - 1, PIDList),
                                       Random]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       lists:nth(Ind - Rows + 1, PIDList),
                                       lists:nth(Ind - Rows - 1, PIDList),
                                       Random]}
                            end;
                        true -> %For all the middle elements
                            if Mod == 1 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       lists:nth(Ind - Rows + 1, PIDList),
                                       lists:nth(Ind - Rows + 1, PIDList),
                                       Random]};
                               Mod == 0 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       lists:nth(Ind - Rows - 1, PIDList),
                                       lists:nth(Ind - Rows - 1, PIDList),
                                       Random]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows + 1, PIDList),
                                       lists:nth(Ind - Rows - 1, PIDList),
                                       lists:nth(Ind + Rows + 1, PIDList),
                                       lists:nth(Ind + Rows - 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList),
                                       Random]}
                            end
                     end
                  end,
                  PIDList).

gridmaker(PIDList, Total, Rows) ->
    lists:foreach(fun(Elem) ->
                     Ind = string:str(PIDList, [Elem]),
                     Mod = Ind rem Rows,
                     if Ind =< Rows -> %For all the bottom elements
                            if Mod == 1 -> %left most value
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList)]};
                               Mod == 0 -> %right most
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList)]};
                               true -> %middle values
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList)]}
                            end;
                        Total - Ind < Rows -> %For all top elements
                            if Mod == 1 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]};
                               Mod == 0 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]}
                            end;
                        true -> %For all the middle elements
                            if Mod == 1 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]};
                               Mod == 0 ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList),
                                       lists:nth(Ind - 1, PIDList),
                                       lists:nth(Ind + Rows, PIDList),
                                       lists:nth(Ind - Rows, PIDList)]}
                            end
                     end
                  end,
                  PIDList).

% helper functions ends here.
%
%
%

% Topolgies Start here
% Full Network Topology
fullNetwork(NumNodes, Algorithm) ->
    TimeStart = erlang:monotonic_time() / 10000,
    register(listener, spawn(nmanager, listener, [1, [], TimeStart])),
    if Algorithm == "gossip" ->
           PIDlist = gspawner_Nodes(NumNodes, []),
           Len = length(PIDlist),
           lists:foreach(fun(Elem) -> Elem ! {populate, lists:delete(Elem, PIDlist)} end, PIDlist),
           listener ! {Len, PIDlist},
           Start_PID =lists:nth(rand:uniform(Len), PIDlist),
           Start_PID ! {rumour},
           io:format(" ");
       Algorithm == "push-sum" ->
           PIDlist = psspawner_Nodes(NumNodes, [], 1),
           Len = length(PIDlist),
           lists:foreach(fun(Elem) -> Elem ! {populate, lists:delete(Elem, PIDlist)} end, PIDlist),
           listener ! {Len, PIDlist},
           S = rand:uniform(length(PIDlist)),
           Start_PID = lists:nth(S, PIDlist),
           Start_PID ! {S, 1},
           io:format(" ");
       true ->
           io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

% Line Topology
line(NumNodes, Algorithm) ->
    TimeStart = erlang:monotonic_time() / 10000,
    register(listener, spawn(nmanager, listener, [1, [], TimeStart])),
    if Algorithm == "gossip" ->
           PIDList = gspawner_Nodes(NumNodes, []),
           Len = length(PIDList),
           lists:foreach(fun(Elem) ->
                            Ind = string:str(PIDList, [Elem]),
                            if Ind == 1 -> Elem ! {populate, [lists:nth(Ind + 1, PIDList)]};
                               Ind == Len -> Elem ! {populate, [lists:nth(Ind - 1, PIDList)]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList), lists:nth(Ind - 1, PIDList)]}
                            end
                         end,
                         PIDList),
           listener ! {Len, PIDList},
           RS = rand:uniform(NumNodes),
           StartPID = lists:nth(RS, PIDList),
           StartPID ! {rumour};
       Algorithm == "push-sum" ->
           PIDList = psspawner_Nodes(NumNodes, [], 1),
           Len = length(PIDList),
           lists:foreach(fun(Elem) ->
                            Ind = string:str(PIDList, [Elem]),

                            if Ind == 1 -> Elem ! {populate, [lists:nth(Ind + 1, PIDList)]};
                               Ind == Len -> Elem ! {populate, [lists:nth(Ind - 1, PIDList)]};
                               true ->
                                   Elem
                                   ! {populate,
                                      [lists:nth(Ind + 1, PIDList), lists:nth(Ind - 1, PIDList)]}
                            end
                         end,
                         PIDList),
           listener ! {Len, PIDList},
           RS = rand:uniform(NumNodes),
           StartPID = lists:nth(RS, PIDList),
           StartPID ! {RS, 1};
       true ->
           io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

% 2d GridNetwork Topology

grid2d(NumNodes, Algorithm) ->
    % io:format("Inside the 2d function\n"),
    TimeStart = erlang:monotonic_time() / 10000,
    register(listener, spawn(nmanager, listener, [1, [], TimeStart])),
    % io:format("Listener is up\n"),
    if Algorithm == "gossip" ->
           io:format("here goes the code for the gossip in a 3-D Grid.\n"),
           Rows =
               erlang:trunc(
                   math:sqrt(NumNodes)),
        %    io:format("Rows ~p~n", [Rows]),
           Total = Rows * Rows,
        %    io:format("Total elements ~p~n", [Total]),
           PIDList = gspawner_Nodes(Total, []),
        %    io:format("PID_list ~p~n\n", [PIDList]),
           gridmaker(PIDList, Total, Rows),
           Len = length(PIDList),
           listener ! {Len, PIDList},
           Start_PID =
               lists:nth(
                   rand:uniform(length(PIDList)), PIDList),
           Start_PID ! {rumour};
       Algorithm == "push-sum" ->
           io:format("here goes the code for the push-sum Algorithm in a 3-D Grid.\n"),
           Rows =
               erlang:trunc(
                   math:sqrt(NumNodes)),
           io:format("Rows ~p~n", [Rows]),
           Total = Rows * Rows,
           io:format("Total elements ~p~n", [Total]),
           PIDList = psspawner_Nodes(Total, [], 1),
        %    io:format("PID_list ~p~n\n", [PIDList]),
           gridmaker(PIDList, Total, Rows),
           NPIDList = lists:sublist(PIDList, Total),
           listener ! {Total, NPIDList},
           RS = rand:uniform(length(NPIDList)),
           StartPID = lists:nth(RS, NPIDList),
           StartPID ! {RS, 1};
       true ->
           io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

imperfect3d(NumNodes, Algorithm) ->
    TimeStart = erlang:monotonic_time() / 10000,
    register(listener, spawn(nmanager, listener, [1, [], TimeStart])),
    Rows = round(math:pow(NumNodes, 1 / 3)),
    Total = Rows * Rows * Rows,
    Size = Rows * Rows,

    if Algorithm == "gossip" ->
           PIDList = gspawner_Nodes(Total, []),
           Lists = divider(PIDList, Size),
           lists:foreach(fun(Elem) ->
                            Other = lists:subtract(PIDList, Elem),
                            gridmaker(Elem, Size, Rows, Other)
                         end,
                         Lists),
           Len = length(PIDList),
           listener ! {Len, PIDList},
           RS = rand:uniform(Total),
           StartPID = lists:nth(RS, PIDList),
           StartPID ! {rumour};
       Algorithm == "push-sum" ->
           PIDList = psspawner_Nodes(Total, [], 1),
           Lists = divider(PIDList, Size),
           lists:foreach(fun(Elem) ->
                            Other = lists:subtract(PIDList, Elem),
                            gridmaker(Elem, Size, Rows, Other)
                         end,
                         Lists),
           Len = length(PIDList),
           listener ! {Len, PIDList},
           RS = rand:uniform(Total),
           StartPID = lists:nth(RS, PIDList),
           StartPID ! {RS, 1};
       true ->
           io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.
