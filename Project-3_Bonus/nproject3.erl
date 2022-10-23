-module(nproject3).

-export([start/2]).

iterator(0,Ms)->
    Ms;

iterator(N,M)->
    iterator(N bsr 1,M+1).

create_chord(0,_,_,NList,_,_) ->
    NList;

create_chord(NNodes,ID,M,List,Nreq,No)->
    if
        ID ==1 ->
            Pr = 0;
        true ->
            Pr = ID-1   
    end,
    addNode(ID,NNodes,No,M,List,Nreq,0,Pr).

start(NumNodes,NumRequests)->
    M = iterator(NumNodes,0),
    io:format("Nodes to be Checked: ~p~n",[NumNodes]),
    io:format("Requests to be checked: ~p~n",[NumRequests]),
    io:format("Finger tuple contains: ~p~n tuples",[M]),
    io:format("NumNodes ~p~n",[NumNodes]),
    create_chord(NumNodes,1,M,[],NumRequests,NumNodes).


addNode(Id,N,No,M,NodeList,Nreq,Succ,Pred)->
    Tuple = {Id,self()},
    Node = spawn(playground, start, [Tuple,M,NodeList,No,[],Succ,Pred]),
    % Map = maps:new(),
    create_chord(N-1,Id+1,M,[Node|NodeList],Nreq,No).


% stabalize()->
%     % io:format("Here"),
%     stabalize.