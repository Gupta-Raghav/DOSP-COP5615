-module(gossip).
-import(nmanager,[start/0,fullNetwork/2,line/2,grid3d/2,imperfect3d/2]).
-export([main/3]).

main(NumNodes, Topology, Algo) ->
    register(manager,spawn(topologies,start,[NumNodes,Topology,Algo])),
    
    Ltopology = string:to_lower(Topology),
    io:format("~p~n",[Ltopology]),
    if Ltopology == "fullnetwork" ->
        nmanager:fullNetwork(NumNodes,Algo);
    Ltopology == 'line' ->
        line(NumNodes,Algo);
    Ltopology == '3dgrid' ->
        grid3d(NumNodes,Algo);
    Ltopology == 'imperfect3d' ->
        imperfect3d(NumNodes,Algo);
    true ->
        io:format("[ERROR]: UNDEFINED TOPOLOGY, please try again\n")
    end.