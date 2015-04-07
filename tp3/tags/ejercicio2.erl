-module(ejercicio2).
-compile(export_all).

eval(P)->
	case P of
		{sum,Val1,Val2}  -> Val1 + Val2;
		{res,Val1,Val2}  -> Val1 - Val2;
		{mult,Val1,Val2} -> Val1 * Val2;
		{divi,Val1,Val2} -> Val1 / Val2;
		{cons,Val}      -> Val;
		_		 -> io:format("Expresion invalida!~n"),ok
	end.
