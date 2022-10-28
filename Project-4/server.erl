-module(server).
-compile(export_all).

hash(Rstring)->
    <<Hashed:256>> = crypto:hash(sha256, Rstring),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    Ahstring = string:to_lower(HashStr),
    Ahstring.


listener(UMap,Ulist,Plist)->
    
    receive
        {Client,Uname, Pass} ->
            io:format("~p________Client is trying to connect_______________~p~n",[Client,Uname]),
           
            Hashpass = hash(Pass),
            HashUname = hash(Uname),
            Flag = maps:is_key(HashUname,UMap),
            % io:format("~p HashUname ~n",[HashUname]),
            if
                Flag ->
                    Client ! {failed,"Username Already taken.\n try different username.\n"},
                    % io:format("~p Map ~n",[UMap]),
                    listener(UMap,Ulist,Plist);
                true ->
                    Client ! {successful,"Welcome"},
                    UNmap = maps:put(HashUname,Hashpass,UMap), 
                    % io:format("~p Map ~n",[UNmap]),
                    listener(UNmap,Ulist,Plist)
            end
    end.

start()->
    Map = maps:new(),
    register(server,spawn(server,listener,[Map,[],[]])),
    listener(Map,[],[]).

