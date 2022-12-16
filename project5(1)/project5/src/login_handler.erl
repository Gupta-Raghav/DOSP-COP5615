
-module(login_handler).
% -behavior(cowboy_handler).

-export([init/2, handle/2]).

init(Req0, State) ->
    %parse signup?username=munish
    QsVal = cowboy_req:parse_qs(Req0),
    {_, Value} = lists:keyfind(<<"username">>, 1, QsVal),
    io:format("Value: ~p~n", [Value]),
    
    listener ! {signin, Value, self() },
    receive
        failed ->
            io:format("Failed to login user~n"),
            Req = cowboy_req:reply(400, 
                #{<<"content-type">> => <<"text/plain">>},
                <<"Error in Login">>,
                Req0),
            {ok, Req, State};
        success ->
            io:format("User login~n"),
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"text/plain">>},
                <<"User Login Successfully">>,
                Req0),
            {ok, Req, State}
    end.


handle(Req0, State) ->
    %read the body for username
    QsVal = cowboy_req:parse_qs(cowboy_req:body(Req0)),
    io:format("QsVal: ~p~n", [QsVal]),

    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        <<"Hello Erlang!; test">>,
        Req0),
    {ok, Req, State}.

    %parse the body
