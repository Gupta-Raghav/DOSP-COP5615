-module(clienttest).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).


% spawner(0,List,_)->
%     List;

% spawner(Num, List,Add)->
%     CNode = spawn(client,bear,[Num,Add]),
%     {server,Add} ! {CNode},
%     spawner(Num-1,[CNode|List],Add).

% bear(N,Add)->
%     % {server,Add} ! {self()},
%     receive
%         {Message, PID}->
%             io:format("From ~p Message ~p~n",[PID,Message]),
%             bear(N-1,Add)
%     end.

listener(Add,Username,Pass, Receiver)->
% list of actions
% syntax for the acitons.
% Keyword = string:trim(io:get_line("Choose the action you want to perform: ~n")),

        receive
            {signout} ->
                    {server, Add} ! {Receiver,Username,signOut},
                    exit(Receiver, normal),
                    exit(normal);

            %% 8/11/2022 Tweet Functionality

            {tweet, Tweet} ->
                % Tweet = string:trim(io:get_line("Enter your tweet: ")),
                tweet(Add, Receiver,Username,Tweet);
                % {server, Add} ! {Receiver, Username, Tweet, tweet};
        
            % 11/11/2022 Follow 
            {follow, List} ->
                % Follow = string:trim(io:get_line("type @ of the username you want to follow: ")),
                N = length(List),
                follow(Add,Receiver, Username, List, N);

            "queryht" ->
                KW = string:trim(io:get_line("Enter hashtag to be queried: ")),
                {server, Add} ! {Receiver, Username, KW, queryht};

            "querymention" ->
                {server, Add} ! {Receiver, Username, querymention};

            "retweet" ->
                TweetID = string:trim(io:get_line("Enter tweet id to retweet: ")),
                {server, Add} ! {Receiver, Username, list_to_integer(TweetID), retweet};

            true ->
                io:format("check the keyword you entered\n"),
                listener(Add,Username,Pass,Receiver)
        end,
        listener(Add,Username,Pass,Receiver).

tweet(Add, Receiver,Username, Tweet) ->
    {server, Add} ! {Receiver, Username, Tweet, tweet}.
    % ok.

follow(Add,Receiver, Username, Follow,0)->
    ok;
    % {server, Add} ! {Receiver, Username, Follow, follow};

follow(Add,Receiver, Username, List,N)->
    lists:foreach(fun(FollowElem)->
        {Follow, FPID} = FollowElem,
        {server, Add} ! {Receiver, Username, Follow, follow}
             end,List).
    


start(Add,Keyword,Username, Pass,SimPID)->
    % Keyword = string:trim(io:get_line("Choose the action you want to perform: ")),
    % Username =string:trim(io:get_line("Choose a Username: ")),
    % Pass = string:trim(io:get_line("Choose a Strong password: ")),
    Receiver = spawn(testReceiver, receiver, [Add,Username,Pass]),
    % SimPID ! {self(),Add,Keyword,Username, Pass,Receiver},
    % Receiver = self(),
    % SimPID ! {self(),whereis(server)},
    % SimPID ! {self(),Add,Keyword,Username, Pass,Receiver},
    % Msg = net_adm:ping('server@RGsLegion'),
    % SimPID ! {self(),Msg},
    if
    Keyword == "new"->
        {server, Add} ! {Receiver, self(), Username,Pass,new},
            receive 
            {failed,Msg} ->
                % io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                % SimPID ! {self(),Msg},
                start(Add,Keyword,Username, Pass,SimPID);
            {successful,Msg} ->
                % io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                SimPID ! {singUpSuccess},
                listener(Add,Username,Pass, Receiver)
            end;
    Keyword == "signin" ->
        {server, Add} ! {Receiver, self(), Username,Pass,signIn},
        receive 
            {failed,Msg} ->
                % io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                start(Add,Keyword,Username, Pass,SimPID);
            {successful,Msg} ->
                % io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass, Receiver)
        end;
    true ->
        start(Add,Keyword,Username, Pass,SimPID)
    end.