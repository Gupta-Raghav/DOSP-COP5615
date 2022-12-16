-module(engine).

-compile(export_all).

-define(IP, "10.20.0.10").
-define(SIM_ADD, erlang:list_to_atom("sim@" ++ ?IP)).
% -define(ENG_ADD, 'eng@192.168.1.212').
-define(SIM, {sim, ?SIM_ADD}).
-define(SEND(Message),
        case persistent_term:get(sim, false) of
            true ->
                % io:format("~p to synchronizer~n",[Message]),
                ?SIM ! Message;
            false ->
                ok
        end).

send(Message) ->
    ?SEND(Message).

ip() ->
    ?IP.

simulator() ->
    ?SIM.

% map of #{userName => {nodeName}}
% map of hashtags #{"#Cricket" => ["tweets"]}
% map of mentions #{"@userName" => ["tweets that mention userName"]}
% list of connected users to send live tweets
% followerMap map of userName and the users subscribed to the userName #{userName => [users that follow userName]}
% followee map of userName and the users the userName follows #{userName => [users that userName follows]}
% re:run("Here's a #hashtag and here is #hashtag #", "(#+[a-zA-Z0-9(_)]+)",[global,{capture,first,list}]).

%each client should maintian a list of followers and followees -> followerMap and followee
%each client should also maintain a state of whether they are logged in or not -> deliver tweets live without querying the server
%hashmap in the engine for followers and followees
%connectedNode has users connected that will receive live tweets

