-module(topologies).

-export([fullNetwork/2,line/2,imperfect3d/2,grid3d/2,spawner_Nodes/3]).

spawner_Nodes(0,PIDList,_)->
    PIDList;
spawner_Nodes (numNodes,PIDList,algorithm) -> %we might need the algorithm as well but let's see how it goes.
    PID = spawn(nodes,start,[]), 
    spawner_Nodes(numNodes-1,[PID|PIDList], algorithm). %recursion to spawn nodes = numNodes.

start()->
    ok.
fullNetwork(numNodes,algorithm) ->
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a full Network.\n");
    algorithm == 'push-sum' ->
        io:format("here goes the code for the push-sum algorithm in a full Network.\n");
    true ->
        io:format("The algorithm you have mentioned doesn't match our database.\n")
    end.

line(numNodes,algorithm)->
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a Line topology.\n");
    algorithm == 'push-sum' ->
        io:format("here goes the code for the push-sum algorithm in a Line Topology.\n");
    true ->
        io:format("The algorithm you have mentioned doesn't match our database.\n")
    end.

grid3d(numNodes,algorithm)->
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a 3-D Grid.\n");
    algorithm == 'push-sum' ->
        io:format("here goes the code for the push-sum algorithm in a 3-D Grid.\n");
    true ->
        io:format("The algorithm you have mentioned doesn't match our database.\n")
    end.

imperfect3d(numNodes,algorithm)->
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a imperfect 3-D Grid.\n");
    algorithm == 'push-sum' ->
        io:format("here goes the code for the push-sum algorithm in a imperfect 3-D Grid.\n");
    true ->
        io:format("The algorithm you have mentioned doesn't match our database.\n")
    end.
        


% This can be called our Network manager, this will control the topologies and which algorithm to go for.