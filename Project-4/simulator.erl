-module(simulator).
-compile([export_all, nowarn_ignored, nowarn_unused_vars]).

start(Add, N)->
    statistics(wall_clock),
    PID =spawn(simulator, listener,[N,N]),
    register(simListener,PID),
    FTot = (((N-1)*(N))/2),
    % io:format("~p~n",[FTot]),
    FPID =spawn(simulator, flistener,[N,FTot]),
    register(fListener,FPID),
    TPID =spawn(simulator, tlistener,[N,N]),
    register(tListener,TPID),
    UserList = spawner(N,Add, [],PID,FPID,TPID),
    lists:foreach(fun(Client)->
                    % io:format("~p Client~n",[Client])
                    {Name, ClientPID}= Client,
                    I=string:str(UserList, [Client]),
                    List = lists:nthtail(I,UserList),
                    % io:format("~p List for ~p ~n",[List, Client]),
                    ClientPID ! {follow, List}
                 end,UserList),
                %  io:format("____________Starting Tweet Simulation_____________~n"),
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
flistener(N,Count) when Count==2 ->
    {_,TimeEnd} = statistics(wall_clock),
    io:format("Time taken to Follow ~p seconds~n", [TimeEnd/1000]);
    % io:format("Simulating Follow requests ~n");

flistener(N,Count)->
    % io:format("~p~n",[Count]),
    receive
        {success} ->
            % io:format("~p~n",[Count]),
            flistener(N,Count-1)
    end.

tlistener(N,Count) when Count==0.4*(N) ->
    {_,TimeEnd} = statistics(wall_clock),
    io:format("Time taken to Tweet ~p seconds~n", [TimeEnd/1000]);
    % io:format("Simulating Follow requests ~n");

tlistener(N,Count)->
    receive
        {success} ->
            % io:format("~p~n",[Count]),
            tlistener(N,Count-1)
    end.


% TweetCount==0.8*(TweetCount)


listener(N,SignUpCount) when SignUpCount==0 ->
    {_,TimeEnd} = statistics(wall_clock),
    io:format("Time taken to Singup new users ~p seconds~n", [TimeEnd/1000]);
    % io:format("Simulating Follow requests ~n");

% listener(N,SignUpCount) when SignUpCount==0 ->
%     {_,TimeEnd} = statistics(wall_clock),
%     io:format("Time taken to Tweet ~p seconds~n", [TimeEnd/1000]);
%     % io:format("Simulating Follow requests ~n");

listener(N,SignUpCount)->
    receive
        {singUpSuccess} ->
            listener(N,SignUpCount-1)
    end.

spawner(0,_,Users,_,_,_)->
    Users;
spawner(NUsers, Add,Users,LPid,FPID,TPID)->
    % io:format(NUsers-1),
    N = integer_to_list(NUsers),
    Name = string:concat("User",N),
    PID = spawn(clienttest, start, [Add,"new",Name, Name,LPid,FPID,TPID]),
    spawner(NUsers-1, Add, [{Name,PID} | Users],LPid,FPID,TPID). 