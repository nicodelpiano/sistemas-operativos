-module(ejercicio8).
-compile(export_all).

broadcaster()->
	spawn(fun () -> broadcaster([]) end).

broadcaster(L)->
	receive
		{sub,P}    -> broadcaster([P|L]);
		{des,P}  -> broadcaster(L--[P]);
		{send,Msj} -> enviara(Msj,L),broadcaster(L)
	end.
		
enviara(Msj,L)->
	case L of
		[]       -> io:format("Nadie para enviar!.~n");
		[P|Rest] -> case Rest of
				[] -> P!Msj,
			    	      io:format("Mensaje enviado a ~p!~n",[P]);
			    	_  -> P!Msj,
				      io:format("Mensaje enviado a ~p!~n",[P]),
				      enviara(Msj,Rest)
			    end
	end.
 
