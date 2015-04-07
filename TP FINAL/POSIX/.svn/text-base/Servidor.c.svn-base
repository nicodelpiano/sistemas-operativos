/*Del Piano, Iwakawa*/
/*Sistemas Operativos 1*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <string.h>

#define N_WORKERS 5
#define BUFSIZE 200
#define IDSIZE 20
#define CLNT_LIMIT 10

/*Para compilar:    gcc -o Servidor Servidor.c -D_REENTRANT -lpthread*/

void parser( char* msg, int* clnt_id) {
	int i, len_id, len;
	char target_id[BUFSIZE];

	len = strlen(msg);
	len_id = strchr(msg, ' ') - msg-1;
	strncpy( target_id, msg+1, len_id );
	target_id[len_id] = 0;
	*clnt_id = atoi(target_id);
}

int cycle (int i) {
	if(i < N_WORKERS-1) 
		return i+1;
	return 0;
}

struct clnt_info {
	int sock;
	int worker;
	char* id;
};
struct wokr_info {
	int sock;				
	char* id;
};

int serv_sock;
int wokr_count = 0;
int clnt_count = 0;
struct wokr_info* workers[CLNT_LIMIT];
struct clnt_info* clients[CLNT_LIMIT];
pthread_mutex_t mutx;

void send_worker(char* msg, int sender) {
	int i,j,len;
	len = strlen(msg);
	pthread_mutex_lock( &mutx );
	for (i=0; i<wokr_count; i++)
		if (workers[i]->sock == sender)       
			j = atoi (workers[i]->id);
	for (i=0; i<wokr_count; i++)
		if (atoi(workers[i]->id) == cycle(j))       
			write( workers[i]->sock, msg, len );
	pthread_mutex_unlock( &mutx );
}

void send_cliente( char* msg, int sender){
	int i, target_sock, id_len, len;
	char target_id[IDSIZE];
	int clnt_id, n;
	len = strlen(msg);
	parser(msg,&clnt_id);
	pthread_mutex_lock( &mutx );
	for ( i=0; i<clnt_count; i++ ){
		if(clnt_id == atoi(clients[i]->id)) {
			target_sock = clients[i]->sock;
		}
	}	        
	pthread_mutex_unlock( &mutx );
	printf("Le envio esto al cliente: %s\n", &strchr(msg, ' ')[1]);
	write( target_sock, &strchr(msg, ' ')[1], len );
}

void activate_worker();

void* wokr_msg_process(void* arg) {

	int wokr_sock = (int) arg;
	char msg[BUFSIZE];
	int i, len;
	
	while ( (len=read(wokr_sock, msg, sizeof(msg))) != 0 ){ 
		msg[len] = 0;
		printf("%s\n",msg);
		switch (msg[0]) {
			case '?' : //Mensaje para un worker
				send_worker( msg, wokr_sock); 
			case '!' : //Mensaje para un cliente
				if(msg[0]=='!')
					send_cliente( msg, wokr_sock);
		}
	}

	pthread_mutex_lock( &mutx );
	for ( i=0; i<wokr_count; i++)
		if ( wokr_sock == workers[i]->sock ){
			printf( "El worker ID %s perdió la conexión.\n", workers[i]->id );
			free( workers[i]->id );
			free( workers[i] );
			for ( ; i<wokr_count-1; i++)
				workers[i] = workers[i+1];                        
			break;
		}
	wokr_count--;
	pthread_mutex_unlock( &mutx );        
	close( wokr_sock );
	printf("Esperando retomar conexión...\n");
	activate_worker();	
	return 0;
}

