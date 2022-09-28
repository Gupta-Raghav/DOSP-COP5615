-module(server).
-import(string,[substr/3]).
-export([
    server_output/2
]).

% this is my pong process
%shall I spawn the processes in here? I think we can have a spawner>> that simply creates actors for us that works for us.
%server basically only prints the output for us and communicates to the client and may be the workers.

server_output(0,MPID) ->
    MPID ! found,
    ok;
server_output(Count,MPID) ->
        receive
        {RString,Ahstring} ->
            io:format("Found the string with given zeroes ~s",[RString]),
            io:format(" -> The following hashed string ~s\n",[Ahstring]),
            server_output(Count-1,MPID)
        end.


%so basically we are looking for 701 
