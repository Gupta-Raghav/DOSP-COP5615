-module(nmanager).
-import(nodeg,[start_Rumour/1]).
-import(nodesp,[start_sum/1,populate_Neigbours/3]).
-export([fullNetwork/2,line/2,imperfect3d/2,grid3d/2,gspawner_Nodes/3,psspawner_Nodes/4,listener/2]).

listener(Len,PIDlist) when Len ==0 ->
   io:format("Done\n"),     
   lists:foreach(fun(Elem)->
                Elem ! kill
                end,PIDlist);

listener(Len,PIDlist)->
    receive
        {Len,PIDlist} -> 
            listener(Len,PIDlist);
        {done} ->
            listener(Len-1,PIDlist) 
    end.
% This will spawn the "Gossip nodes". 
gspawner_Nodes(0,PIDList,_)->
    PIDList;
gspawner_Nodes (NumNodes,PIDList,Algorithm) -> %we might need the Algorithm as well but lets see how it goes.
    PID = spawn(nodesp,start_g,[[],0]), 
    gspawner_Nodes(NumNodes-1,[PID|PIDList], Algorithm). %recursion to spawn nodes = NumNodes.

% This will spawn the "push sum nodes".
psspawner_Nodes(0,PIDList,_,_)->
        PIDList;
psspawner_Nodes (NumNodes,PIDList,Algorithm,X) -> %we might need the Algorithm as well but lets see how it goes.
        PID = spawn(nodesp,start_sp,[[],X]), 
        psspawner_Nodes(NumNodes-1,[PID|PIDList], Algorithm,X+1).

fullNetwork(NumNodes,Algorithm) -> 
    % io:format("~p~n",[Algorithm]),
    if Algorithm == "gossip" ->
        % io:format("here goes the code for the gossip in a full Network.\n"),
        PIDlist = gspawner_Nodes(NumNodes,[],Algorithm),  
        Len = length(PIDlist),
        % io:fwrite("~w~n",[PIDlist]),   %considering we have spawned NumNodes number of nodes and all the PIDs are saved in PIDlist

        lists:foreach(fun(Elem)->
                    Elem ! {populate,lists:delete(Elem,PIDlist)}    
                    end,PIDlist),
                    listener ! {Len,PIDlist},
        % Need to figure out how to populate the Neigbour list in the node module.
        
        Start_PID = lists:nth(rand:uniform(length(PIDlist)), PIDlist),    
        % io:format("~w",[Start_PID]),
        % io:format("~w",[erlang:is_process_alive(Start_PID)]),
        Start_PID ! {rumour},
        io:format(" ");
        % lists:foreach()
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a full Network.\n");
        % start_sum(Start_PID);
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

line(NumNodes,Algorithm)->
    if Algorithm == "gossip" ->
        io:format("here goes the code for the gossip in a Line topology.\n");
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a Line Topology.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

grid3d(NumNodes,Algorithm)->
    if Algorithm == gossip ->
        io:format("here goes the code for the gossip in a 3-D Grid.\n");
    Algorithm == push-sum ->
        io:format("here goes the code for the push-sum Algorithm in a 3-D Grid.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

imperfect3d(NumNodes,Algorithm)->
    if Algorithm == gossip ->
        io:format("here goes the code for the gossip in a imperfect 3-D Grid.\n");
    Algorithm == push-sum ->
        io:format("here goes the code for the push-sum Algorithm in a imperfect 3-D Grid.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.
        

% This can be called our Network manager, this will control the topologies and which Algorithm to go for.