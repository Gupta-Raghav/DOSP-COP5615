-module(project3).
-compile(export_all).
-export([start/1,listener/4,lookupListener/3]).


% iterate the node list to start doing the lookup.
% everytime it finds something it replies back to the listener.
% listener wait for all the numNodes * numRequests number of messages and then exits after printing the 
% the average of the hops.
lookup(_,0,_)->
    ok;

lookup(M,N,List)->
    Key = rand:uniform(round(math:pow(2,10)))-1,
    lists:foreach(fun({_,Node})->
                % io:format("sending ~p Node ~p time~n",[N,Node]),
                Node ! {lookup,Key}
                end,List),
    lookup(M,N-1,List).

lookupListener(Total,AvgH,Div) when Total ==0->
    io:format("Average hops = ~p~n",[AvgH/Div]);

lookupListener(Total,AvgH,Div)->
    receive
        {found,Id,Scc,Skey,Hops} ->
            % io:format("Lookup listener count ~p\n",[Total]), 
            % io:format("Found  ~p  at node ~p  starting from node ~p~n",[Skey, Scc, Id]),
            lookupListener(Total-1,AvgH+Hops,Div)
    end.


listener(M,N,List,NumRequests) when N ==0->
    % io:format("starting lookup.\n"),
    
    % lookupListener(T,Hops,T),
    % lookup(List);
    lookup(M,NumRequests,List);


listener(M,N,NodeList,NumRequests) ->
    receive
        {Num,List}->
            % io:format("received nlist~p~n",[List]),
            lists:foreach(fun({_,Node})->
                Node ! {createFt,List},  
                receive
                    {fingertablecreated} ->
                        ok
                end
                end,List),
            listener(M,0,List,NumRequests)
    end.


start([_NumNodes,_NumRequests])->
    NumNodes = list_to_integer(_NumNodes),
    NumRequests = list_to_integer(_NumRequests),
    M = 5,
    io:format("Nodes to be Checked: ~p~n",[NumNodes]),
    io:format("Requests to be checked: ~p~n",[NumRequests]),
    io:format("Finger tuple contains: ~p~n tuples",[M]),
    register(listener, spawn(project3, listener, [M,NumNodes,[],NumRequests])),
    T = NumRequests*NumNodes,
    register(lookupListener, spawn(project3, lookupListener, [T,0,T])),
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

lookup(Nodelist)->
    receive
        {lookup,Key} ->
            {_,Node} =lists:nth(1, Nodelist),
            Node ! {lookup,Key},
            lookup(Nodelist)
    end.

z(Key)->
    listener ! {lookup, Key}.
