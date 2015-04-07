%% Del Piano, Iwakawa
%% Sistemas Operativos I
-module(worker).
-compile(export_all).
-define(NWORKERS,5).

%%%%%%%%%%%%%%%%%%%%%%
%Funciones Auxiliares%
%%%%%%%%%%%%%%%%%%%%%%

%initworkers
initworkers(0) -> [];
initworkers(N) -> T = spawn(?MODULE,newworker,[[],[]]),
		  				[T|initworkers(N-1)].

%ID
id(_,Acum,Socket,0) -> gen_tcp:send(Socket,["OK ID "++integer_to_list(Acum)]),exit(self());
id(W,Acum,Socket,N) ->
	lists:nth(N,W)!{self(),socket},
	receive
		Num -> id(W,Acum+Num,Socket,N-1)
	end.

%LS
ls(_,Acum,Socket,0) -> gen_tcp:send(Socket,"OK "++destuplaesp(Acum)++" \0"),exit(self());
ls(W,Acum,Socket,N) ->
	lists:nth(N,W)!{self(),arch},
	receive
		{ls,Arch} -> ls(W,Acum++Arch,Socket,N-1)
	end.

%%cerrar archivos: cierra todos los archivos del socket dado
cerrarArchivos(_,_,Socket,0) -> gen_tcp:send(Socket,"OK \0");
cerrarArchivos(W,Pid,Socket,N) ->
	lists:nth(N,W)!{cerrar,Pid},cerrarArchivos(W,Pid,Socket,N-1).


%destupla

destupla([]) -> [];
destupla([{_,Arch,_,_,_}|Resto]) -> [Arch|destupla(Resto)].

%destupla con espacios

destuplaesp([]) -> [];
destuplaesp([{_,Arch,_,_,_}|Resto]) -> [Arch++" "|destuplaesp(Resto)].

%busca el FD de un archivo
findfd(Arch,L) -> case lists:filter(fun({_,Nombre,_,_,_}) -> Nombre=:=Arch end,L) of
			[] -> -1;
			[{Fd,_,_,_,_}] -> Fd
		  end.

%buscar el archivo A en la lista de archivos
find2(A,L) -> lists:filter(fun({_,Arch,_,_,_}) -> A=:=Arch end,L).

%buscar el fd F en la lista de archivos
find(F,L) -> lists:filter(fun({Fd,_,_,_,_}) -> Fd=:=F  end,L).

%Datos
datos([])->"ok";
datos([{_,_,C,_,_}]) -> C.

%Fd
fd({A,_,_,_,_}) -> A.

%swapeamos dos archivos
change(ArchList,ArchN,ArchV)-> [ArchN|ArchList -- [ArchV]].

%parser, parseamos la entrada P

parser(P) ->
	case [hd(P)] == "W" of
		true -> 
			Pack = lists:sublist(string:tokens(P," "),5),
			Result = lists:sum(lists:map(fun(X) -> length(X)+1 end,Pack))+1,
			Tockens = Pack ++ [(lists:sublist(P,Result,length(P)))],Tockens -- [[]];
		false -> string:tokens(P," ")
	end.

%newworker
%este es el comportamiento de un worker
%tiene una lista de sockets (clientes que se conectaron a el) y una lista de archivos (que pertenecen a el)
%parsea el paquete enviado por el cliente, y trabaja los casos

