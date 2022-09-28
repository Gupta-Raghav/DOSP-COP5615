-module(client).
-compile(export_all).

client_start(Address) ->
    {listener,Address} ! {up,self()},
    receive
        done ->
            ok    
    end.

start(K) -> %this is for the local code implementation.
            bitcoin_finder(K).

stop()->
    ok.
%This is our Miner code that mines a single bitcoin.
bitcoin_finder(K) -> %work unit of a single worker: A single worker generates a random string,concatinates it, finds the hash value and compare the string as well. 
  Random = (base64:encode_to_string(crypto:strong_rand_bytes(60))),
    UFID =
        "gupta.raghav;",
    RString = string:concat(UFID,Random),
    <<Hashed:256>> = crypto:hash(sha256, RString),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    Ahstring = string:to_lower(HashStr),    
    SubStr = string:substr(Ahstring, 1, K),
    %generating a string of K 0's
    Zero_string = lists:concat(lists:duplicate(K, "0")),
    if
        %Comparing the strings to find THE string.
        SubStr == Zero_string ->
            output ! {RString, Ahstring},
            stop(); %This is where we draw the line or end the work unit of a single worker. while(you found a string){if yes then you are done} else {you keep finding THE coin} 
        true ->
            bitcoin_finder(K) %going for recursion if the worker doesn't find a coin.
    end.
