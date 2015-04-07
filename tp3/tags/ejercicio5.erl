-module(ejercicio5).
-compile(export_all).

bufferController (N1, N2) ->
            receive 

					{quieroescribir, Pid} ->
							case ((N1=:=0) and (N2=:=0)) of
									true ->	Pid!escribe,bufferController(0,1);
									false -> bufferController(N1,N2)
							end;

					yaescribi -> 
						bufferController(0,0);
				
					{quieroleer, Pid} ->
							case N2=:=0 of							
								true -> Pid!lee,bufferController(N1+1,0);
								false -> bufferController(N1,N2)
							end;

					yalei -> bufferController(N1-1,0)
            end.

leer () -> 
         io:format("Voy a leer.~n"),
         receive after 1000 -> io:format("Ya lei.~n") end.

escribir () ->
         io:format("Voy a escribir.~n"),
         receive after 1000 -> io:format("Ya escribi.~n") end.

lector (Buffer) ->
  Buffer!{quieroleer, self()},
  receive lee -> leer() end,
  Buffer!yalei,
  receive after 1000 -> lector(Buffer) end.

escritor (Buffer) ->
  Buffer!{quieroescribir, self()},
  receive escribe -> escribir() end,
  Buffer!yaescribi,
  receive after 1000 -> escritor(Buffer) end.

init () ->
  Buffer = spawn(?MODULE,bufferController,[0,0]),
  spawn(?MODULE,lector,[Buffer]),
  spawn(?MODULE,lector,[Buffer]),
  spawn(?MODULE,lector,[Buffer]),
  spawn(?MODULE,escritor,[Buffer]),
  spawn(?MODULE,escritor,[Buffer]),
  spawn(?MODULE,escritor,[Buffer]),
  spawn(?MODULE,escritor,[Buffer]),
  ok.  