newworker(SocketList,ArchList)->
	receive
		{Socket,Packet,Pid,Workers,ContFd} -> 
				case parser(Packet) of

				%Recibo un CON de parte del cliente, me fijo cuantos clientes se conectaron en cada worker
				%Hicimos asi para no tener otro proceso contador dando vueltas, ya tengo uno contando FDs
				["CON"] -> spawn(fun() -> id(Workers,0,Socket,?NWORKERS) end),
					newworker([Socket|SocketList],ArchList);

				%Si hay un LSD, entonces busco la lista de todos los archivos en cada worker
				%y se las envío al cliente
				["LSD"] -> spawn(fun() -> ls(Workers,[],Socket,?NWORKERS) end),
					newworker(SocketList,ArchList);

				%Si hay un BYE, puede ser que el cliente lo haya mandado, como haya terminado abruptamente
				%en cada caso, se cierran todos los archivos de ese cliente y se continúa normalmente
				["BYE"] -> spawn(fun() -> cerrarArchivos(Workers,Pid,Socket,?NWORKERS) end),
					newworker(SocketList,ArchList);
				
				%Si el cliente quiere leer con REA, leerá Size del Fd que quiere leer
				["REA","FD",Fd,"SIZE",Size] -> 
					
					%buscamos el Fd en el archlist del worker, si no esta buscamos en los demás
					case (find(list_to_integer(Fd),ArchList)) of

						[] -> WAux = Workers -- [self()],

									case WAux of
										%en caso de no haberlo encontrado, error
										[] -> gen_tcp:send(Socket,"ERROR 77 EBADFD\0"),
												newworker(SocketList,ArchList);

										_  -> hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
												newworker(SocketList,ArchList)
									end;

						%podemos encontrarlo sin que este abierto, en ese caso pedimos que lo abra
						[{_,_,_,[],_}] -> 
							gen_tcp:send(Socket,"ERROR: ARCHIVO NO ABIERTO\0"),
							newworker(SocketList,ArchList);

						%en caso de encontrarlo, nos fijamos si podemos leerlo (si lo habíamos abierto nosotros)
						[{X,Y,Z,[P],B}] -> 
						
									case (P=:=Pid)  of 
										
										true ->
												case list_to_integer(Size) of
													0 -> 
															gen_tcp:send(Socket,"OK SIZE 0 "),
															newworker(SocketList,ArchList);
 
													N -> case (B>=length(Z)) of
															true -> 
										        				gen_tcp:send(Socket,"OK SIZE 0 "),
										        				newworker(SocketList,ArchList);
															
															false -> 
																gen_tcp:send(Socket,"OK SIZE "++integer_to_list(min(list_to_integer(Size),length(Z)-B))++" "++lists:sublist(Z,B+1,N)++"\0"),
																ArchListNueva = change(ArchList,{X,Y,Z,[P],B+N},{X,Y,Z,[P],B}),
										     					newworker(SocketList,ArchListNueva)
										    				end
												end;
								  		
										false -> 	
										     gen_tcp:send(Socket,"ERROR 77 EBADFD\0"),
										     newworker(SocketList,ArchList)
									end
					end;
	
				%OPN, abre un archivo, le asigna el Pid del proceso socket que lo quiere abrir
				["OPN",Arch] -> 
					case (find2(Arch,ArchList)) of
					
						[{Fd,Nombre,Datos,[],B}] -> 
								gen_tcp:send(Socket,"OK FD "++integer_to_list(Fd)++" \0"),
								%%abrimos el archivo
								ArchNewList = change(ArchList,{Fd,Nombre,Datos,[Pid],B},{Fd,Nombre,Datos,[],B}),
								newworker(SocketList,ArchNewList);
						
						[{_,_,_,_,_}] -> 
								gen_tcp:send(Socket,"ERROR: ARCHIVO ABIERTO\0"),
								newworker(SocketList,ArchList);

						%Buscamos en los otros workers
						[] -> 
								WAux = Workers -- [self()],
							         	
								case WAux of
									
									[] -> 
										gen_tcp:send(Socket,"ERROR: NO EXISTE EL ARCHIVO\0"),
										newworker(SocketList,ArchList);

									_  -> 
										hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
										newworker(SocketList,ArchList)
								end
								
						end;

				%Borramos un archivo, buscando en todos los workers
				["DEL",Arch] -> %spawn(fun() -> delete(Workers,Arch,Socket,?NWORKERS) end),
											case find2(Arch,ArchList) of
													[] -> WAux = Workers -- [self()],
															case WAux of
																[] -> gen_tcp:send(Socket,"ERROR: EL ARCHIVO NO EXISTE\0"),
																		newworker(SocketList,ArchList);
																_	-> hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
																		newworker(SocketList,ArchList)
															end;
													[{_,_,_,[_],_}] -> gen_tcp:send(Socket,"ERROR: ARCHIVO ABIERTO\0"),
																			 newworker(SocketList,ArchList);
													[{_,_,_,[],_}] -> gen_tcp:send(Socket,"OK \0"),
																			newworker(SocketList,ArchList -- find2(Arch,ArchList))
											end,newworker(SocketList,ArchList);
				
				%WRT, escribimos en Fd, Size bytes de Text
				["WRT","FD",Fd,"SIZE",Size,Text] ->
					%buscamos el fd en la lista de archivos,
					%si no encontramos, seguimos la busqueda en todos los workers
					case find(list_to_integer(Fd),ArchList) of
						
						[] -> 
							WAux = Workers -- [self()],
								
							case WAux of
									[] -> 
										gen_tcp:send(Socket,"ERROR 77 EBADFD\0"),
										newworker(SocketList,ArchList);

									_  -> 
										hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
										newworker(SocketList,ArchList)
							end;

						%podemos encontrarlo sin que este abierto, en ese caso pedimos que lo abra
						[{_,_,_,[],_}] -> 
							gen_tcp:send(Socket,"ERROR: ARCHIVO NO ABIERTO\0"),
							newworker(SocketList,ArchList);						

						%en caso de encontrarlo		
						L  -> 
							{X,Y,Datos,[P],B}=hd(L),
							case (P=:=Pid) of
									false -> 
										gen_tcp:send(Socket,"ERROR: ARCHIVO YA ABIERTO \0"),
										newworker(SocketList,ArchList);
									  
									true ->
										NuevosDatos = Datos ++ lists:sublist(Text,1,list_to_integer(Size)),
										ArchListNueva = ArchList -- L,
										gen_tcp:send(Socket,"OK \0"),
										newworker(SocketList,[{X,Y,NuevosDatos,[P],B}|ArchListNueva])
							end
					end;

				%Cerramos el Fd, buscando el Fd en cada worker
				["CLO","FD",Fd] -> 
					case find(list_to_integer(Fd),ArchList) of

						[{_,_,_,[],_}] ->
							gen_tcp:send(Socket,"OK \0"),
							newworker(SocketList,ArchList);

                  [{N,Nombre,Datos,[P],B}] ->
							ArchListNueva = change(ArchList,{N,Nombre,Datos,[],0},{N,Nombre,Datos,[P],B}),
							gen_tcp:send(Socket,"OK \0"),
							newworker(SocketList,ArchListNueva);
						
						[] -> 
							WAux = Workers -- [self()],
							
							case WAux of
								[] ->
									gen_tcp:send(Socket,"ERROR 77 EBADFD\0"),
									newworker(SocketList,ArchList);

								_  ->
									hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
									newworker(SocketList,ArchList)
							end
					end;
				
				%Creamos el archivo, primero buscamos si existe y no lo creamos

				["CRE",Arch] ->
					case find2(Arch,ArchList) of
						[] -> 
							WAux = Workers -- [self()],
									
							case WAux of
								[] ->	
									ContFd!{dame,self()},receive N -> ok end,
									Fd = N,                     
									gen_tcp:send(Socket,"OK \0"),
									newworker(SocketList,[{Fd,Arch,[],[],0}|ArchList]);

								_  ->   
									hd(WAux)!{Socket,Packet,Pid,WAux,ContFd},
									newworker(SocketList,ArchList)
							end;

						_  -> 
							gen_tcp:send(Socket,"ERROR: ARCHIVO EXISTENTE\0"),
							newworker(SocketList,ArchList)
					end;

				%cualquier otro mensaje del paquete que no sea valido viene aca
				_	-> gen_tcp:send(Socket,"ERROR: COMANDO INVALIDO"),
					newworker(SocketList,ArchList)
				
				end;

		%%
		%%Comunicacion entre workers
		%%
		
		%Nos piden la lista de archivo y se la enviamos al Pid
		{Pid,arch}   -> Pid!{ls,ArchList},newworker(SocketList,ArchList);
		
		%Nos piden la lista de Sockets, la enviamos al Pid
		{Pid,socket} -> Pid!length(SocketList),newworker(SocketList,ArchList);
		
		%Nos piden cerrar los archivos abiertos por el Pid
		{cerrar,Pid} -> 
			%mapeamos una funcion a la lista de archivos del worker, que
			%cambia los archivos que estan abiertos por Pid, a cerrados
			NuevaLista = lists:map(fun({Fd,Nombre,Datos,P,B}) -> 
								case P of
									[]  -> {Fd,Nombre,Datos,P,B};
									_ -> case hd(P) =:= Pid of
											true  -> {Fd,Nombre,Datos,[],0};
											false -> {Fd,Nombre,Datos,P,B}
											end
								end end,ArchList),
			newworker(SocketList,NuevaLista)					

	end.

