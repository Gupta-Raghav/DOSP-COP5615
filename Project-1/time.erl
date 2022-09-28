-module(time).
-export([time_test/0]).

time_test() ->
	statistics(runtime),
	statistics(wall_clock),

	master:local_time_test(4),

	{_,Time} = statistics(runtime),
	{_,Time2} = statistics(wall_clock),

	io:format("The Run time is - ~p\n", [Time]),
	io:format("The Ratio is - ~p", [Time/Time2]).
	% io:format("CPU time ~p Milliseconds: ", [Time2]).