engine() ->
    % {ok, L} = inet:getif(),
    % Ip = lists:concat(
    %          lists:join(".", erlang:tuple_to_list(element(1, hd(L))))),
    % net_kernel:start(
    %     erlang:list_to_atom("eng@" ++ Ip), #{name_domain => longnames}),
    register(listener,
             spawn(?MODULE,
                   listener,
                   [maps:new(), maps:new(), maps:new(), maps:new(), maps:new(), maps:new()])).

sim() ->
    persistent_term:put(sim, true),
    engine().

broadcast(Followers, TweeterName, Tweet, ConnectedNodes) ->
    %for each user in the userlist, send the tweet to the node
    % io:format("UserNodes: ~p~n", [UserNodes]),
    % io:format("ConnectedNodes ~p~n", [ConnectedNodes]),
    % io:format("Tweet: ~p~n", [Tweet]),
    lists:foreach(fun(Follower) ->
                     Flag = maps:is_key(Follower, ConnectedNodes),
                     {Connected, {NodeID, _}} = maps:get(Follower, ConnectedNodes),
                     if Flag, Connected ->
                            {clientListener, NodeID} ! {receiveTweet, TweeterName, Tweet};
                        true -> ok
                     end
                  end,
                  Followers).

% user -> []
% tweeter -> [newTweet | oldTweet]
% retweet: append "RT @tweeter: " to the tweet

listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets) ->
    receive
        clear ->
            listener(maps:new(), maps:new(), maps:new(), maps:new(), maps:new(), maps:new());
        printU ->
            io:format("~nUsers:~p~n", [ConnectedUsers]),
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        printM ->
            io:format("~nMentions:~p~n", [Mentions]),
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        printFollower ->
            io:format("~nFollowerMap:~p~n", [FollowerMap]),
            % maps:foreach(fun(K, V) -> io:format("~p:~p~n", [K, length(V)]) end, FollowerMap),
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        printFollowing ->
            io:format("~nFollowingMap:~p~n", [FollowingMap]),
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        printH ->
            io:format("~nTags:~p~n", [Hashtags]),
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        {signup, UserName, ConnectedVia} ->
            % io:format("~nSignUp:~p~n", [UserName]),
            ExistingUser = maps:is_key(UserName, ConnectedUsers),
            PID = ConnectedVia,
            if ExistingUser ->
                   PID ! failed,
                   listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
               true ->
                   PID ! success,
                %    ?SEND(signup),
                io:format("SignUp:~p~n", [UserName]),
                   
                   listener(maps:put(UserName, {true, ConnectedVia}, ConnectedUsers),
                            Hashtags,
                            Mentions,
                            maps:put(UserName, [], FollowerMap),
                            maps:put(UserName, [], FollowingMap),
                            maps:put(UserName, [], Tweets))
            end;
        {signin, UserName, ConnectedVia} ->
            ExistingUser = maps:is_key(UserName, ConnectedUsers),
            PID = ConnectedVia,
            if ExistingUser ->
                   PID ! success,
                   % overwrite the existing connection details
                   listener(maps:put(UserName, {true, ConnectedVia}, ConnectedUsers),
                            Hashtags,
                            Mentions,
                            FollowerMap,
                            FollowingMap,
                            Tweets);
               true ->
                   PID ! failed,
                   listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets)
            end;
        {signout, Uname} ->
            ExistingUser = maps:is_key(Uname, ConnectedUsers),
            if ExistingUser ->
                   {_, ConnectedVia} = maps:get(Uname, ConnectedUsers),
                   io:format("~nSignOut:~p~n", [Uname]),
                   listener(maps:put(Uname, {false, ConnectedVia}, ConnectedUsers),
                            Hashtags,
                            Mentions,
                            FollowerMap,
                            FollowingMap,
                            Tweets);
               true ->
                   listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets)
            end;
        {tweet, Uname, Text} ->
            NewTags = parseHashTags(Text, Hashtags),
            NewMentions = parseMentions(Text, Mentions),
            %broadcast the tweet to all the users in the list
            Followers = maps:get(Uname, FollowerMap, []),
            % Tweet = Uname ++ ": " ++ Text,
            broadcast(Followers, Uname, Text, ConnectedUsers),
            ?SEND(tweet),
            %add the tweet to the user's tweet list
            NewTweets =
                maps:update_with(Uname, fun(UTweets) -> [Text | UTweets] end, [Text], Tweets),
            % io:format("~nNewTweets: ~p~n", [NewTweets]),
            listener(ConnectedUsers, NewTags, NewMentions, FollowerMap, FollowingMap, NewTweets);
        {retweet, Uname, Text} ->
            NewTags = parseHashTags(Text, Hashtags),
            NewMentions = parseMentions(Text, Mentions),
            %broadcast the tweet to all the users in the list
            Followers = maps:get(Uname, FollowerMap, []),
            % Tweet = Uname ++ ": " ++ Text,
            broadcast(Followers, Uname, Text, ConnectedUsers),
            %add the tweet to the user's tweet list
            NewTweets =
                maps:update_with(Uname, fun(UTweets) -> [Text | UTweets] end, [Text], Tweets),
            % io:format("~nNewTweets: ~p~n", [NewTweets]),
            listener(ConnectedUsers, NewTags, NewMentions, FollowerMap, FollowingMap, NewTweets);
        {search, tag, Tag, ConnectedVia} ->
            {_, PID} = ConnectedVia,
            case maps:is_key(Tag, Hashtags) of
                true ->
                    PID ! {searchResult, maps:get(Tag, Hashtags)};
                false ->
                    PID ! nores
            end,
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        {search, tweet, Uname, ConnectedVia} ->
            {_, PID} = ConnectedVia,
            case maps:is_key(Uname, Tweets) of
                true ->
                    PID ! {searchResult, maps:get(Uname, Tweets)};
                false ->
                    PID ! nores
            end,
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets);
        {subscribe, Follower, UserName, ConnectedVia} ->
            %add the user to the list of followers of the user
            %add the user to the list of followees of the user
            PID= ConnectedVia,
            UserExist = maps:is_key(UserName, ConnectedUsers),
            if UserExist ->
                   FollowerExist = maps:is_key(Follower, ConnectedUsers),
                   if FollowerExist ->
                          NewFollowerMap =
                              maps:update_with(UserName,
                                               fun(Followers) -> [Follower | Followers] end,
                                               [Follower],
                                               FollowerMap),
                          NewFollowingMap =
                              maps:update_with(Follower,
                                               fun(Followees) -> [UserName | Followees] end,
                                               [UserName],
                                               FollowingMap),
                          PID ! success,
                          ?SEND(subscribe),
                          listener(ConnectedUsers,
                                   Hashtags,
                                   Mentions,
                                   NewFollowerMap,
                                   NewFollowingMap,
                                   Tweets);
                      true ->
                          %if the follower does not exist, send a failed message
                          PID ! failed,
                          listener(ConnectedUsers,
                                   Hashtags,
                                   Mentions,
                                   FollowerMap,
                                   FollowingMap,
                                   Tweets)
                   end;
               true ->
                   %if the user you are trying to follow does not exist, send a failed message
                   PID ! failed,
                   listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets)
            end;
        {subscribeList, Follower, UserNameList} ->
            %add the user to the list of followers of the user
            %add the user to the list of followees of the user
            % {_, PID} = ConnectedVia,
            {NewFollowerMap, NewFollowingMap} =
                subscribeAll(Follower, UserNameList, FollowerMap, FollowingMap, ConnectedUsers),
            listener(ConnectedUsers, Hashtags, Mentions, NewFollowerMap, NewFollowingMap, Tweets);
        {search, mention, Uname, ConnectedVia} ->
            {_, PID} = ConnectedVia,
            case maps:is_key(Uname, Mentions) of
                true ->
                    PID ! {searchResult, maps:get(Uname, Mentions)};
                false ->
                    PID ! nores
            end,
            listener(ConnectedUsers, Hashtags, Mentions, FollowerMap, FollowingMap, Tweets)
    end.

