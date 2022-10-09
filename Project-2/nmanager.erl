-module(nmanager).
-import(nodeg,[start_Rumour/1]).
-import(nodesp,[start_sum/1,populate_Neigbours/3]).
-export([fullNetwork/2,line/2,grid2d/2,gspawner_Nodes/2,psspawner_Nodes/3,listener/3]).

listener(Len,_,TimeStart) when Len ==0 ->
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
            % io:format("Done sending ~p~n",Node),
            listener(Len-1,PIDlist,TimeStart) 
    end.
% This will spawn the "Gossip nodes".

gspawner_Nodes(0,PIDList)->
    PIDList;
gspawner_Nodes(NumNodes,PIDList) -> %we might need the Algorithm as well but lets see how it goes.
    PID = spawn(nodesp,start_g,[[],0]), 
    gspawner_Nodes(NumNodes-1,[PID|PIDList]). %recursion to spawn nodes = NumNodes.

% This will spawn the "push sum nodes".
psspawner_Nodes(0,PIDList,_)->
        PIDList;
psspawner_Nodes (NumNodes,PIDList,X) -> %we might need the Algorithm as well but lets see how it goes.
        PID = spawn(nodesp,start_sp,[[],X,1,X,0]), 
        psspawner_Nodes(NumNodes-1,[PID|PIDList],X+1).

fullNetwork(NumNodes,Algorithm) -> 
    % io:format("~p~n",[Algorithm]),
    TimeStart = erlang:monotonic_time()/10000,
    register(listener,spawn(nmanager,listener,[1,[],TimeStart])),
    if Algorithm == "gossip" ->
        % io:format("here goes the code for the gossip in a full Network.\n"),
        PIDlist = gspawner_Nodes(NumNodes,[]),  
        Len = length(PIDlist),
        % io:fwrite("~w~n",[PIDlist]), 
        % io:format("~p~n",[PIDlist]),
        lists:foreach(fun(Elem)->
                    Elem ! {populate,lists:delete(Elem,PIDlist)}
                    end,PIDlist),
                    listener ! {Len,PIDlist},
        Start_PID = lists:nth(rand:uniform(length(PIDlist)), PIDlist),    
        % io:format("~w",[Start_PID]),        % io:format("~w",[erlang:is_process_alive(Start_PID)]),
        Start_PID ! {rumour},
        io:format(" ");
        % lists:foreach()
    Algorithm == "push-sum" ->
             PIDlist = psspawner_Nodes(NumNodes,[],1),  
             Len = length(PIDlist),
             % io:fwrite("~w~n",[PIDlist]), 
            % io:format("~p~n",[PIDlist]),
             lists:foreach(fun(Elem)->
                Elem ! {populate,lists:delete(Elem,PIDlist)}
                end,PIDlist),
                listener ! {Len,PIDlist},
                S= rand:uniform(length(PIDlist)),
                Start_PID = lists:nth(S, PIDlist),    
    % io:format("~w",[Start_PID]),s
    % io:format("~w",[erlang:is_process_alive(Start_PID)]),
    Start_PID !{S,1};
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

line(NumNodes,Algorithm)->
    TimeStart = erlang:monotonic_time()/10000,
    register(listener,spawn(nmanager,listener,[1,[],TimeStart])),
    if Algorithm == "gossip" ->
        PIDList = gspawner_Nodes(NumNodes,[]),
        % io:format("PID_list ~p~n\n",[PIDList]),
        Len = length(PIDList),
        lists:foreach(fun(Elem)->
            Ind = string:str(PIDList, [Elem]),
            % io:format("Element ~p~n",[Ind]),
                    if
                        Ind ==1 ->
                            % io:format("pop for ~p\n",[Elem]),
                            Elem ! {populate,[lists:nth(Ind+1,PIDList)]};
                        Ind == Len ->
                            % io:format("Element ~p~n",[Elem]),
                            Elem ! {populate,[lists:nth(Ind-1,PIDList)]};
                        true ->
                            % io:format("Element ~p~n",[Elem]),
                            Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList)]}
                    end
                    end,PIDList),
                    listener ! {Len,PIDList,TimeStart},
        RS = rand:uniform(NumNodes),
        StartPID = lists:nth(RS, PIDList),
        StartPID ! {rumour};
    Algorithm == "push-sum" ->
        % io:format("here goes the code for the push-sum Algorithm in a Line Topology.\n");
    PIDList = psspawner_Nodes(NumNodes,[],1),
    % io:format("PID_list ~p~n\n",[PIDList]),
    Len = length(PIDList),
    lists:foreach(fun(Elem)->
        Ind = string:str(PIDList, [Elem]),
        % io:format("Element ~p~n",[Ind]),
                if
                    Ind ==1 ->
                        % io:format("pop for ~p\n",[Elem]),
                        Elem ! {populate,[lists:nth(Ind+1,PIDList)]};
                    Ind == Len ->
                        % io:format("Element ~p~n",[Elem]),
                        Elem ! {populate,[lists:nth(Ind-1,PIDList)]};
                    true ->
                        % io:format("Element ~p~n",[Elem]),
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList)]}
                end
                end,PIDList),
                listener ! {Len,PIDList,TimeStart},
    RS = rand:uniform(NumNodes),
    StartPID = lists:nth(RS, PIDList),
    StartPID ! {RS,1};
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

