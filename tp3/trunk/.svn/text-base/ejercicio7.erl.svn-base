-module(ejercicio7).
-compile(export_all).

panillo(Pid) ->
	receive	
	
		{msg, 0} -> Pid!exit, receive exit -> ok end;
	
		{msg, N} -> io:format("~p: ~p~n", [self(), N]), 
				Pid!{msg, N-1}, panillo(Pid);
		
		exit -> io:format("~p Termino~n", [self()]),Pid!exit
	end.

crearAnillo (N) ->
	panillo(anillo(N, self())).

anillo(1, Pid) ->
	spawn(?MODULE, panillo, [Pid]);

anillo(N, Pid) ->
	(spawn(?MODULE, panillo, [anillo(N-1, Pid)])).

init()->
	spawn(?MODULE,crearAnillo,[5])!{msg,10}.	


