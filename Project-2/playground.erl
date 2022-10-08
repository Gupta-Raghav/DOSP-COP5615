-module(playground).

-export([start/0]).

start()->
    Lst=[1000,123,12334,123435,1232136,12357,1238654],
    % io:fwrite("~w~n",[Lst]),
    Tail = lists:last(Lst),
    List = lists:droplast(Lst),
    [H|T]=List,
    io:format("~w~n",[H]),
    io:format("~w~n",[T]),
    io:format("~w~n",[Tail]).

    % lists:foreach(fun(Elem)->
    %                     Ind = string:str(Lst, [Elem]),
    %                     io:format("~p~n",[lists:nth(Ind,Lst)])
    %                     % io:format("index ~w\n",[Ind])
    %                     end,Lst).
    % X = rand:uniform(length(Lst)),
    % io:format("X=~w\n",[X]),
    % Result = lists:nth(X, Lst),
    % io:fwrite("~p\n",[Result]).

    %io:fwrite("~p~n",[lists:nth(X, Lst)]).
