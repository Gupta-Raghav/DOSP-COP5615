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

listener(Add,Username,Pass, Receiver)->
% list of actions
% syntax for the acitons.
Keyword = string:trim(io:get_line("Choose the action you want to perform: ~n")),

        if
            Keyword == "signout" ->
                    {server, Add} ! {Receiver,Username,signOut},
                    exit(Receiver, normal),
                    exit(normal);

            %% 8/11/2022 Tweet Functionality

            Keyword == "tweet" ->
                Tweet = string:trim(io:get_line("Enter your tweet: ")),
                {server, Add} ! {Receiver, Username, Tweet, tweet};
        
            % 11/11/2022 Follow 
            Keyword == "follow" ->
                Follow = string:trim(io:get_line("type @ of the username you want to follow: ")),
                {server, Add} ! {Receiver, Username, Follow, follow};

            Keyword == "queryht" ->
                KW = string:trim(io:get_line("Enter hashtag to be queried: ")),
                {server, Add} ! {Receiver, Username, KW, queryht};

            Keyword == "querymention" ->
                {server, Add} ! {Receiver, Username, querymention};

            Keyword == "retweet" ->
                TweetID = string:trim(io:get_line("Enter tweet id to retweet: ")),
                {server, Add} ! {Receiver, Username, list_to_integer(TweetID), retweet};

            true ->
                io:format("check the keyword you entered\n"),
                listener(Add,Username,Pass,Receiver)
        end   ,
        % receive 
        %     {failed,Msg} ->
        %         io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
        %         listener(Add,Username,Pass);
        %     {successful,Msg} ->
        %         io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
        %         listener(Add,Username,Pass);
        %     {queryresult, MentionedTweets} ->
                
        %         lists:foreach(fun(Tweet)->
        %         %io:format("Tweet Found:     ~p~n", [Tweet])
        %         file:write_file("output.txt", io_lib:fwrite("Tweet Found:     ~p~n", [MentionedTweets]), [append])
        %         end, MentionedTweets),
        %         listener(Add,Username,Pass);

        %     {broadcast,Following,Twt} ->
        %         %io:format("[~p]~n : ~p~n",[Following,Twt]),
        %         file:write_file("output.txt", io_lib:fwrite("[~p]~n : ~p~n",[Following,Twt]), [append]),
        %         listener(Add,Username,Pass)
        listener(Add,Username,Pass,Receiver).




start(Add)->
    Keyword = string:trim(io:get_line("Choose the action you want to perform: ")),
    Username =string:trim(io:get_line("Choose a Username: ")),
    Pass = string:trim(io:get_line("Choose a Strong password: ")),
    Receiver = spawn(receiver, receiver, [Add,Username,Pass]),
    
    if
    Keyword == "new"->
        {server, Add} ! {Receiver, self(), Username,Pass,new},
            receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                start(Add);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass, Receiver)
            end;
    Keyword == "signin" ->
        {server, Add} ! {Receiver, self(), Username,Pass,signIn},
        receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                start(Add);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                listener(Add,Username,Pass, Receiver)
        end;
    true ->
        start(Add)
    end.