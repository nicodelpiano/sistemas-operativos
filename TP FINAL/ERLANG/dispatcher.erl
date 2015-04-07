% Del Piano, Iwakawa
% Sistemas Operativos 1
-module(dispatcher).
-compile(export_all).
-import(worker,[initworkers/1,newworker/0]).
-define(PORT,8000).
-define(NWORKERS,5).

%proceso cont para contar Fds
cont(N)->
	receive {dame,Pid} -> Pid!N, cont(N+1) end.

%proceso listener
listener(Port,W)->
	case gen_tcp:listen(Port,[{reuseaddr,true},{active,false}]) of
		{ok,LS}    -> 	
			ContFd = spawn(?MODULE,cont,[1]),%iniciamos el proceso contador de Fds
			spawn(?MODULE,wait_connect,[LS,0,W,ContFd]);
		{error,Reason} -> 
			io:format("ERROR: ~p.~n",[Reason])
	end.

%esperamos por una conexion
wait_connect(ListenSocket,Count,W,ContFd) ->
		{ok,Socket} = gen_tcp:accept(ListenSocket),
		N = random:uniform(?NWORKERS),%numero random entre los workers para asignarle al cliente
		Pid = spawn(?MODULE, get_request,[Socket,Count,W,N,ContFd]),
		gen_tcp:controlling_process(Socket,Pid),
		wait_connect(ListenSocket,Count +1,W,ContFd).

%proceso socket del cliente
get_request(Socket,Count,W,N,ContFd) ->
		Worker = lists:nth(N,W),
		case gen_tcp:recv(Socket,0) of
				{ok,Packet} -> 
					Worker!{Socket,Packet,self(),W,ContFd},
					get_request(Socket,Count,W,N,ContFd);
				{error,_} -> 
					Worker!{Socket,"BYE",self(),W,ContFd},
					exit(self())
		end.

%iniciamos los workers y el proceso escucha por el puerto 8000
init()->
	Workers = initworkers(?NWORKERS),
	listener(?PORT,Workers).
