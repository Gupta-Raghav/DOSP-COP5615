-module(gossip).
-import(nmanager,[start/0]).
-compile(export_all).

main() ->
    register(manager,spawn(nmanager,start,[])).