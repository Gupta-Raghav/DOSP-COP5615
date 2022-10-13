-module(project2).
-import(nmanager,[start/0,fullNetwork/2,line/2,grid2d/2,imperfect3d/2]).
-export([main/3]).

main(NumNodes, Topology, Algo) ->
    % NumNodes = erlang:list_to_integer(_NumNodes),
   
    Ltopology = string:to_lower(Topology),
    LAlgo = string:to_lower(Algo),
    % io:format("~p~n",[Ltopology]),
    if Ltopology == "fullnetwork" ->
        fullNetwork(NumNodes,LAlgo);
    Ltopology == "line" ->
        line(NumNodes,LAlgo);
    Ltopology == "2dgrid" ->
        grid2d(NumNodes,LAlgo);
    Ltopology == "imperfect3d" ->
        imperfect3d(NumNodes,LAlgo);
    true ->
        io:format("[ERROR]: UNDEFINED TOPOLOGY, please try again\n")
    end.