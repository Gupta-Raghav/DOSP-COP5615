-module(node).
-export([start/7]).

start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)->
    % io:format("Node with Id ~p Existing Nodes ~p and value of M ~p~n",[ID,Existing_Nodes,M]),

    % io:format("Suc: ~p,Pre: ~p~n",[Sc,Pr]),
    receive
        {lookup,K}->
            search(K,ID,Sc,Ft,0);
        {createFt,NodeList}->
            FingerTable = ft_node(1,M,ID,NodeList,No,Ft,Sc,Pr),
            listener ! {fingertablecreated},
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr);
        {updateSP,S,P} ->
            listener ! {doneupdating},
            start(ID,M,Existing_Nodes,No,Ft,S,P);
        {populate}->
            % populateKeys(),
            listener ! done_populating;
        {askSucessor,Sk,PID} ->
            {SId,SNode} = Sc,
            if
                Sk =< SId ->

                    PID ! {Sc};
                true -> 
                    %  io:format("inside the false statement~n"),
                     SNode ! {askSucessor,Sk,PID}
            end, 
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)
    end.

% binary search
% middle element
% low , high
nearest(Key,Fingert,It)->
    nearest.


search(Skey,Id,Scc={SID,SPid},Ft,Hops)->
    if
        Skey > Id, Skey=<SID ->
            listener ! {found};
        Id > SID, Skey=<SID ->
            listener ! {found};
        Id > SID, Skey > SID ->
            listener ! {found}; 
        true ->
            nearest(Skey,Ft,length(Ft))
    end.


    
ft_node(I,Ftm,ID,_,_,Ft,_,_) when I ==Ftm+1->
    io:format("Finger Table for Id ~p is ~p~n",[ID,Ft]),
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
                        % io:format("Successor ~p~n",[Sucessor]),
                        ft_node(I+1,FtM,Id,Nodes,No,[{SKey,Sucessor}|Ft],S,P)
                end 
        end.
        
