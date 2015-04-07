-module(ejercicio4).
-export([testLock/0,testSem/0]).

%internal
-export([f/2,waiter/2]).
-export([waiter_sem/2,sem/2]).

p_lock() -> receive {lock,W} -> W! ok, 
              receive {unlock, W} -> W! ok end,
              p_lock();
	      {exit}->ok
            end.

lock (L) -> L! {lock, self()}, receive ok -> ok end.
unlock (L) -> L! {unlock, self()}, receive ok -> ok end.
createLock () -> spawn(?MODULE,p_lock,[]).
destroyLock (L) -> L! {exit}.


p_sem(N) -> 
if(N>0) ->
receive {semp,W} -> W! ok, p_sem(N-1) end
end,

if(N==0) ->
receive {semv,W} -> W! ok, p_sem(N+1) end
end.

createSem (N) -> spawn(?MODULE,p_sem,N).
destroySem (S) -> S! {exit}.

semP (S) ->  S! {semp, self()}, receive ok -> ok end.
semV (S) ->  S! {semv, self()}, receive ok -> ok end.
 

f (L,W) -> lock(L),
  %   regioncritica(),
  io:format("uno ~p~n",[self()]),
  io:format("dos ~p~n",[self()]),
  io:format("tre ~p~n",[self()]),
  io:format("cua ~p~n",[self()]),
  unlock(L),
  W!finished.

waiter (L,0)  -> destroyLock(L);
waiter (L,N)  -> receive finished -> waiter(L,N-1) end.

waiter_sem (S,0)  -> destroySem(S);
waiter_sem (S,N)  -> receive finished -> waiter_sem(S,N-1) end.


testLock () -> L = createLock(),
  W=spawn(?MODULE,waiter,[L,3]),
  spawn(?MODULE,f,[L,W]),
  spawn(?MODULE,f,[L,W]),
  spawn(?MODULE,f,[L,W]),
  ok.
 
sem (S,W) -> 
  semP(S),
  %regioncritica(), bueno, casi....
  io:format("uno ~p~n",[self()]),
  io:format("dos ~p~n",[self()]),
  semV(S),
  W!finished.

testSem () -> S = createSem(2), % a lo sumo dos usando io al mismo tiempo
  W=spawn(?MODULE,waiter_sem,[S,5]),
  spawn(?MODULE,sem,[S,W]),
  spawn(?MODULE,sem,[S,W]),
  spawn(?MODULE,sem,[S,W]),
  spawn(?MODULE,sem,[S,W]),
  spawn(?MODULE,sem,[S,W]).


