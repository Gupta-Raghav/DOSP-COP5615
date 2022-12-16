-module(landing_handler).
% -behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    %start the server
    % check if the server is already running
    % if not, start it
    % if yes, return an error
    Engine = whereis('listener'),
    if Engine == undefined ->
        io:format("Starting the server~n"),
        engine:engine(),
        io:format("Server started~n");
    true ->
        io:format("Server already running~n")
    end,


    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Welcome to Twitter">>,
        Req0),
    {ok, Req, State}.
