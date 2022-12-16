-module(client).

-compile(export_all).

-define(ENG_ADD, erlang:list_to_atom("eng@" ++ engine:ip())).
% -define(ENG_ADD, 'eng@192.168.1.212').
-define(ENGINE, {listener, ?ENG_ADD}).

ip() ->
    ?ENG_ADD.

client() ->
    % % ip=`ifconfig en0 | grep "inet " | awk -F'[: ]+' '{ print $2 }'`
    % {ok, L} = inet:getif(),
    % Ip = lists:concat(
    %          lists:join(".", erlang:tuple_to_list(element(1, hd(L))))),
    % net_kernel:start(
    %     erlang:list_to_atom(ClientName ++ "@" ++ Ip), #{name_domain => longnames}),
    net_adm:ping(?ENG_ADD),
    register(clientListener, spawn(?MODULE, clientListener, [])).

init() ->
    persistent_term:put(loggedIn, false),
    {_, Inp} = io:read("SignIn(1) or New User(2): "),
    if Inp == 1 ->
           UserName =
               string:strip(
                   io:get_line("User Name: "), right, $\n),
           signin(UserName);
       Inp == 2 ->
           UserName =
               string:strip(
                   io:get_line("User Name: "), right, $\n),
           case newUser(UserName) of
               failed ->
                   io:format("User already exists~n");
               success ->
                   io:format("SignUp successfull~n")
           end
    end.

signin(UserName) ->
    ?ENGINE ! {signin, UserName, {node(), self()}},
    receive
        failed ->
            io:format("Sign-In failed~n");
        success ->
            io:format("SignIn successfull~n"),
            persistent_term:put(loggedIn, true),
            % since the simulator will store all the persistent terms
            % we need to have uniques keys for the timeline map
            persistent_term:put(
                string:concat(UserName, "Timeline"), maps:new()),
            persistent_term:put(uname, UserName)
    end.

newUser(UserName) ->
    ?ENGINE ! {signup, UserName, {node(), self()}},
    receive
        failed ->
            failed;
        success ->
            persistent_term:put(loggedIn, true),
            % since the simulator will store all the persistent terms
            % we need to have uniques keys for the timeline map
            persistent_term:put(
                string:concat(UserName, "Timeline"), maps:new()),
            persistent_term:put(uname, UserName),
            success
    end.

clientListener() ->
    receive
        {receiveTweet, TweeterName, Tweets} ->
            io:format("~nTimeline:~p~n", [Tweets]),
            UserName = persistent_term:get(uname),
            TweetMap =
                persistent_term:get(
                    string:concat(UserName, "Timeline")),
            persistent_term:put(
                string:concat(UserName, "Timeline"),
                maps:update_with(TweeterName,
                                 fun(OldVal) -> [Tweets | OldVal] end,
                                 [Tweets],
                                 TweetMap)),
            clientListener();
        nores ->
            io:format("No results found~n"),
            clientListener()
    end.

tweet() ->
    Text =
        string:strip(
            io:get_line("Tweet: "), right, $\n),
    sendTweet(persistent_term:get(uname), Text).

sendTweet(UserName, Text) ->
    ?ENGINE ! {tweet, UserName, Text}.

searchMentions() ->
    SearchText =
        string:strip(
            io:get_line("Search term: "), right, $\n),
    ?ENGINE ! {search, mention, SearchText, {node(), self()}},
    receivePrint().

searchTags() ->
    SearchText =
        string:strip(
            io:get_line("Search term: "), right, $\n),
    ?ENGINE ! {search, tag, SearchText, {node(), self()}},
    receivePrint().

receivePrint() ->
    receive
        {searchResult, Data} ->
            io:format("~p~n", [Data]);
        nores ->
            io:format("no data found~n")
    end.

searchTweets() ->
    SearchText =
        string:strip(
            io:get_line("User Name: "), right, $\n),
    ?ENGINE ! {search, tweet, SearchText, {node(), self()}},
    receivePrint().

retweet() ->
    UserName = persistent_term:get(uname),
    Timeline =
        timeline(persistent_term:get(
                     string:concat(UserName, "Timeline"))),
    TweetId =
        string:strip(
            io:get_line("Tweet Id: "), right, $\n),
    {_, TweetText} = lists:nth(list_to_integer(TweetId), Timeline),
    ?ENGINE ! {retweet, persistent_term:get(uname), TweetText}.

subscribe() ->
    UserName =
        string:strip(
            io:get_line("User Name: "), right, $\n),
    sendSubscribe(persistent_term:get(uname), UserName).

sendSubscribe(Follower, Followee) ->
    ?ENGINE ! {subscribe, Follower, Followee, {node(), self()}},
    receive
        failed ->
            % io:format("Subscribe failed~n"),
            ok;
        success ->
            % io:format("Subscribe successfull~n"),
            ok
    end.

signout() ->
    ?ENGINE ! {signout, persistent_term:get(uname)},
    persistent_term:put(loggedIn, false),
    UserName = persistent_term:get(uname),
    persistent_term:erase(
        string:concat(UserName, "Timeline")),
    persistent_term:erase(uname).

timeline(Map) ->
    TimelineMap =
        maps:fold(fun(K, V, AccIn) ->
                     Appended = addNameToTweet(K, V, []),
                     lists:append(Appended, AccIn)
                  end,
                  [],
                  Map),
    Timeline = lists:enumerate(TimelineMap),
    io:format("~p~n", [Timeline]),
    Timeline.

addNameToTweet(_, [], Acc) ->
    Acc;
addNameToTweet(Uname, [H | T], Acc) ->
    addNameToTweet(Uname, T, [string:concat("RT:" ++ Uname ++ " ", H) | Acc]).

printTweets() ->
    UserName = persistent_term:get(uname),
    persistent_term:get(
        string:concat(UserName, "Timeline")).

timeline() ->
    timeline(printTweets()).

clientSim(UserName) ->
    receive
        signup ->
            newUser(UserName);
        signin ->
            signin(UserName);
        signout ->
            ?ENGINE ! {signout, UserName},
            ignore();
        {tweet, Text} ->
            sendTweet(UserName, Text);
        {subscribe, FollowList} ->
            ?ENGINE ! {subscribeList, UserName, FollowList};
        exit ->
            exit(kill);
        _ ->
            ok
    end,
    clientSim(UserName).

ignore() ->
    receive
        exit ->
            exit(kill);
        {tweet, _} ->
            engine:simulator() ! tweet,
            ignore();
        _ ->
            ignore()
    end.
