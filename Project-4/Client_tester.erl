-module(clientT).
-compile(export_all).


spawner(0,List,_)->
    List;

spawner(Num, List,Add)->
    CNode = spawn(client,bear,[Num,Add]),
    {server,Add} ! {CNode},
    spawner(Num-1,[CNode|List],Add).

bear(N,Add)->
    % {server,Add} ! {self()},
    receive
        {Message, PID}->
            io:format("From ~p Message ~p~n",[PID,Message]),
            bear(N-1,Add)
    end.

start(N,Add)->
    NList = spawner(N,[],Add),
    io:format("Nlist ~p~n",[NList]).
    