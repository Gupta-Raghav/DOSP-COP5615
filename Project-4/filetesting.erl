-module(filetesting).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).

test() ->
    MentionedTweets = ["Tweet 1", "tweet 2", "tweet 3"],
     lists:foreach(fun(Tweet)->
                 %io:format("Tweet Found:     ~p~n", [Tweet])
                 file:write_file("output.txt", io_lib:fwrite("Tweet Found:     ~p~n", [MentionedTweets]), [append])
                 end, MentionedTweets).
    %file:write_file("/output", io_lib:fwrite("Tweet Found:     ~p~n", [MentionedTweets]), append).
    %file:write_file("output.txt", io_lib:fwrite("Tweet Found:     ~p~n", [MentionedTweets]), [append]).