-module(nNode).

-export([start/1]).

start(Tuple)->
    % assigning keys
    [Id|Pid] = tuple_to_list(Tuple),
    KeyList = assign_keys(Id,[],0,4),
    io:format("Tuple value ~p~n",[KeyList]).


assign_keys(Id,List,It,K) when It ==K ->
    List;

assign_keys(Id,List,It,K)->
    assign_keys(Id+It,[Id|List],It+1,K).
    