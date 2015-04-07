-module(ejercicio1).
-export([init/0]).

match_test () -> 
  {A,B} = {5,4}, %Valido, asignando las variables por primera vez
  %{A,A} = {5,4}, %Invalido, A ya es 5, no puede reasignar 4
  {B,A} = {4,5}, %Valido, los valores de A y B no cambian con respecto a la primera asignacion
  {A,A} = {5,5}. %Valido, el valor de A es asignado nuevamente como en la primera vez

string_test () -> [
  helloworld == 'helloworld', %True
  "helloworld" == 'helloworld', %False
  helloworld == "helloworld", %False
  [$h,$e,$l,$l,$o,$w,$o,$r,$l,$d] == "helloworld", %True
  [104,101,108,108,111,119,111,114,108,100] == helloworld, %False
  [104,101,108,108,111,119,111,114,108,100] == 'helloworld', %False
  [104,101,108,108,111,119,111,114,108,100] == "helloworld"]. %True  

tuple_test (P1,P2) ->
  io:format("El nombre de P1 es ~p y el apellido de P2 es ~p~n",[nombre(P1),apellido(P2)]).

apellido ({persona,{nombre,_},{apellido,X}}) -> 
  X.
nombre ({persona,{nombre,X},{apellido,_}}) ->
  X.

%filter(fun(apellido(X)) -> X =:= Apellido end, [P1,P2,P3,P4]).

filtrar_por_apellido(Personas,Apellido) -> 
  [nombre(X) || X <- Personas, Apellido == apellido(X)].

init () -> 
  P1 = {persona,{nombre,"Juan"},{apellido, "Gomez"}},
  P2 = {persona,{nombre,"Carlos"},{apellido, "Garcia"}},
  P3 = {persona,{nombre,"Javier"},{apellido, "Garcia"}},
  P4 = {persona,{nombre,"Rolando"},{apellido, "Garcia"}},
  match_test(),
  tuple_test(P1,P2),
  string_test(),
  Garcias = filtrar_por_apellido([P4,P3,P2,P1],"Garcia").
