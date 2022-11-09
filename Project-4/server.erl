-module(server).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).


hash(Rstring)->
    <<Hashed:256>> = crypto:hash(sha256, Rstring),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    Ahstring = string:to_lower(HashStr),
    Ahstring.

signup(Client,Uname, Pass,UMap,PMap ) ->
    
    Hashpass = hash(Pass),
    HashUname = hash(Uname),
    Flag = maps:is_key(HashUname,UMap),
    if
        Flag ->
            Client ! {failed,"Username Already taken.\n try different username.\n"},
            UMap;
        true ->
            Client ! {successful,"Welcome"},
            UNmap = maps:put(HashUname,Hashpass,UMap), 
            PNMap = maps:put(Uname, Client, PMap),
            {UNmap,PNMap}
    end.
signin(Client,Uname, Pass,UMap,PMap)->
    Hashpass = hash(Pass),
            HashUname = hash(Uname),
            Flag = maps:is_key(HashUname,UMap), %If the hashed username matches.
            if
                Flag ->
                    Cpass = maps:get(HashUname,UMap),
                    % only if the password matches
                    if
                        Cpass == Hashpass ->
                        Client ! {successful,"Successfully logged-in."},
                        PNMap = maps:put(Uname, Client, PMap),
                        PNMap;
                        true ->
                        Client ! {failed,"Login-failed, Password that you entered is wrong."}
                    end;
                true ->
                    Client ! {failed,"Username that you entered does not exist. Create an account with new keyword."}
            end.
signout(Client, Uname, PMap) ->
    Flag = maps:is_key(Uname, PMap),
    if 
        Flag->
            NPMap = maps:remove(Uname, PMap),
            Client ! {successful,"Successfully logged-out."},
            NPMap;
        true->
            Client ! {failed,"Username that you entered does not exist"}
    end.

tweet(Client, Uname, Tweet, TMap, HTMap, MMap, FollowersMap) ->
    Keys = maps:keys(TMap),
    if 
        length(Keys) == 0 ->
            TweetID = 1;
        true ->
            TweetID = lists:max(Keys) + 1
    end,
    NewHTMap = find_hashtags(Tweet, TweetID, HTMap),
    NewTMap = maps:put(TweetID, {Uname, {Tweet, calendar:now_to_datetime(erlang:timestamp())}}, TMap),
    io:format("Tweets:   ~p~n", [NewTMap]),
    Client ! {successful, "Successfully tweeted"},
    {NewTMap, NewHTMap}.



find_hashtags("", TweetID, HTMap) ->
    io:format("HTMap:   ~p~n", [HTMap]),
    HTMap;
find_hashtags(Tweet, TweetID, HTMap) ->
    NewTweet = string:find(Tweet, "#"),
    if 
        NewTweet == nomatch ->
            HTMap;
        true ->
            Words = string:lexemes(NewTweet, " "),
            Hashtag = lists:nth(1, Words),
            Bool = maps:is_key(Hashtag, HTMap),
            if
                Bool ->
                    ExistingTweets = maps:get(Hashtag, HTMap),
                    NewHTMmap = maps:update(Hashtag, lists:append(ExistingTweets, [TweetID]), HTMap);
                true ->
                    NewHTMmap = maps:put(Hashtag, [TweetID], HTMap)
            end,
            RemoveHT = re:replace(NewTweet, "#", "", [{return,list}]),
            find_hashtags(RemoveHT, TweetID, NewHTMmap)
    end.




%UMap: list of all users
%PMap: list of active users
%TMap: Map of all tweets
%HTMap: hashtag map
%MMap: mentions map
listener(UMap, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap)->
    receive
        {Client,Uname, Pass,new} ->
            io:format("~p________Client is trying to connect_______________~p~n",[Client,Uname]),
            {UNmap, PNMap}= signup(Client,Uname, Pass,UMap,PMap),
            listener(UNmap, PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap);
        {Client,Uname, Pass,signIn} ->
            io:format("~p________Client is trying to connect_______________~p~n",[Client,Uname]),
            PNMap = signin(Client,Uname, Pass,UMap,PMap),
            io:format("Clients online:  ~p~n",[PNMap]),
            listener(UMap, PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap);
        {Client, Uname, signOut} ->
            io:format("~p____Client signing out_____~p~n",[Client, Uname]),
            PNMap = signout(Client, Uname, PMap),
            io:format("Clients online:  ~p~n",[PNMap]),
            listener(UMap,PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap);

        %% 8/11/2022 Tweet Functionality
        {Client, Uname, Tweet, tweet}->
            {NewTMap, NewHTMap} = tweet(Client, Uname, Tweet, TMap, HTMap, MMap, FollowersMap),
            listener(UMap, PMap, NewTMap, NewHTMap, MMap, FollowersMap, FollowingMap)    

    end.

start()->
    Map = maps:new(),
    PMap = maps:new(),
    TMap = maps:new(),
    HTMap = maps:new(),
    MMap = maps:new(),
    FollowersMap = maps:new(),
    FollowingMap = maps:new(),
    register(server,spawn(server,listener,[Map, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap])),
    listener(Map, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap).











% Funcitons:
% inside start
    % receive 
    % 1.) "new" -> call to signup. 
    % 2.) 'signin' -> call to signin.
    % 3.) "tweet" -> call to method tweet.
    % 4.) "subscribe" -> call to subscribe.
    % 5.) "retweet" -> in one way or the other call the tweet funciton itself.
    %      6.) timeline -> shows the timeline of the user in chronological order.    
    % 7.) querries
    %   i.) hashtag
    %   ii.) mention
    %   iii.) tweet  


% we will accept PID(Self of client in every function) for message passing. 
% Data structures:
% Map of users (Key -> username, value:{password}).
% tweet of all users (Key -> Tweet_ID, value:{tweet}) => tweet itself will be some data structure. -> funciton for processing hashtags, mentions once done
% send the tweet to the users(Broadcast).
% Single tweet data structure : list of (Username, text, timestamp).
% Hashtag : map of hashtag (key-> #_{name} , value: [Tweet Id](list of tweet IDs))
% Mentions : map of mentions (key -> @_{username}, value: [tweet id](list of tweet IDs)).
% Followers : map of followers (key -> @_{username}, value: [@_followers](list of followers username)).
% Following : map of following (key -> @_{username}, value: [{@_followers,number of tweets}](list of followers username)).
% Followers and following get's updated every time a user1 subscribes to user2.
% 