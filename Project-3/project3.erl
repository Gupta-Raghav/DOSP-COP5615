-module(project3).

-export([start/2,listener/0]).

iterator(0,Ms)->
    Ms;

iterator(N,M)->
    iterator(N bsr 1,M+1).


assign_keys(M,List) ->
        lists:foreach(fun({Id,Node})->
            Node ! {keys, lists:seq()}
            end,List),
        g.
    
listener() ->
    receive
        {KeyMap} ->
            io:format("Finger Table ~p~n",[KeyMap]),
            listener()
    end.


start(NumNodes,NumRequests)->
    M = 3,
    io:format("Nodes to be Checked: ~p~n",[NumNodes]),
    io:format("Requests to be checked: ~p~n",[NumRequests]),
    io:format("Finger tuple contains: ~p~n tuples",[M]),
    register(listener, spawn(project3, listener, [])),
    create_chord(NumNodes,M,[],NumRequests,[]).

create_chord(0,M,NodeList,_,_)->
    % io:format("Id list~p~n",[IdList]),
    NList = lists:keysort(1,NodeList),
    io:format("Node list sorted~p~n",[NList]),
    lists:foreach(fun({Id,Node})->
                    Ind = string:str(NList, [{Id,Node}]),
                    if
                        Ind ==1 ->
                            Node ! {updateSP, lists:nth(Ind + 1, NList),lists:nth(length(NList), NList)};
                        Ind ==length(NList) ->
                            Node ! {updateSP, lists:nth(1, NList),lists:nth(Ind - 1, NList)};
                        true ->
                            Node ! {updateSP, lists:nth(Ind + 1, NList),lists:nth(Ind-1, NList)}
                    end
                    end,NList),
    lists:foreach(fun({_,Node})->
                Node ! {createFt,NList}    
                end,NList);
    % assign_keys(M,NList);     
    % assign keys.
    % Ft creation.
    % NodeList;

create_chord(N,M,NodeList,Nreq,IdList)->
    Id= rand:uniform(round(math:pow(2,M))),
    Flag = lists:member(Id,IdList),
    if
        Flag ->
            create_chord(N,M,NodeList,Nreq,IdList);
        true -> 
            Node = spawn(node, start, [Id,M,NodeList,N,[],0,0]),
            NodeId = {Id,Node},
            create_chord(N-1,M,[NodeId|NodeList],Nreq,[Id|IdList])
    end.
    

stabalize()->
    find_successor(),
    stabalize.

find_successor()->
    ask.


