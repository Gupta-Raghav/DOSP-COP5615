-module(client).
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

listener(Add,Username,Pass)->
% list of actions
% syntax for the acitons.
Keyword = string:trim(io:get_line("Choose the action you want to perform: ")),
        if
            Keyword == "signout" ->
                    {server, Add} ! {self(),Username,signOut},
                    exit(normal);

            %% 8/11/2022 Tweet Functionality

            Keyword == "tweet" ->
                Tweet = string:trim(io:get_line("Enter your tweet: ")),
                {server, Add} ! {self(), Username, Tweet, tweet};
        
            % 11/11/2022 Follow 
            Keyword == "follow" ->
                Follow = string:trim(io:get_line("type @ of the username you want to follow: ")),
                {server, Add} ! {self(), Username, Follow, follow};

            Keyword == "queryht" ->
                KW = string:trim(io:get_line("Enter hashtag to be queried: ")),
                {server, Add} ! {self(), Username, KW, queryht};

            Keyword == "querymention" ->
                {server, Add} ! {self(), Username, querymention};

            true ->
                io:format("check the keyword you entered\n"),
                listener(Add,Username,Pass)
        end,   
        receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass);
            {queryresult, MentionedTweets} ->
                lists:foreach(fun(Tweet)->
                io:format("Tweet Found:     ~p~n", [Tweet])
                end, MentionedTweets),
                listener(Add,Username,Pass);

            {broadcast,Following,Twt} ->
                io:format("[~p]~n : ~p~n",[Following,Twt]),
                listener(Add,Username,Pass)
        end.


start(Add)->
    Keyword = string:trim(io:get_line("Choose the action you want to perform: ")),
    Username =string:trim(io:get_line("Choose a Username: ")),
    Pass = string:trim(io:get_line("Choose a Strong password: ")),
    
    if
    Keyword == "new"->
        {server, Add} ! {self(),Username,Pass,new},
            receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                start(Add);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass)
            end;
    Keyword == "signin" ->
        {server, Add} ! {self(),Username,Pass,signIn},
        receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                start(Add);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass)
        end;
    true ->
        start(Add)
    end.