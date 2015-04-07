-module(ejercicio6).
-compile(export_all).

echo()->
	receive
		Msj -> io:format("Recibi ~p.~n",[Msj])	
	end,
	echo().

servidor()->
	receive
		{X,Msj,Pid} -> io:format("Nuevo cliente conectado: ~p, dijo ~p.~n",[X,Msj]),Pid!Msj
	end,
	servidor().

init()->
	S =  spawn(?MODULE,servidor,[]),
	P1 = spawn(?MODULE,echo,[]),
	P2 = spawn(?MODULE,echo,[]),	
	S!{"Jorge","Hola",P1},
	S!{"Carlos","Buenasss",P2}.
