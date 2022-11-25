-module(receiver).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).


receiver(Add,Username,Pass) ->
    receive 
            {failed,Msg} ->
                io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]),
                receiver(Add,Username,Pass);
            {successful,Msg} ->
                io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg]),
                receiver(Add,Username,Pass);
            {queryresult, MentionedTweets} ->
                
                lists:foreach(fun(Tweet)->
                %io:format("Tweet Found:     ~p~n", [Tweet])
                file:write_file("output.txt", io_lib:fwrite("Tweet Found:     ~p~n", [MentionedTweets]), [append])
                end, MentionedTweets),
                receiver(Add,Username,Pass);

            {timeline, U, Tweet} ->
                file:write_file("output.txt", io_lib:fwrite("[~p]~n : ~p~n",[U,Tweet]), [append]),
                receiver(Add,Username,Pass);

            {broadcast,Following,Twt} ->
                %io:format("[~p]~n : ~p~n",[Following,Twt]),
                file:write_file("output.txt", io_lib:fwrite("[~p]~n : ~p~n",[Following,Twt]), [append]),
                receiver(Add,Username,Pass)
    end.