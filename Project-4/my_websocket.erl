-module(my_websocket).
-export([start/0]).

start() ->
  % Start the cowboy web server on port 8000, with a protocol
  % handler for websockets.
  cowboy:start_http(my_http_listener, 100, [{port, 8000}],
                    [{env, [{dispatch, [{'_', [{"/websocket", cowboy_websocket, websocket_handler}]}]}]}]).

% This is the websocket protocol handler.
websocket_handler(Req, Socket) ->
  % Send a message to the client when the websocket is opened.
  cowboy:send(Socket, <<"Hello, client!">>),
  % Loop forever, receiving messages from the client and
  % sending them back (echo server).
  receive
    {cowboy_websocket, Socket, <<"Hello, server!">>} ->
      cowboy:send(Socket, <<"Hello, client!">>);
    {cowboy_websocket, Socket, Msg} ->
      cowboy:send(Socket, Msg)
  end.
