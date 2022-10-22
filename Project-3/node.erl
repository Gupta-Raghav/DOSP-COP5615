-module(node).
-export([start/7]).

start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)->
    % io:format("Node with Id ~p Existing Nodes ~p and value of M ~p~n",[ID,Existing_Nodes,M]),

    % io:format("Suc: ~p,Pre: ~p~n",[Sc,Pr]),
    receive
        {lookup,K}->
            % io:format("Inside Lookup\n"),
            search(K,ID,Sc,Ft,0);
        {continuesearch, K, Hop} ->
            % io:format("IN continue with hops : ~p~n",[Hop]),
            search(K,ID,Sc,Ft,Hop);
        {createFt,NodeList}->
            %io:format("Inside createft\n"),
            FingerTable = ft_node(1,M,ID,NodeList,No,Ft,Sc,Pr),
            %io:format("ft done: ~p~n",[FingerTable]),
            listener ! {fingertablecreated},
            start(ID,M,Existing_Nodes,No,FingerTable,Sc,Pr);
        {updateSP,S,P} ->
            listener ! {doneupdating},
            start(ID,M,Existing_Nodes,No,Ft,S,P);
        {populate}->
            % populateKeys(),
            listener ! done_populating;
        {askSucessor,Sk,PID} ->
            % {SId,SNode} = Sc,
            % if
            %     Sk =< SId ->

            %         PID ! {Sc};
            %     true -> 
            %         %  io:format("inside the false statement~n"),
            %          SNode ! {askSucessor,Sk,PID}
            % end, 
            %io:format("about to call contft"),
            contFT(Sk, PID, Sc, ID, M),
            start(ID,M,Existing_Nodes,No,Ft,Sc,Pr)
    end.
nearest(Key,Fingert,1,PID)->
    {_,Succ} = lists:nth(1, Fingert),
    PID ! Succ;

nearest(Key,Fingert,It,PID)->
    {_,Succ} = lists:nth(It, Fingert),
    {Fid,_} = Succ,
    if
        Fid < Key ->
            % io:format("here in the true conditon~n"),
           PID ! {Succ};
        true ->
            % io:format("here in the False conditon~n"),
            nearest(Key,Fingert,It-1,PID)
    end.


search(Skey,Id,Scc={SID,_},Ft,Hops)->
    % io:format("Inside Search ~n"),
    if
        Skey > Id, Skey=<SID ->
            % io:format("First condition ~n"),
            listener ! {found,Scc,Skey,Hops+1};
        Id > SID, Skey=<SID ->
            % io:format("Second condition ~n"),
            listener ! {found,Scc,Skey,Hops+1};
        Id > SID, Skey > SID ->
            % io:format("Third condition ~n"),
            listener ! {found,Scc,Skey,Hops+1}; 
        true ->
            % io:format("False condition ~n"),
            nearest(Skey,Ft,length(Ft),self()),
            receive
                {{_,SUCCPID}}->
                % io:format("SUCCPID ~p\n",[SUCCPID]),
                SUCCPID ! {continuesearch, Skey, Hops+1}
                % io:format("Found S through Nearest ~p~n",[S])
            end
            
    end.


    
ft_node(I,Ftm,ID,_,_,Ft,_,_) when I ==Ftm+1->
     io:format("Finger Table for Id ~p is ~p~n",[ID,Ft]),
    Ft;

ft_node(I,FtM,Id, Nodes,No,Ft,S,P)->
        % io:format("here in the Finger table conditon~n"),
        Key = round(Id + round(math:pow(2,I-1))),
        SKey = (Key) rem round(math:pow(2,FtM)),
        %io:format("Calculating for ID ~p \t Key ~p, Skey: ~p~n",[Id,Key,SKey]),
        {SId ,SNode} = S,
        {PId ,PNode} = P,
        %io:format("Above  SId:~p, Skey: ~p~n",[SId,SKey]),
        % if
        %     I > SId, I > Key, SId >= Key ->
        %     % io:fwrite("Cond2~n", []),
        %     Succ;
        %      I > SId, I < Key, SId =< Key ->
        %     % io:fwrite("Cond6~n", []),
        %     Succ;
        %     Key > I, Key =< SId ->
        %     % io:fwrite("Cond3~n", []),
        %     Succ;
        NameSpace = round(math:pow(2,FtM)),
        %numbers between last and first node
        Temp = lists:member(SKey, lists:seq(Id, NameSpace)++lists:seq(0, SId)),
        if
            SKey=< SId, SKey > Id->
                %io:format("Inserting ~p, ~p: in FT of : ~p  ~n",[SKey,S, Id]),
                ft_node(I+1,FtM,Id,Nodes,No,[{SKey,S}|Ft],S,P);

            SId < Id ->
                if
                    Temp ->
                       % io:format("Inserting ~p, ~p: in FT of : ~p  ~n",[SKey,S, Id]),
                        ft_node(I+1,FtM,Id,Nodes,No,[{SKey,S}|Ft],S,P);
                    true ->
                        SNode ! {askSucessor,SKey,self()}
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
    %io:format("in contFT "),
    Temp = lists:member(Sk, lists:seq(Id, NameSpace)++lists:seq(0, SId)),

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
    
    % if 
    %     %%Normal clockwise circulation
    %     SId >= Id ->
    %        % io:format("line 131 "),
    %         if
    %             Sk =< SId, Sk > Id ->
    %                 io:format("line 134~n"),
    %                 ReqID ! {Sc};
    %             Sk=< SId, Sk < Id; 
    %             Sk > SId->
    %                 SNode ! {askSucessor,Sk,ReqID}
    %         end;
    %     SId < Id ->
    %         if
    %             Sk =< SId ->
    %                 io:format("found successor after circling ring ~p~n",[Sc]),
    %                 ReqID ! {Sc};
    %             Sk > SId ->
    %                 SNode ! {askSucessor,Sk,ReqID}
    %         end
    % end.

    