-module(namanager).

-export([fullNetwork/2,line/2,imperfect3d/2,grid3d/2,gspawner_Nodes/3,psspawner_Nodes/3]).

gspawner_Nodes(0,PIDList,_)->
    PIDList;
gspawner_Nodes (numNodes,PIDList,algorithm) -> %we might need the algorithm as well but let's see how it goes.
    PID = spawn(nodes,start,[algorithm]), 
    gspawner_Nodes(numNodes-1,[PID|PIDList], algorithm). %recursion to spawn nodes = numNodes.

psspawner_Nodes(0,PIDList,_)->
        PIDList;
psspawner_Nodes (numNodes,PIDList,algorithm) -> %we might need the algorithm as well but let's see how it goes.
        PID = spawn(nodes,start,[algorithm,x]), 
        psspawner_Nodes(numNodes-1,[PID|PIDList], algorithm).

    
fullNetwork(numNodes,algorithm) ->
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a full Network.\n"),
        PIDlist = gspawner_Nodes(numNodes,[],algorithm);
        % lists:foreach()
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