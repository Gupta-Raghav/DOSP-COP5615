-module(client2).
-compile(export_all).


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

start(Add)->
    % list of actions
    % syntax for the acitons.
    Keyword = io:get_line("Choose the action you want to perform."),
    Username =io:get_line("Choose a Username: "),
    %  "gupta.raghav",
    Pass = io:get_line("Chosoe a Strong password: "),
    % Username = "Aliya.abdullah",
    % Pass = "DOBRAKIJAI",
    % % Username = "gupta.raghav",
    % % Pass = "DOSPKiJAI",
    {server, Add} ! {self(),Username,Pass,Keyword},
    receive 
        {failed,Msg} ->
            io:format("_______________Failed._____________________________~n [Server]: ~p~n",[Msg]);
       {successful,Msg} ->
            io:format("_______________successfull.__________________~n [Server]: ~p~n",[Msg])
    end.














%TO Do:
% recursive funciton for taking input constantly.
% ADd keyword for sign up
% implement Sign in, tweet, subscribe, timeline -> retweet, hashtag, Scheduler that runs every 5 sec for every user that shows new tweets.
% Pause scheduler when a specific funciton is running.
% 
% 
% 
%   
% 
% Data structures:
% Client struct : username, 
% 
