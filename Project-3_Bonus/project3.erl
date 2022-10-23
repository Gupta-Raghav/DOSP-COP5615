-module(project3).

-export([start/2,listener/2]).

lookup(List)->
    {_,Node} = lists:nth(1, List),
    {Key,_} = lists:nth(rand:uniform(length(List)), List),
    % io:format("Asking node ~p with key~p ~n",[Node,Key]),
    Node ! {lookup,Key}.

listener(N,List) when N ==0->
    % Start lookup after this
    io:format("starting lookup after this\n"),   
    lookup(List),
    %io:format("FT successfully filled"),
    receive
        {found,FNode,Key,H}->
            io:format("Hop on Fnode ~p with key~p : ~p~n",[FNode,Key,H])
    end,
    listener(0,List);


listener(N,NodeList) ->
    receive
        {Num,List}->
            io:format("received nlist~p~n",[List]),
            lists:foreach(fun({_,Node})->
                Node ! {createFt,List},  
                receive
                    {fingertablecreated} ->
                        ok
                end
                end,List),
            listener(0,List)
    end.


start(NumNodes,NumRequests)->
    M = 5,
    io:format("Nodes to be Checked: ~p~n",[NumNodes]),
    io:format("Requests to be checked: ~p~n",[NumRequests]),
    io:format("Finger tuple contains: ~p~n tuples",[M]),
    register(listener, spawn(project3, listener, [NumNodes,[]])),
    create_chord(NumNodes,M,[],NumRequests,[]).

create_chord(0,_,NodeList,_,_)->
    % io:format("Id list~p~n",[IdList]),
    NList = lists:keysort(1,NodeList),
    
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
    %io:format("Done creting the chord~n"),
    N = length(NList),
    listener ! {N,NList};
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
    

% stabalize()->
%     find_successor(),
%     stabalize.

% find_successor()->
%     ask.


