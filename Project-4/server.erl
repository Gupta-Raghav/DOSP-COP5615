-module(server).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).


hash(Rstring)->
    <<Hashed:256>> = crypto:hash(sha256, Rstring),
    HashStr = string:right(integer_to_list(Hashed,16),64,$0),
    Ahstring = string:to_lower(HashStr),
    Ahstring.

signup(Client,C, Uname, Pass,UMap,PMap ) ->
    
    Hashpass = hash(Pass),
    HashUname = hash(Uname),
    Flag = maps:is_key(HashUname,UMap),
    if
        Flag ->
            C ! {failed,"Username Already taken.\n try different username.\n"},
            UMap;
        true ->
            C ! {successful,"Welcome"},
            UNmap = maps:put(HashUname,Hashpass,UMap), 
            PNMap = maps:put(Uname, Client, PMap),
            {UNmap,PNMap}
    end.
signin(Client,C, Uname, Pass,UMap,PMap)->
    Hashpass = hash(Pass),
            HashUname = hash(Uname),
            Flag = maps:is_key(HashUname,UMap), %If the hashed username matches.
            if
                Flag ->
                    Cpass = maps:get(HashUname,UMap),
                    % only if the password matches
                    if
                        Cpass == Hashpass ->
                        C ! {successful,"Successfully logged-in."},
                        PNMap = maps:put(Uname, Client, PMap),
                        PNMap;
                        true ->
                        C ! {failed,"Login-failed, Password that you entered is wrong."}
                    end;
                true ->
                    C ! {failed,"Username that you entered does not exist. Create an account with new keyword."}
            end.
signout(Client, Uname, PMap, LMap) ->
    Flag = maps:is_key(Uname, PMap),
    if 
        Flag->
            NPMap = maps:remove(Uname, PMap),
            NLMap = maps:put(Uname, calendar:now_to_datetime(erlang:timestamp()), LMap),
            io:format("Logging out map:     ~p~n", [NLMap]),
            Client ! {successful,"Successfully logged-out."},
            {NPMap, NLMap};
        true->
            Client ! {failed,"Username that you entered does not exist"}
    end.

tweet(Client, Uname, Tweet, TMap, HTMap, MMap, FollowersMap, UMap) ->
    Keys = maps:keys(TMap),
    if 
        length(Keys) == 0 ->
            TweetID = 1;
        true ->
            TweetID = lists:max(Keys) + 1
    end,
    
    NewHTMap = find_hashtags(Tweet, TweetID, HTMap),
    NewMMap = find_mentions(Tweet, TweetID, MMap, UMap, Client),
    NewTMap = maps:put(TweetID, {Uname, {Tweet, calendar:now_to_datetime(erlang:timestamp())}}, TMap), 
    io:format("Tweets:   ~p~n", [NewTMap]),
    io:format("HTMap:   ~p~n", [NewHTMap]),
    io:format("MMap:   ~p~n", [NewMMap]),
    %% todo: broadcast function
    Client ! {successful, "Successfully tweeted"},
    {NewTMap, NewHTMap, NewMMap}.

broadcast(FollowersMap,PMap,Tweet,Uname)->
    Bool = maps:is_key(Uname, FollowersMap),
    if
        Bool ->
            
            List = maps:get(Uname,FollowersMap),
            %io:format("List ~p~n",[List]),
            lists:foreach(fun(Follower)->

                Flag = maps:is_key(Follower,PMap),
                if
                    Flag ->
                        io:format("Follower ~p~n",[maps:get(Follower, PMap)]),
                        maps:get(Follower, PMap) ! {broadcast,Uname,Tweet};
                    true ->
                        ok
                end
                    end,List);
        true ->
            ok
    end.


find_hashtags("", TweetID, HTMap) ->
    %io:format("HTMap:   ~p~n", [HTMap]),
    HTMap;
find_hashtags(Tweet, TweetID, HTMap) ->
    NewTweet = string:find(Tweet, "#"),
    %io:format("NewTweet:   ~p~n ", [NewTweet]),
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

find_mentions("", TweetID, NewMMap, UMap, Client) ->
    NewMMap;
