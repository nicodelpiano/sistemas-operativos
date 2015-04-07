/*Del Piano, Iwakawa*/
/*Sistemas Operativos 1*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <string.h>

#define BUFSIZE 200
#define IDSIZE 20
#define CLNT_LIMIT 10

/*Para compilar:    gcc -o Cliente Cliente.c -D_REENTRANT -lpthread*/

void* send_msg( void* arg ) {
	char msg[BUFSIZE];
	int sock = (int) arg;        
	while (1) {
		fgets( msg, BUFSIZE, stdin );
		msg[strlen(msg)+1] = '\0';
		if(msg[strlen(msg)-1] == '\n')
			msg[strlen(msg)-1] = '\0';
		write( sock, msg, strlen(msg) );
			
	}
}

void* recv_msg( void* arg ) {
	int sock = (int) arg;
	char recieved[BUFSIZE+IDSIZE+15];
	int len;

	while (1) {
		len = read( sock, recieved, BUFSIZE+IDSIZE+14 );
		if ( len == -1 )
			return (void*)1;
		recieved[len] = 0;
		printf("%s\n",recieved);
	}
}

int main( int argc, char** argv ) {
	int sock;
	struct sockaddr_in serv_addr;
	pthread_t send_thrd, recv_thrd;
	void* thr_rtn_val;

	sock = socket( PF_INET, SOCK_STREAM, 0 );
	if ( sock == -1 )
		printf("ERROR: No se pudo conectar\n");

	memset( &serv_addr, 0, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = inet_addr( "127.0.0.1" );
	serv_addr.sin_port = htons( 8000 );

	if ( connect(sock, (struct sockaddr*) &serv_addr, sizeof(serv_addr)) == -1 )
		printf("ERROR: No se pudo conectar\n");

	pthread_create( &send_thrd, NULL, send_msg, (void*) sock );
	pthread_create( &recv_thrd, NULL, recv_msg, (void*) sock );

	pthread_join( send_thrd, &thr_rtn_val );
	pthread_join( recv_thrd, &thr_rtn_val );        

	close( sock );
	return 0;
}
