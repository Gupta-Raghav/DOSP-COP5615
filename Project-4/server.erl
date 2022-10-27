-module(server).
-compile(export_all).



listener()->
    receive
        {Client} ->
            io:format("~p Client is up~n",[Client]),
            Client ! {"Welcome",self()},
            listener()
    end.


start()->
    register(server,spawn(server,listener,[])),
    listener().