find_mentions(Tweet, TweetID, MMap, UMap, Client) ->
    NewTweet = string:find(Tweet, "@"),
    %io:format("NewTweet:   ~p~n ", [NewTweet]),
    if 
        NewTweet == nomatch ->
            MMap;
        true ->
            Words = string:lexemes(NewTweet, " "),
            Mention = lists:nth(1, Words),
            DoesUserExists = maps:is_key(hash(re:replace(Mention, "@", "", [{return,list}])), UMap),
            if
                DoesUserExists ->
                    %% Should send message to user that they were mentioned?
                    Bool = maps:is_key(Mention, MMap),
                    if
                        Bool ->
                            ExistingTweets = maps:get(Mention, MMap),
                            NewMMap = maps:update(Mention, lists:append(ExistingTweets, [TweetID]), MMap);
                        true ->
                            NewMMap = maps:put(Mention, [TweetID], MMap)
                    end,
                    RemoveM = re:replace(NewTweet, "@", "", [{return,list}]),
                    find_mentions(RemoveM, TweetID, NewMMap, UMap, Client);

                true ->
                    %% Tweet is still stored. Only the mention is not processed.
                    Client ! {failed, "The user that you are trying to mention does not exist"},
                    MMap
            end      
    end.


follow(Client,Uname, Follow, FollowersMap, FollowingMap,UMap)->
    % io:format("Idhar aa chuka hun ~n"),
    Flag = maps:is_key(hash(Follow), UMap),    
    if
        Flag ->
            Flag2 = maps:is_key(Follow, FollowersMap),
            if
                Flag2 ->
                    ExistingFollowers= maps:get(Follow, FollowersMap), %fetching the exsisting followers
                    NewFollowersMap = maps:update(Follow, lists:append(ExistingFollowers, [Uname]), FollowersMap); % updating the existing followers with the new follower
                true ->
                    NewFollowersMap= maps:put(Follow, [Uname], FollowersMap) % else creating a new map in a way
            end,
            Flag3 = maps:is_key(Uname, FollowingMap),
            if
                Flag3 ->
                    ExistingFollowing= maps:get(Uname, FollowingMap), %fetching the exsisting following list of the user
                    NewFollowingMap = maps:update(Uname, lists:append(ExistingFollowing, [Follow]), FollowingMap);  % updating the existing followers with the new following
                true ->
                    NewFollowingMap= maps:put(Uname, [Follow], FollowingMap) % else creating a new map in a way
            end,
            io:format("NewFollowersMap ~p~n",[NewFollowersMap]),
            io:format("NewFollowingMap ~p~n",[NewFollowingMap]),
            Client ! {successful, "Followed the person"},
            {NewFollowersMap, NewFollowingMap};
        true ->
            Client ! {failed, "The user that you are trying to mention does not exist"},
            {FollowingMap,FollowersMap}
    end.


 queryht(Client, Uname, HT, HTMap, TweetMap) ->
    Hashtag = "#"++HT,
    Bool = maps:is_key(Hashtag, HTMap),

    if
        Bool ->
            Tweets = maps:get(Hashtag, HTMap),
            NewHTs = lists:map(fun(TweetID) ->
                Tweet = maps:get(TweetID, TweetMap),
                {U, {T, TimeStamp}} = Tweet,
                [U, T]
                end, Tweets),
            %io:format("MentionedTweets:   ~p~n", [NewHTs]),
            Client ! {queryresult, NewHTs};
        true ->
            Client ! {failed, "The hashtag you were trying to query does not exist"}
    end.

querymention(Client, Un, MMap, TweetMap) ->
    Uname = "@"++Un,
    Bool = maps:is_key(Uname, MMap),
    %io:format("Here:   ~p~n", [Uname]),
    if
        Bool ->
            Tweets = maps:get(Uname, MMap),
            % lists:foreach(fun(TweetID)->
            %     Tweet = maps:get(TweetID, TweetMap),
            %     {U, {T, TimeStamp}} = Tweet,
            %     io:format("appending:   ~p~n", [[U, T]]),
            %     lists:append(MentionedTweets, [[[U, T]]])
            % end, Tweets),
            NewMentions = lists:map(fun(TweetID) ->
                Tweet = maps:get(TweetID, TweetMap),
                {U, {T, TimeStamp}} = Tweet,
                [U, T]
                end, Tweets),
            io:format("MentionedTweets:   ~p~n", [NewMentions]),
            Client ! {queryresult, NewMentions};
        true ->
            Client ! {failed, "You have not been mentioned in any tweet"}
    end.



retweet(Client, Uname, TweetID, TMap, FollowersMap, PMap) ->
    Bool = maps:is_key(TweetID, TMap),
    if
        Bool ->
            Tweet = maps:get(TweetID, TMap),
            {U, {T, TimeStamp}} = Tweet,
            NewTweet = "RT@" ++ U ++ ": " ++ T,
            Keys = maps:keys(TMap),
            NewTweetID = TweetID = lists:max(Keys) + 1,
            NewTMap = maps:put(NewTweetID, {Uname, {NewTweet, calendar:now_to_datetime(erlang:timestamp())}}, TMap),
            broadcast(FollowersMap,PMap,NewTweet,Uname),
            NewTMap;
        true ->
            Client ! {failed, "Tweet does not exist"}
    end.