subscribeAll(_, [], FollowerMap, FollowingMap, _) ->
    ?SEND(subscribe),
    {FollowerMap, FollowingMap};
subscribeAll(Follower, [UserName | T], FollowerMap, FollowingMap, ConnectedUsers) ->
    case maps:is_key(UserName, ConnectedUsers) of
        true ->
            NewFollowerMap =
                maps:update_with(UserName,
                                 fun(Followers) -> [Follower | Followers] end,
                                 [Follower],
                                 FollowerMap),
            NewFollowingMap =
                maps:update_with(Follower,
                                 fun(Followees) -> [UserName | Followees] end,
                                 [UserName],
                                 FollowingMap),
            subscribeAll(Follower, T, NewFollowerMap, NewFollowingMap, ConnectedUsers);
        _ ->
            subscribeAll(Follower, T, FollowerMap, FollowingMap, ConnectedUsers)
    end.

parseHashTags(Text, HashTags) ->
    Data = re:run(Text, "(#+[a-zA-Z0-9(_)]+)", [global, {capture, first, list}]),
    case Data of
        nomatch ->
            HashTags;
        {match, LLTags} ->
            Tags =
                sets:to_list(
                    sets:from_list(
                        lists:merge(LLTags))),
            addOrReplace(Tags, Text, HashTags)
    end.

parseMentions(Text, Mentions) ->
    Data = re:run(Text, "(@+[a-zA-Z0-9(_)]+)", [global, {capture, first, list}]),
    case Data of
        nomatch ->
            Mentions;
        {match, LLMentions} ->
            Names =
                sets:to_list(
                    sets:from_list(
                        lists:merge(LLMentions))),
            addOrReplace(Names, Text, Mentions)
    end.

% need to add tweet to the list of existing tweets that mention the userName/hash tag
% if the userName/hashtag does not exist in the map, create a new key
addOrReplace([], _, MentionsMap) ->
    MentionsMap;
addOrReplace([Name | UserNames], Tweet, MentionsMap) ->
    case maps:is_key(Name, MentionsMap) of
        true ->
            ListOfTweets = maps:get(Name, MentionsMap),
            addOrReplace(UserNames, Tweet, maps:put(Name, [Tweet | ListOfTweets], MentionsMap));
        false ->
            addOrReplace(UserNames, Tweet, maps:put(Name, [Tweet], MentionsMap))
    end.

connect(Node) ->
    {Module, Binary, Filename} = code:get_object_code(worker),
    rpc:call(Node, code, load_binary, [Module, Filename, Binary]).

printusers() ->
    listener ! printU.

printmentions() ->
    listener ! printM.

printtags() ->
    listener ! printH.

printfollowers() ->
    listener ! printFollower.

printfollowing() ->
    listener ! printFollowing.

clear() ->
    listener ! clear.
