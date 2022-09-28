-module(master).
-import(client,[start/1]).
-import(server, [server_output/2]).

-compile(export_all).
-define(Noworkers,100).
master_start(K) ->
    %NEED TO MAKE AN OUTPUT FUNCTION
    receive
        {up,Client_PID} ->
            io:format("here\n"),
         %Registering the output function in the server module.
        register(output, spawn(server, server_output, [?Noworkers+1,self()])),
        spawner(?Noworkers,K), %spawner function to spawn the given number of actors/workers.
        bitcoin_finder(output, K,Client_PID)
    end.

local_time_test(K) ->
        register(output, spawn(server, server_output, [?Noworkers+1,self()])),
        spawner(?Noworkers,K), %spawner function to spawn the given number of actors/workers.
        bitcoin_finder(output, K).

spawner(Count,_) when Count==0->
    ok;  
spawner(Count,K)->
    spawn(client, start, [K]), %The K here is the argument for the client:start function
    spawner(Count-1, K). %loop



bitcoin_finder(output,K) -> 
        Random = (base64:encode_to_string(crypto:strong_rand_bytes(60))),
        UFID =
            "gupta.raghav;",
        RString = string:concat(UFID,Random),
        <<Hashed:256>> = crypto:hash(sha256, RString),
        HashStr = string:right(integer_to_list(Hashed,16),64,$0),
        Ahstring = string:to_lower(HashStr),
        SubStr = string:substr(Ahstring, 1, K),
        Zero_string = lists:concat(lists:duplicate(K, "0")),
        
        if
            SubStr == Zero_string ->
                output ! {RString,Ahstring},
                list();
                true ->
                    bitcoin_finder(output,K)
        end.
list()->
    receive
       found ->
               ok
        end.

bitcoin_finder(output,K,Client_PID) -> 
	Random = (base64:encode_to_string(crypto:strong_rand_bytes(60))),
    UFID =
        "gupta.raghav;",
    RString = string:concat(UFID,Random),
    <<Hashed:256>> = crypto:hash(sha256, RString),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    Ahstring = string:to_lower(HashStr),
    SubStr = string:substr(Ahstring, 1, K),
    Zero_string = lists:concat(lists:duplicate(K, "0")),
    
    if
        SubStr == Zero_string ->
			output ! {RString,Ahstring},
            list(Client_PID);
            true ->
                bitcoin_finder(output,K,Client_PID)
    end.
list(Client_PID)->
    receive
        found ->
        Client_PID ! done,
        shutup()
end.
shutup() ->
    io:format("The Run time stops here\n"),
    init:stop(),
    ok.

mstart(K) ->
    register(listener, spawn(master,master_start,[K])),
    master_start(K).
    