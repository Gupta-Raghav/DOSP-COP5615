-module(gossip).
-import(nmanager,[start/0,fullNetwork/2,line/2,grid3d/2,imperfect3d/2]).
-export([main/3]).

main(numNodes, topology, algo) ->
    register(manager,spawn(topologies,start,[numNodes,topology,algo])),
    ltopology = string:to_lower(topology),
    if ltopology == 'fullnetwork' ->
        fullNetwork(numNodes,algo);
    ltopology == 'line' ->
        line(numNodes,algo);
    ltopology == '3dgrid' ->
        grid3d(numNodes,algo);
    ltopology == 'imperfect3d' ->
        imperfect3d(numNodes,algo);
    true ->
        io:format("[ERROR]: UNDEFINED TOPOLOGY, please try again\n")
    end.