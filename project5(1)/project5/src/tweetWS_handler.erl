
-module(tweetWS_handler).
-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2]).
init(Req0, State) ->
    case cowboy_req:parse_header(<<"sec-websocket-protocol">>, Req0) of
        undefined ->
            {cowboy_websocket, Req0, State};
        Subprotocols ->
            case lists:keymember(<<"mqtt">>, 1, Subprotocols) of
                true ->
                    Req = cowboy_req:set_resp_header(<<"sec-websocket-protocol">>, <<"mqtt">>, Req0),
                    {cowboy_websocket, Req, State};
                false ->
                    Req = cowboy_req:reply(400, Req0),
                    {ok, Req, State}
            end
    end.
    % {cowboy_websocket, Req, State}.

websocket_init(State) ->
    erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    io:format("Received: ~p~n", [Msg]),

    {reply, [{text, <<"Thats what she said! ", Msg/binary >>}], State};

websocket_handle(_Data, State) ->
    {[], State}.


websocket_info({timeout, _Ref, Msg}, State) ->
    erlang:start_timer(1000, self(), <<"How are we doing?">>),
    {reply, {text, Msg}, State};

websocket_info(_Info, State) ->
    {[], State}.

% websocket_terminate(Reason, Req, State) ->
%     ok.


