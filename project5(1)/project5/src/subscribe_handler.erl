
-module(subscribe_handler).
% -behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    %parse subscribe?username=munish&following=prakhar
    QsVal = cowboy_req:parse_qs(Req0),
    {_, Follower} = lists:keyfind(<<"username">>, 1, QsVal),
    {_, Following} = lists:keyfind(<<"following">>, 1, QsVal),
    
    listener ! {subscribe, Follower, Following, self() },
    
    receive
        failed ->
            io:format("~p could not subscribe to ~p~n", [Follower, Following]),
            Req = cowboy_req:reply(400, 
                #{<<"content-type">> => <<"text/plain">>},
                <<"Error in Subscribing">>,
                Req0),
            {ok, Req, State};
        success ->
            io:format("~p subscribed to ~p~n", [Follower, Following]),
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"text/plain">>},
                <<"Subscribition Successfull">>,
                Req0),
            {ok, Req, State}
    end.


    %parse the body
