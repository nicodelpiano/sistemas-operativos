-module(ejercicio9).
-export([server/0]).

server()->
	spawn(fun ()->server([]) end).

server(L)->
	receive
		{newname,Name,Pid} ->
			case lists:filter(fun ({N,_}) -> N==Name end,L) of
				[] -> server([{Name,Pid}|L]);
				_  -> server(L)
			end;

		{newmsj,Name,Msj} ->
			case lists:filter(fun ({N,_}) -> N==Name end,L) of
				[]           -> io:format("El nombre ~p no existe.~n",[Name]);
				[{Name,Pid}] -> Pid!Msj
			end
	end,
	server(L).
