-module(client2).
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

start(Add)->
    Username =io:get_line("Chosoe a Username: "),
    %  "gupta.raghav",
    Pass = io:get_line("Chosoe a Strong password: "),
    % Username = "Aliya.abdullah",
    % Pass = "DOBRAKIJAI",
    % % Username = "gupta.raghav",
    % % Pass = "DOSPKiJAI",
    {server, Add} ! {self(),Username,Pass},
    receive
        {failed,Msg} ->
            io:format("_______________Auth Failed._____________________________~n [Server]: ~p~n",[Msg]);
       {successful,Msg} ->
            io:format("_______________Auth successfully done.__________________~n [Server]: ~p~n",[Msg])
            % start(Add)   
    end.
