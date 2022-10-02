-module(playground).

-export([start/0]).

start()->
    Lst=[1000,123,12334,123435,1232136,12357,1238654],
    io:fwrite("~w~n",[Lst]),
    % lists:foreach(fun(Elem)->
    %                     io:format("element~w\n",[Elem])
    %                     end,Lst).
    % NList = lists:enumerate(Lst),
    
    % NList.
    X = rand:uniform(length(Lst)),
    io:format("X=~w\n",[X]),
    Result = lists:nth(X, Lst),
    io:fwrite("~p\n",[Result]).

    %io:fwrite("~p~n",[lists:nth(X, Lst)]).