void* clnt_msg_process(void* arg) {
	int clnt_sock = (int) arg;
	char msg_r[BUFSIZE],msg_s[BUFSIZE];
	int i, len, rand;
	while ( (len=read(clnt_sock, msg_r, sizeof(msg_r))) != 0 ){   
		msg_r[len] = 0;
		if(!strcmp(msg_r,"CON")){
			pthread_mutex_lock( &mutx );
			for ( i=0; i<clnt_count; i++)
				if ( clnt_sock == clients[i]->sock ){
					sprintf(msg_s,"OK ID %s",clients[i]->id);
				}
			pthread_mutex_unlock( &mutx );
			write(clnt_sock,msg_s, sizeof(msg_s));
		}
		else {
			pthread_mutex_lock( &mutx );
			for ( i=0; i<clnt_count; i++)
				if ( clnt_sock == clients[i]->sock ){
					rand = clients[i]->worker;
					sprintf(msg_s,"?%s %i %s",clients[i]->id,N_WORKERS-1,msg_r);
				}
			pthread_mutex_unlock( &mutx );
			write(workers[rand]->sock,msg_s,BUFSIZE);
		}
		printf("%s\n",msg_s);
	}

	pthread_mutex_lock( &mutx );
	for ( i=0; i<clnt_count; i++)
		if ( clnt_sock == clients[i]->sock ){
			printf( "El cliente ID: %s perdió la conexión\n", clients[i]->id );
			free( clients[i]->id );
			free( clients[i] );
			for ( ; i<clnt_count-1; i++)
				clients[i] = clients[i+1];                        
			break;
		}
	clnt_count--;
	pthread_mutex_unlock( &mutx );        
	close( clnt_sock );
	return 0;
}

void activate_worker(){
	int ready = 0;
	int wokr_addr_size, wokr_sock;
	struct sockaddr_in wokr_addr;
	char w[IDSIZE];
	pthread_t thread;
	printf("Activando workers...\n");

	while (ready!=1){
		wokr_addr_size = sizeof(wokr_addr);
		wokr_sock = accept( serv_sock, (struct sockaddr*) &wokr_addr, &wokr_addr_size );
		pthread_mutex_lock( &mutx );
		workers[wokr_count] = (struct wokr_info*) malloc( sizeof(struct wokr_info) );
		workers[wokr_count]->id = (char*) malloc( IDSIZE );
		workers[wokr_count]->sock = wokr_sock; 
		read( wokr_sock, w, IDSIZE ); 
		if(strcmp(w,"Worker")) {
			printf("No puedes conectarte en este momento, falla de workers\n");
			free( workers[wokr_count]->id );
			free( workers[wokr_count] );
			pthread_mutex_unlock(&mutx );        
			close( wokr_sock );
		}
		else {
			sprintf(workers[wokr_count-1]->id,"%i", wokr_count++);
			write(workers[wokr_count-1]->sock,workers[wokr_count-1]->id,sizeof(workers[wokr_count-1]->id));
			if(wokr_count > N_WORKERS-1)
				ready=1;
			pthread_mutex_unlock( &mutx );
			pthread_create( &thread, NULL, wokr_msg_process, (void*)wokr_sock );
			printf( "Worker %s conectado\n", workers[wokr_count-1]->id );
		}
	}
}

int main( int argc, char** argv ) {
	int clnt_sock, wokr_sock;
	struct sockaddr_in serv_addr;
	struct sockaddr_in clnt_addr;
	struct sockaddr_in wokr_addr;
	int clnt_addr_size;
	int wokr_addr_size;
	pthread_t thread;
	char w[IDSIZE];

	if ( pthread_mutex_init(&mutx, NULL) )
		printf("ERROR: No se pudo iniciar conexión\n");

	serv_sock = socket( PF_INET, SOCK_STREAM, 0 );
	memset( &serv_addr, 0, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl( INADDR_ANY );
	serv_addr.sin_port = htons( 8000);

	if ( bind(serv_sock, (struct sockaddr*) &serv_addr, sizeof(serv_addr)) )
		printf("ERROR: No se pudo conectar\n");

	if ( listen(serv_sock, CLNT_LIMIT) )
		printf("ERROR: Demasiados clientes\n");

	//---Workers
	activate_worker();
	printf("Workers activados\n");

	//--Clients
	while (1){
		clnt_addr_size = sizeof(clnt_addr);
		clnt_sock = accept( serv_sock, (struct sockaddr*) &clnt_addr, &clnt_addr_size );
		pthread_mutex_lock( &mutx );
		clients[clnt_count] = (struct clnt_info*) malloc( sizeof(struct clnt_info) );
		clients[clnt_count]->id = (char*) malloc( IDSIZE );
		clients[clnt_count]->sock = clnt_sock;
		clients[clnt_count]->worker = random()%N_WORKERS;
		sprintf(clients[clnt_count-1]->id,"%i", clnt_count++);
		pthread_mutex_unlock( &mutx );
		pthread_create( &thread, NULL, clnt_msg_process, (void*)clnt_sock );
		printf( "Nuevo cliente conectado ID: %s\n", clients[clnt_count-1]->id );
	}
	return 0;
}
