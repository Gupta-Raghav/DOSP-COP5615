-module(node).
-export([start/7]).

start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)->
    % io:format("Node with Id ~p Existing Nodes ~p and value of M ~p~n",[ID,Existing_Nodes,M]),

    % io:format("Suc: ~p,Pre: ~p~n",[Sc,Pr]),
    receive
        {lookup,K}->
            % io:format("Inside Lookup\n"),
            % io:format("here\n"),
            search(K,ID,Sc,Ft,0,round(math:pow(2,M))),
            % io:format("Id ~p Key ~p~n",[ID,K]),
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr);
        {continuesearch, K, Hop} ->
            % io:format("IN continue with hops : ~p~n",[Hop]),
            search(K,ID,Sc,Ft,Hop,round(math:pow(2,M))),
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr);
        {createFt,NodeList}->
            % io:format("Inside createft\n"),
            FingerTable = ft_node(1,M,ID,NodeList,No,Ft,Sc,Pr),
            io:format("ID ~p ft done: ~p~n",[ID,FingerTable]),
            listener ! {fingertablecreated},
            start(ID,M,Existing_Nodes,No,FingerTable,Sc,Pr);
        {updateSP,S,P} ->
            listener ! {doneupdating},
            start(ID,M,Existing_Nodes,No,Ft,S,P);
        {askSucessor,Sk,PID} ->
            contFT(Sk, PID, Sc, ID, M),
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)
    end.
nearest(ID,Key,Fingert,It,PID,Space)->
    if
        It ==0->
            {_,Succ} = lists:last(Fingert),
            Succ;
        true->
            {_, Finger={LId, _LPid}} = lists:nth(It,Fingert),
            if
                Key < ID->
                    io:format("here\n"),
                    {_,Succ} = lists:last(Fingert),
                    Finger;
                ID <LId, LId<Key ->
                    Finger;
                true ->
                    nearest(ID,Key,Fingert,It-1,PID,Space)  
            end
    end.


search(Skey,Id,Scc={SID,_},Ft,Hops,Space)->
    io:format("Inside Id ~p, Finger Table ~p Searching ~p~n",[Id,Ft,Skey]),
    if
        Id =<Skey ->
            lookupListener ! {found,Id,{Id, self()},Skey,Hops+1};
        Id > SID, Skey =< Id ->
            lookupListener ! {found,Id,Scc,Skey,Hops+1};
        Id > SID, Skey > Id ->
            lookupListener ! {found,Id,Scc,Skey,Hops+1};
        Skey > Id, Skey=<SID ->
            lookuupListener ! {found,Id,Scc,Skey,Hops+1};
        % Skey > Id, Skey > SID ->
        %     lookupListener ! {found,Id,Scc,Skey,Hops+1};
        true ->
            {_,SUCCPID} =  nearest(Id,Skey,Ft,length(Ft),self(),Space),
            % io:format("Succesor PID~p~n",[SUCCPID]),
            SUCCPID ! {continuesearch, Skey, Hops+1}
    end.


    
    ft_node(I,Ftm,ID,_,_,Ft,_,_) when I ==Ftm+1->
        FT = lists:reverse(Ft),
    %    io:format("Finger Table for Id ~p is ~p~n",[ID,FT]),
       FT;
   
   ft_node(I,FtM,Id, Nodes,No,Ft,S,P)->
           % io:format("here in the Finger table conditon~n"),
           Key = round(Id + round(math:pow(2,I-1))),
           SKey = (Key) rem round(math:pow(2,FtM)),
           %io:format("Calculating for ID ~p \t Key ~p, Skey: ~p~n",[Id,Key,SKey]),
           {SId ,SNode} = S,
           NameSpace = round(math:pow(2,FtM)),
           %numbers between last and first node
           Temp = lists:member(SKey, lists:seq(Id+1, NameSpace)++lists:seq(0, SId)),
        %    io:format("Inserting ~p, ~p: in FT of : ~p asking node ~p ~n",[SKey,S, Id,SId]),
           if
               SKey=< SId, SKey > Id->
                   %io:format("Inserting ~p, ~p: in FT of : ~p  ~n",[SKey,S, Id]),
                   ft_node(I+1,FtM,Id,Nodes,No,[{SKey,S}|Ft],S,P);
   
               SId < Id ->
                   if
                       Temp ->
                           ft_node(I+1,FtM,Id,Nodes,No,[{SKey,S}|Ft],S,P);
                       true ->
                           SNode ! {askSucessor,SKey,self()},
                           receive
                           {Sucessor}->
                           %io:format("FT entry received ~p~n",[Sucessor]),
                           ft_node(I+1,FtM,Id,Nodes,No,[{SKey,Sucessor}|Ft],S,P)
                   end

                   end;
                   
   
               SKey=< SId, SKey < Id; 
               SKey > SId->
                   %io:format("Below SId:~p, Skey: ~p~n",[SId,SKey]),
                   SNode ! {askSucessor,SKey,self()},
                   receive
                       {Sucessor}->
                           %io:format("FT entry received ~p~n",[Sucessor]),
                           ft_node(I+1,FtM,Id,Nodes,No,[{SKey,Sucessor}|Ft],S,P)
                   end 
           end.
           
   contFT(Sk, ReqID, Sc, Id, M) ->
       
       {SId,SNode} = Sc,
       NameSpace = round(math:pow(2,M)),
    %    io:format("in contFT "),
       Temp = lists:member(Sk, lists:seq(Id, NameSpace)++lists:seq(0, SId)),
    %    io:format("Inserting ~p, ~p: in FT of : ~p asking node ~p ~n",[SKey,S, Id,SId]),
       if
           Sk=< SId, Sk > Id->
               %io:format("Inserting ~p: in FT of : ~p  ~n",[Sc, Id]),
               ReqID ! {Sc};
   
           SId < Id ->
               if
                       Temp ->
                           
                           ReqID ! {Sc};
                       true ->
                           SNode ! {askSucessor,Sk,ReqID}
                   end;
   
           Sk=< SId, Sk < Id; 
           Sk > SId->
               SNode ! {askSucessor,Sk,ReqID}
       end.