timeline(ClientR, Uname, TMap, LMap, FollowingMap) ->
    Bool = maps:is_key(Uname, LMap),
    if 
        Bool ->
            IfHasFollowing = maps:is_key(Uname, FollowingMap),
            if
                IfHasFollowing ->
                    Following = maps:get(Uname, FollowingMap),
                    Signout = maps:get(Uname, LMap),
                    maps:foreach(fun(TweetID, Tweet) ->
                        {U, {T, TimeStamp}} = Tweet,
                        IfFollowing = lists:member(U, Following),
                        if
                            IfFollowing ->
                                TSCompare = min(TimeStamp, Signout),
                                if 
                                    TSCompare == Signout ->
                                        ClientR ! {timeline, U, T};
                                    true ->
                                        ok
                                end;
                            true ->
                                ok
                        end
                        end, TMap);
                true ->
                    ok
            end;
        true ->
            ok
    end.



%UMap: list of all users
%PMap: list of active users
%TMap: Map of all tweets
%HTMap: hashtag map
%MMap: mentions map
%LMap: Last logout map
listener(UMap, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LMap)->
    receive
        {ClientR, Client, Uname, Pass,new} ->
            % io:format("~p________Client is trying to connect_______________~p~n",[Client,Uname]),
            {UNmap, PNMap}= signup(ClientR,Client,Uname, Pass,UMap,PMap),
            listener(UNmap, PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LMap);
        {ClientR,Client,Uname, Pass,signIn} ->
            io:format("~p________Client is trying to connect_______________~p~n",[Client,Uname]),
            PNMap = signin(ClientR,Client,Uname, Pass,UMap,PMap),
            timeline(ClientR, Uname, TMap, LMap, FollowingMap),
            io:format("Clients online:  ~p~n",[PNMap]),
            listener(UMap, PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LMap);
        {Client, Uname, signOut} ->
            io:format("~p____Client signing out_____~p~n",[Client, Uname]),
            {PNMap, LNMap} = signout(Client, Uname, PMap, LMap),
            io:format("Clients online:  ~p~n",[PNMap]),
            listener(UMap,PNMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LNMap);

        %% 8/11/2022 Tweet Functionality
        {Client, Uname, Tweet, tweet}->
            %io:format("User wants to tweet.~n"),
            {NewTMap, NewHTMap, NewMMap} = tweet(Client, Uname, Tweet, TMap, HTMap, MMap, FollowersMap, UMap),
            broadcast(FollowersMap,PMap,Tweet,Uname),
            listener(UMap, PMap, NewTMap, NewHTMap, NewMMap, FollowersMap, FollowingMap, LMap);

        % 11/11/2022 Follow Functionality
        {Client, Uname, FollowU, follow}->
            % io:format("Here.~n"),
            {NewFollowersMap, NewFollowingMap}= follow(Client,Uname, FollowU, FollowersMap, FollowingMap,UMap),
            listener(UMap, PMap, TMap, HTMap, MMap,NewFollowersMap, NewFollowingMap, LMap);

        {Client, Uname, Hashtag, queryht} ->
            queryht(Client, Uname, Hashtag, HTMap, TMap),
            listener(UMap, PMap, TMap, HTMap, MMap,FollowersMap, FollowingMap, LMap);

        {Client, Uname, querymention} ->
            %io:format("Here.~n"),
            querymention(Client, Uname, MMap, TMap),
            listener(UMap, PMap, TMap, HTMap, MMap,FollowersMap, FollowingMap, LMap);

        {Client, Uname, TweetID, retweet} ->
            NewTMap = retweet(Client, Uname, TweetID, TMap, FollowersMap, PMap),
            listener(UMap, PMap, NewTMap, HTMap, MMap,FollowersMap, FollowingMap, LMap);
        _ ->
            io:format("Default~n")

    end.

start()->
    Map = maps:new(),
    PMap = maps:new(),
    TMap = maps:new(),
    HTMap = maps:new(),
    MMap = maps:new(),
    LMap = maps:new(),
    FollowersMap = maps:new(),
    FollowingMap = maps:new(),
    UMap = map_populator(Map, ["raghav", "aliya", "prakhar", "dobra"]),
    io:format("done updating map ~n"),
    register(server,spawn(server,listener,[UMap, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LMap])).
    % listener(UMap, PMap, TMap, HTMap, MMap, FollowersMap, FollowingMap, LMap).

map_populator(Map, []) ->
    Map;
map_populator(Map, List) ->
    U = lists:last(List),
    NMap = maps:put(hash(U), hash(U), Map),
    map_populator(NMap, lists:droplast(List)).











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