grid2d(NumNodes,Algorithm)->
    io:format("Inside the 2d function\n"),
    TimeStart = erlang:monotonic_time()/10000,
    register(listener,spawn(nmanager,listener,[1,[],TimeStart])),
    io:format("Listener is up\n"),
    if Algorithm == "gossip" ->
        io:format("here goes the code for the gossip in a 3-D Grid.\n"),
         Rows = erlang:trunc(math:sqrt(NumNodes)),
        io:format("Rows ~p~n",[Rows]),
        Total = Rows * Rows,
        io:format("Total elements ~p~n", [Total]),
        PIDList = gspawner_Nodes(Total,[]),
        io:format("PID_list ~p~n\n",[PIDList]),
        lists:foreach(fun(Elem)->
        Ind = string:str(PIDList, [Elem]),
        Mod = Ind rem Rows,
        if
            Ind =< Rows -> %For all the bottom elements
                if
                    Mod ==1  ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind+Rows,PIDList)]};
                    Mod == 0->
                        Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList)]};
                    true ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList)]}
                end;
                Total-Ind < Rows-> %For all top elements
                if
                    Mod ==1 ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-Rows,PIDList)]};
                    Mod == 0->
                        Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind-Rows,PIDList)]};
                    true ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind-Rows,PIDList)]}
                end;
            true -> %For all the middle elements
                if
                    Mod ==1  ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]};
                    Mod == 0->
                        Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]};
                    true ->
                        Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]}
                end
        end
        end,PIDList),
        Len = length(PIDList),
        listener ! {Len,PIDList},
        Start_PID = lists:nth(rand:uniform(length(PIDList)), PIDList),    
        % io:format("~w",[Start_PID]), 
        % io:format("~w",[erlang:is_process_alive(Start_PID)]),
        Start_PID ! {rumour};
    Algorithm == "push-sum" ->
        io:format("here goes the code for the push-sum Algorithm in a 3-D Grid.\n"),
        Rows = erlang:trunc(math:sqrt(NumNodes)),
       io:format("Rows ~p~n",[Rows]),
       Total = Rows * Rows,
       io:format("Total elements ~p~n", [Total]),
       PIDList = psspawner_Nodes(NumNodes,[],1),
       io:format("PID_list ~p~n\n",[PIDList]),
       lists:foreach(fun(Elem)->
       Ind = string:str(PIDList, [Elem]),
       Mod = Ind rem Rows,
       if
           Ind =< Rows -> %For all the bottom elements
               if
                   Mod ==1  ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind+Rows,PIDList)]};
                   Mod == 0->
                       Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList)]};
                   true ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList)]}
               end;
               Total-Ind < Rows-> %For all top elements
               if
                   Mod ==1 ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-Rows,PIDList)]};
                   Mod == 0->
                       Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind-Rows,PIDList)]};
                   true ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind-Rows,PIDList)]}
               end;
           true -> %For all the middle elements
               if
                   Mod ==1  ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]};
                   Mod == 0->
                       Elem ! {populate,[lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]};
                   true ->
                       Elem ! {populate,[lists:nth(Ind+1,PIDList),lists:nth(Ind-1,PIDList),lists:nth(Ind+Rows,PIDList),lists:nth(Ind-Rows,PIDList)]}
               end
       end
       end,PIDList),
       NPIDList = lists:sublist(PIDList,Total),
       listener ! {Total,NPIDList},   
        RS = rand:uniform(length(NPIDList)),
        StartPID = lists:nth(RS, NPIDList),
        StartPID ! {RS,1};
    true ->
        io:format("The Algorithm you have mentioned doesnt match our database.\n")
    end.

% imperfect3d(NumNodes,Algorithm)->
%     if Algorithm == "gossip" ->
%         io:format("here goes the code for the gossip in a imperfect 3-D Grid.\n");
%     Algorithm == "push-sum" ->
%         io:format("here goes the code for the push-sum Algorithm in a imperfect 3-D Grid.\n");
%     true ->
%         io:format("The Algorithm you have mentioned doesnt match our database.\n")
%     end.
        

% This can be called our Network manager, this will control the topologies and which Algorithm to go for.