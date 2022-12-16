-module(project5_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

% start(_Type, _Args) ->
	
start(_Type, _Args) ->
    %start the engine/server
    engine:engine(),
    Dispatch = cowboy_router:compile([
% {HostMatch, list({PathMatch, Handler, InitialState})}
        {'_', [
        {"/", landing_handler, []}, %this is the landing-page route which starts the engine
        {"/tweet", tweetWS_handler, []}, %this is tweet websocket handler
        {"/signup", signup_handler, []}, %this is regisration route
        {"/login", login_handler, []}, %this is login route
        {"/subscribe", subscribe_handler, []},
        {"/client", cowboy_static, {priv_file, project5, "index.html"}}, %this is the client route which serves the client
        {"/static/[...]", cowboy_static, {priv_dir, project5, "static"}}
        ]}
    
]),
        %register user handler
    %     {'_',[{"/tweet", tweetWS_handler, []}]},
    %     {'_', [{"/login", login_handler, []}]},
    %     {'_', [{"/register", register_handler, []}]}
    % ]),
    {ok, _} = cowboy:start_clear(http,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    project5_sup:start_link().


stop(_State) ->
	ok = cowboy:stop_listener(http).
