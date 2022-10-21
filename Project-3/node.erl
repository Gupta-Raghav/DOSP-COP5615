-module(node).
-export([start/7]).

start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)->
    % io:format("Node with Id ~p Existing Nodes ~p and value of M ~p~n",[ID,Existing_Nodes,M]),

    % io:format("Suc: ~p,Pre: ~p~n",[Sc,Pr]),
    receive
        {createFt,NodeList}->
            FingerTable = ft_node(1,M,ID,NodeList,No,Ft),
            listener ! {FingerTable};
        {updateSP,S,P} ->
            start(ID,M,Existing_Nodes,No,Ft,S,P);
        {populate}->
            % populateKeys(),
            listener ! done_populating



    end.
    % Keys = lists:seq(P, ID).


    
ft_node(I,Ftm,_,_,_,Ft) when I ==Ftm+1->
    Ft;

ft_node(I,FtM,Id, Nodes,No,Ft)->
    
        X = erlang:trunc(Id + math:pow(2,I-1)),
        Snode = (X) rem (No), 
        if
            Snode ==0 ->
                   ft_node(I+1,FtM,Id,Nodes,No,[X|Ft]);
            true ->
                ft_node(I+1,FtM,Id,Nodes,No,[Snode|Ft])
        end.
        
