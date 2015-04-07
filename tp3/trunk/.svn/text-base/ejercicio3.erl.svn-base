-module(ejercicio3).
-export([init/0,cronometro/3]).

wait(T) ->
  receive after T -> ok 
  end.

ejecutar(Fun,N,T) ->
  if (N>1) -> wait(T),Fun(),ejecutar(Fun,N-1,T)
  end,
  if(N=<1) -> ok
  end. 

cronometro (Fun,T1,T2) ->
 ejecutar (Fun,T1/T2,T2).


init () -> 
  %wait(5000).
  spawn (ej3,cronometro,[fun () -> io:format("Tick~n") end,8000,1000]).

