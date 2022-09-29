-module(namanager).
-import(nodeg,[start_Rumour/1]).
-import(nodesp,[start_sum/1,populate_Neigbours/3]).
-export([fullNetwork/2,line/2,imperfect3d/2,grid3d/2,gspawner_Nodes/3,psspawner_Nodes/4]).


% This will spawn the "Gossip nodes". 
gspawner_Nodes(0,PIDList,_)->
    PIDList;
gspawner_Nodes (numNodes,PIDList,algorithm) -> %we might need the algorithm as well but let's see how it goes.
    PID = spawn(nodeg,start,[algorithm,0]), 
    gspawner_Nodes(numNodes-1,[PID|PIDList], algorithm). %recursion to spawn nodes = numNodes.

% This will spawn the "push sum nodes".
psspawner_Nodes(0,PIDList,_,_)->
        PIDList;
psspawner_Nodes (numNodes,PIDList,algorithm,X) -> %we might need the algorithm as well but let's see how it goes.
        PID = spawn(nodesp,start,[algorithm,X]), 
        psspawner_Nodes(numNodes-1,[PID|PIDList], algorithm,X+1).

fullNetwork(numNodes,algorithm) -> 
    if algorithm == 'gossip' ->
        io:format("here goes the code for the gossip in a full Network.\n"),
        PIDlist = gspawner_Nodes(numNodes,[],algorithm),   %considering we have spawned numNodes number of nodes and all the PID's are saved in PIDlist
        lists:foreach(fun(Elem)->
                    populate_Neigbours(Elem,PIDlist,algorithm)    
                    end,PIDlist),
        % Need to figure out how to populate the Neigbour list in the node module.
        Start_PID = [lists:nth(rand:uniform(length(PIDlist)), PIDlist)],    
        start_Rumour(Start_PID);
        % lists:foreach()
    algorithm == 'push-sum' ->
        io:format("here goes the code for the push-sum algorithm in a full Network.\n");
        % start_sum(Start_PID);
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