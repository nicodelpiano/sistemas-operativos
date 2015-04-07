CFLAGS = -L. -D_REENTRANT -lpthread
all: servidor worker1 worker2 worker3 worker4 worker5 cliente


clean:
	rm *.o *.a
	rm Servidor ./worker1/Worker ./worker2/Worker ./worker3/Worker ./worker4/Worker ./worker5/Worker Cliente

servidor: Servidor.c 
	gcc  Servidor.c $(CFLAGS) -o Servidor

worker1: Worker.c 
	gcc Worker.c $(CFLAGS)  -o ./worker1/Worker
worker2: Worker.c 
	gcc Worker.c $(CFLAGS)  -o ./worker2/Worker
worker3: Worker.c 
	gcc Worker.c $(CFLAGS)  -o ./worker3/Worker
worker4: Worker.c 
	gcc Worker.c $(CFLAGS)  -o ./worker4/Worker
worker5: Worker.c 
	gcc Worker.c $(CFLAGS)  -o ./worker5/Worker


cliente: Cliente.c
	gcc Cliente.c $(CFLAGS) -o Cliente

