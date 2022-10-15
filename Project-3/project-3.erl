-module(project3).

-export([start/2]).

create_chord(0,_) ->
    list;

create_chord(NNodes,Nreq)->
    addNode(NNodes,[]).

start(NumNodes,NumRequests)->
    M = eralng:trunc(ceil(math:log(2,NumNodes))),
    Chordspace = math:pow(2,M),
    addNode(Chordspace,[]),
    create_chord(NumRequests,Chordspace-1),
    ok.

addNode(N,NodeList)->
    Node = spawn(node, start, []),
    Hashval = crypto:hash(sha,Node),
    addNode(N- 1, [Hashval | NodeList]),
    adding.

deletingNode()->
    deleting.

stabalize()->
    stabalize.

ask()->
    ask.

hashing(Val)->
   Hash = crypto:hash(sha,Val),
   Hash.