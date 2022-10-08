-module(nmanager).
-import(nodeg,[start_Rumour/1]).
-import(nodesp,[start_sum/1,populate_Neigbours/3]).
-export([fullNetwork/2,line/2,imperfect3d/2,grid2d/2,gspawner_Nodes/2,psspawner_Nodes/4,listener/3,lgspawner_Nodes/2]).

listener(Len,PIDlist,TimeStart) when Len ==0 ->
   io:format("Done\n"),
   TimeEnd = erlang:monotonic_time()/10000,
      RunTime = TimeEnd - TimeStart,
      io:format("total time: ~f milliseconds~n", [RunTime]),
      erlang:halt(); 
%    lists:foreach(fun(Elem)->
%                 Elem ! kill
%                 end,PIDlist);

listener(Len,PIDlist,TimeStart)->
    receive
        {Len,PIDlist} -> 
            listener(Len,PIDlist,TimeStart);
        {done} ->
            listener(Len-1,PIDlist,TimeStart) 
    end.
% This will spawn the "Gossip nodes". 
spawner2d(X,Y,R,PIDlist) ->
    PID = spawn(nodesp,start_g,[[],0]),
    if
        X>0 ->
            spawner2d(X-1,Y,R,[PID|PIDlist]);
        Y>0 ->
            spawner2d(X,Y-1,R,[PID|PIDlist]);
        true ->
            ok
    end.


gspawner_Nodes(0,PIDList)->
    PIDList;
gspawner_Nodes(NumNodes,PIDList) -> %we might need the Algorithm as well but lets see how it goes.
    PID = spawn(nodesp,start_g,[[],0]), 
    gspawner_Nodes(NumNodes-1,[PID|PIDList]). %recursion to spawn nodes = NumNodes.


lgspawner_Nodes(0,PIDList)->
        PIDList;
lgspawner_Nodes(NumNodes,PIDList) -> %we might need the Algorithm as well but lets see how it goes.
        PID = spawn(nodesp,gossip_line,[[],0]), 
        gspawner_Nodes(NumNodes-1,[PID|PIDList]). %recursion to spawn nodes = NumNodes.
% This will spawn the "push sum nodes".
psspawner_Nodes(0,PIDList,_,_)->
        PIDList;
psspawner_Nodes (NumNodes,PIDList,Algorithm,X) -> %we might need the Algorithm as well but lets see how it goes.
        PID = spawn(nodesp,start_sp,[[  ],X]), 
        psspawner_Nodes(NumNodes-1,[PID|PIDList], Algorithm,X+1).

fullNetwork(NumNodes,Algorithm) -> 
    % io:format("~p~n",[Algorithm]),
    TimeStart = erlang:monotonic_time()/10000,
    register(listener,spawn(nmanager,listener,[1,[],TimeStart])),
    if Algorithm == "gossip" ->
        % io:format("here goes the code for the gossip in a full Network.\n"),
        PIDlist = gspawner_Nodes(NumNodes,[]),  
        Len = length(PIDlist),
        % io:fwrite("~w~n",[PIDlist]), 
        io:format("~p~n",[PIDlist]),
        lists:foreach(fun(Elem)->
                    Elem ! {populate,lists:delete(Elem,PIDlist)}
                    end,PIDlist),
                    listener ! {Len,PIDlist},
        % Need to figure out how to populate the Neigbour list in the node module.
        
        Start_PID = lists:nth(rand:uniform(length(PIDlist)), PIDlist),    
        % io:format("~w",[Start_PID]),s
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
      
        PIDList = lgspawner_Nodes(NumNodes,[]),
        RS = rand:uniform(NumNodes),
        StartPID = lists:nth(RS, PIDList),
        io:format("sending.\n"),
        StartPID ! {rumour,RS,PIDList};
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a Line Topology.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

grid2d(NumNodes,Algorithm)->
    io:format("Inside the 2d function\n"),
    Rows = erlang:trunc(math:sqrt(NumNodes)),
    io:format("Rows ~p~n",Rows),
    PIDList = spawner2d(Rows,Rows,Rows,[]),
    Len = 1,
    lists:foreach(fun(Elem)->
                    Elem ! {populate,lists:delete(Elem,PIDList)}    
                    end,PIDList),
                    listener ! {Len,PIDList},
    if Algorithm == "gossip" ->
        io:format("here goes the code for the gossip in a 3-D Grid.\n");
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a 3-D Grid.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

imperfect3d(NumNodes,Algorithm)->
    if Algorithm == "gossip" ->
        io:format("here goes the code for the gossip in a imperfect 3-D Grid.\n");
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a imperfect 3-D Grid.\n");
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.
        

% This can be called our Network manager, this will control the topologies and which Algorithm to go for.