#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#define BUFF_SIZE 1024
int id=-1;

void *handle_client(void *conn_s) {
	char buffer[BUFF_SIZE],buffer2[BUFF_SIZE];
	int res;
	int s;
	s = *(int *)conn_s;
	int cliente;
	cliente = id++; // Nuevo cliente
	fprintf(stderr,"New client %d connected\n",cliente);
	while(1) {
		res=read(s,buffer,BUFF_SIZE);
		if (res<=0){
			close(s);
			break;
		}
		buffer[res]='\0';
		sprintf(buffer2,"Response to client %d: %s",cliente,buffer);
		write(s,buffer2,strlen(buffer2));
	}
	return NULL;
}

int main() {
	int list_s,conn_s=-1,res;
	struct sockaddr_in servaddr;
	char buffer[BUFF_SIZE],buffer2[BUFF_SIZE];
	if ( (list_s = socket(AF_INET, SOCK_STREAM, 0)) < 0 ) {
		fprintf(stderr, "ECHOSERV: Error creating listening socket.\n");
		return -1;
	}
	memset(&servaddr, 0, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(8000);
	if ( bind(list_s, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0 ) {
		fprintf(stderr, "ECHOSERV: Error calling bind()\n");
		return -1;
	}
	if ( listen(list_s, 10) < 0 ) {
		fprintf(stderr, "ECHOSERV: Error calling listen()\n");
		return -1;
	}

	while (1) {
		if ( (conn_s = accept(list_s, NULL, NULL) ) < 0 ) {
			fprintf(stderr, "ECHOSERV: Error calling accept()\n");
			return -1;
		}
		pthread_t xxx;
		pthread_create(&xxx,0,handle_client,(void*)&conn_s);
	}

	return 0;
}

