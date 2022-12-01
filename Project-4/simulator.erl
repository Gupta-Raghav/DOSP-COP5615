-module(simulator).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).

start(Add, N)->
    statistics(wall_clock),
    PID =spawn(simulator, listener,[N,N,N]),
    register(simListener,PID),
    UserList = spawner(N,Add, [],PID),
    lists:foreach(fun(Client)->
                    % io:format("~p Client~n",[Client])
                    {Name, ClientPID}= Client,
                    I=string:str(UserList, [Client]),
                    List = lists:nthtail(I,UserList),
                    % io:format("~p List for ~p ~n",[List, Client]),
                    ClientPID ! {follow, List}
                 end,UserList),
                 timer:sleep(500),
    lists:foreach(fun(Client)->
                    % io:format("~p Client~n",[Client])
                    {Name, ClientPID}= Client,
                    % io:format("~p Client Name ~n",[Name]),
                    % io:format("~p Client PID ~n",[PID])
                    A= rand:uniform(10),
                    if
                        A >= 8->
                            ClientPID ! {signout};
                        true ->
                          ok  
                    end,
                    ClientPID ! {tweet, Name}
                 end,UserList).
    % FollowList = lists:sublist(UserList, N/2),
    % follow(N, Add,FollowList).
 


% follow(N, Add,FollowList)->
%     % N = integer_to_list(NUsers),
%     % Name = string:concat("User",N),
%     PID = spawn(clienttest, start, [Add,"new",Name, Name,self()]),
%     io:format("waiting....~n"),
%     receive
%            {From, Add,Keyword,Username, Pass, Receiver} -> 
%             io:format("~p ~p~p~p~p~p~n",[From,Add,Keyword,Username, Pass, Receiver]);
%             {From, Msg} ->
%                 io:format("~p ~p~n",[From,Msg]) 
%     end,
%     spawner(NUsers-1, Add, [{Name,PID} | Users]). 
listener(N,SignUpCount,_) when SignUpCount==0 ->
    {_,TimeEnd} = statistics(wall_clock),
    io:format("Time taken to Singup new users ~p seconds~n", [TimeEnd/1000]),
    io:format("Simulating Follow requests ~n");

listener(N,_,TweetCount) when TweetCount==0.8*(TweetCount) ->
    {_,TimeEnd} = statistics(wall_clock),
    io:format("Time taken to Tweet ~p seconds~n", [TimeEnd/1000]);
    % io:format("Simulating Follow requests ~n");

listener(N,SignUpCount,TweetCount)->
    receive
        {singUpSuccess} ->
            listener(N,SignUpCount-1,TweetCount);
        {tweetSuccess} ->
            io:format("tweet message ~p~n",[TweetCount]),
            listener(N,SignUpCount,TweetCount-1)
    end.

spawner(0,_,Users,_)->
    Users;
spawner(NUsers, Add,Users,LPid)->
    % io:format(NUsers-1),
    N = integer_to_list(NUsers),
    Name = string:concat("User",N),
    PID = spawn(clienttest, start, [Add,"new",Name, Name,LPid]),
    spawner(NUsers-1, Add, [{Name,PID} | Users],LPid). 