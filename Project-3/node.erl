-module(node).
-export([start/7]).

start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)->
    % io:format("Node with Id ~p Existing Nodes ~p and value of M ~p~n",[ID,Existing_Nodes,M]),

    % io:format("Suc: ~p,Pre: ~p~n",[Sc,Pr]),
    receive
        {createFt,NodeList}->
            FingerTable = ft_node(1,M,ID,NodeList,No,Ft,Sc,Pr),
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr),
            listener ! {FingerTable};
        {updateSP,S,P} ->
            start(ID,M,Existing_Nodes,No,Ft,S,P),
            listener ! {doneupdating};
        {populate}->
            % populateKeys(),
            listener ! done_populating;
        {askSucessor,Sk,PID} ->
            {SNode,SId} = Sc,
            if
                Sk =< SId ->
                    PID ! {Sc};
                true ->
                    SNode ! {askSucessor,Sk,PID}
            end, 
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)
    end.
    % Keys = lists:seq(P, ID).


    
ft_node(I,Ftm,ID,_,_,Ft,_,_) when I ==Ftm+1->
    % io:format("Finger Table for Id ~p is ~p~n",[ID,Ft]),
    Ft;

ft_node(I,FtM,Id, Nodes,No,Ft,S,P)->
    
        Key = erlang:trunc(Id + math:pow(2,I-1)),
        SKey = (Key+1) rem round(math:pow(2,FtM)),
        % io:format("Calculating for ID ~p \t Key ~p, Skey: ~p~n",[Id,Key,SKey]),
        {SId ,SNode} = S,
        % io:format("Above  SId:~p, Skey: ~p~n",[SId,SKey]),
        if
            SKey=<SId->
                ft_node(I+1,FtM,Id,Nodes,No,[{SKey,S}|Ft],S,P);
                % io:format("I , Skey,S : ~p ~p ~p~n",[I,SKey,S]);
            SKey > SId ->
                % io:format("Below SId:~p, Skey: ~p~n",[SId,SKey]),
                SNode ! {askSucessor,SKey,self()},
                receive
                    {Sucessor}->
                        ft_node(I+1,FtM,Id,Nodes,No,[{SKey,Sucessor}|Ft],S,P)
                end 
        end.
        
