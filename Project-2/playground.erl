-module(playground).

-export([start/0]).

start()->
    % Lst=[1000,123,12334,123435,1232136,12357,1238654],
    Lst = [12,3244,132354,123,123,51,6678,48,12],
    Total = 4,
    % X = [{R , C} || R <- lists:seq(1, 3), C <- lists:seq(2, 3)],
    % io:format("~p~n",[X]).
%     Lst=[1000,123,12334,123435,1232136,12357,1238654],
%     % io:fwrite("~w~n",[Lst]),
%     Tail = lists:last(Lst),
%     List = lists:droplast(Lst),
%     [H|T]=List,
%     io:format("~w~n",[H]),
%     io:format("~w~n",[T]),
%     io:format("~w~n",[Tail]).
% lists:foreach(fun(Elem)->
%     Elem ! {populate,lists:delete(Elem,PIDlist)}
%     end,PIDlist),
%     listener ! {Len,PIDlist}
    Nlist = lists:sublist(Lst,5),
    io:format("Nlist ~p~n",[Nlist]).
    % lists:splitwith(fun(A)->
    %     Ind = string:str(Lst, [A]),
    %     io:format("~p~n",[A]),
    %     Total-Ind >= 0 end, [Lst]).
    % X = rand:uniform(length(Lst)),
    % io:format("X=~w\n",[X]),
    % Result = lists:nth(X, Lst),
    % io:fwrite("~p\n",[Result]).

    %io:fwrite("~p~n",[lists:nth(X, Lst)]).
