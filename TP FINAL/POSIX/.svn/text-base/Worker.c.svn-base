/*Del Piano, Iwakawa*/
/*Sistemas Operativos 1*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <dirent.h>
#include <string.h>
#include  <fcntl.h>

#define N_WORKERS 5
#define BUFSIZE 200 
/*NOTA: Se podrian asignar dinamicamente la memoria para los strings, en este caso estamos limitados por mensajes de 200 bytes*/
#define IDSIZE 20
#define CLNT_LIMIT 10

int my_id;

/*Para compilar:    gcc -o Worker Worker.c -D_REENTRANT -lpthread*/

typedef struct FILE_OPN {
	int fd;
	struct FILE_OPN *next;
	char* root;
	int clnt_id;
	int br;
} FILE_OPN;

FILE_OPN *files_opn = NULL;


void directory(char* msg){
	DIR *dir;
	int len=0;
	struct dirent *ent;
	char temp[BUFSIZE];

	dir=opendir("./data");

	while((ent=readdir(dir))!=NULL) 
		if(ent->d_type==DT_REG && ent->d_name[0] != '.') {
			sprintf(&msg[len]," %s ",ent->d_name);
			len += strlen(ent->d_name)+1;
		}
	closedir(dir);
	msg[len]= '\0';
}

int parser_rea(char* msg,int clnt_id){
	int len=0;
	int i;
	struct dirent *ent;
	char FD[BUFSIZE];
	char buf[BUFSIZE];
	char temp[BUFSIZE];
	int size=0;
	
	//Saco la palabra FD del mensaje
	if(strchr(msg, ' ')!=NULL)
		strcpy(temp, strchr(&msg[1], ' '));
	else
		printf("ERROR: Se espera FD\n");
	//Copio el FD en FD
	if(strchr(temp, ' ')!=NULL)
		strcpy(FD, strchr(&temp[1], ' '));
	else
		printf("ERROR: No se especifico FD\n");
	//Pongo el resto del mensaje en temp
	if(strchr(FD, ' ')!=NULL)
		strcpy(temp, strchr(&FD[1], ' '));
	else
		printf("ERROR: No se especifico tamaño\n");

	strcpy(buf, &temp[1]);
	FD[strlen(FD)-strlen(temp)]='\0';

	//Saco la palabra SIZE 
	if(strchr(buf, ' ')!=NULL)
		strcpy(temp, strchr(buf, ' '));
	else
		printf("ERROR: No se especifico tamaño\n");

	//Pongo el tamaño en temp

	size = atoi(&temp[1]);
	printf("Size: %i\n",size);

	int fp ;
	fp = atoi(FD);
	printf("Va a leer del FD:%i\n",fp);
	printf("FD: %i\n",fp);

	if (files_opn == NULL){
		printf( "ERROR: No se pudo leer\n" );
		return 0;
	}
	struct FILE_OPN *temp_file;
	temp_file = files_opn;
	sprintf(temp,"");

	while(temp_file->next!=NULL) {
		if(temp_file->clnt_id==clnt_id && temp_file->fd==fp) {
			sprintf(FD,"%i",fp);
			fp = atoi(&FD[1]);
			lseek(fp,temp_file->br,SEEK_SET);
			i=read(fp,temp,size);
			temp[size] = '\0';
			if(i!=-1) {
				sprintf(msg,"SIZE %i %s",i,temp);
				temp_file->br+=i;
				printf( "Leyó\n" );
				return 1;
			}
			else {
				printf( "ERROR: No se pudo leer\n" );
				return 0;
			}
		}
		temp_file = temp_file->next;
	}
	
	if(temp_file->clnt_id==clnt_id && temp_file->fd==fp){
		sprintf(FD,"%i",fp);
		fp = atoi(&FD[1]);
		printf("FD:%i\n",fp);
		i=read(fp,temp,size);
		temp[size] = '\0';
		if(i!=-1) {
			sprintf(msg,"SIZE %i %s",i,temp);
			temp_file->br=i;
			printf( "Leyó\n" );
			return 1;
		}
	}
	printf( "ERROR: No se pudo leer\n" );
	return 0;
}

int parser_wrt(char* msg, int clnt_id){
	int len=0;
	struct dirent *ent;
	char FD[BUFSIZE];
	char buf[BUFSIZE];
	char temp[BUFSIZE];
	int size=0;
	
	//Saco la palabra FD del mensaje
	if(strchr(msg, ' ')!=NULL)
		strcpy(temp, strchr(&msg[1], ' '));
	else
		printf("ERROR: Se espera FD\n");

	//Copio el FD en FD
	if(strchr(temp, ' ')!=NULL)
		strcpy(FD, strchr(&temp[1], ' '));
	else
		printf("ERROR: No se especifico FD\n");

	//Pongo el resto del mensaje en temp
	if(strchr(FD, ' ')!=NULL)
		strcpy(temp, strchr(&FD[1], ' '));
	else
		printf("ERROR: No se especifico tamaño\n");

	strcpy(buf, &temp[1]);
	FD[strlen(FD)-strlen(temp)]='\0';

	//Saco la palabra SIZE 
	if(strchr(buf, ' ')!=NULL)
		strcpy(temp, strchr(buf, ' '));
	else
		printf("ERROR: No se especifico tamaño\n");

	//Pongo el tamaño en temp
	if(strchr(temp, ' ')!= NULL)
		temp[strlen(temp) - strlen(strchr(&temp[1], ' '))] = '\0';
	else
		printf("ERROR: No se especifico tamaño\n");

	size = atoi(&temp[1]);
	strcpy(temp, buf);
	//Pongo lo q hay para escribir en buf
	if(strchr(temp, ' ') !=NULL)
		strcpy(buf, strchr(&temp[1], ' '));
	else
		printf("ERROR: No hay nada que escribir\n");

	if(strchr(buf, ' ') !=NULL)
		strcpy(temp, strchr(&buf[1], ' '));
	else
		printf("ERROR: No hay nada que escribir\n");

	printf("Size: %i\n",size);

	int fp ;
	printf("Escribe: %s\n",&temp[1]);
	fp = atoi(FD);
	printf("FD: %i\n",fp);

	struct FILE_OPN *temp_file;
	temp_file = files_opn;
	if (temp_file == NULL)
		return 0;

	while(temp_file->next!=NULL) {
		if(temp_file->clnt_id==clnt_id && temp_file->fd==fp) {
			sprintf(FD,"%i",fp);
			fp = atoi(&FD[1]);
			lseek (fp, 0, SEEK_END);
			if( write(fp, &temp[1],size) ){
				printf( "Escribió\n" );
				lseek ( fp , temp_file->br , SEEK_SET );
				return 1;
			}
			else {
				printf( "ERROR: No se pudo escribir\n" );
				return 0;
			}
		}
	temp_file = temp_file->next;
	}
	if(temp_file->clnt_id==clnt_id && temp_file->fd==fp) {
		sprintf(FD,"%i",fp);
		fp = atoi(&FD[1]);
		lseek (fp, 0, SEEK_END);
		if( write(fp, &temp[1],size) ){
			printf( "Escribió\n" );
			lseek ( fp , temp_file->br , SEEK_SET );;
			return 1;
		}
		else {
			printf( "ERROR: No se pudo escribir\n" );
			return 0;
		}
	}
	
}

int parser_clo(char* msg, int clnt_id){
	int len=0;
	struct dirent *ent;
	char FD[BUFSIZE];

	if(strchr(msg, ' ')!=NULL)
		sprintf(FD, "%s",&strchr(msg, ' ')[1]);
	else
		printf("ERROR: No hay archivo");
	int fp ;
	printf("FD: %s\n",strchr(FD, ' '));
	fp = atoi(strchr(FD, ' '));
	printf("FP:%i\n",fp);
	if(files_opn==NULL)
		return 0;

	struct FILE_OPN *temp;
	struct FILE_OPN *temp_free;
	temp = files_opn;
	printf("id:%i fd:%i\n",temp->fd,fp);
	if(temp->clnt_id==clnt_id && temp->fd==fp)
		fp = atoi(&FD[1]);
		if( !close(fp) ){
			temp_free = files_opn;
			files_opn = files_opn->next;
			free(temp_free);
			printf( "Fichero cerrado\n" );
			return 1;
		}

	while(temp->next != NULL){
		printf("id:%i fd:%i\n",temp->fd,fp);
		if(temp->next->clnt_id==clnt_id && temp->next->fd==fp)
			fp = atoi(&FD[1]);
			if( !close(fp) ){
				temp_free = temp->next;
				temp->next=temp->next->next;
				free(temp_free);
				printf( "Fichero cerrado\n" );
				return 1;
			}
		temp = temp->next;
		temp_free = temp;
	}
	printf("id:%i fd:%i\n",temp->fd,fp);
	if(temp->clnt_id==clnt_id && temp->fd==fp)
		fp = atoi(&FD[1]);
		if( !close(fp) ){
			temp_free->next = temp->next;
			free(temp);
			printf( "Fichero cerrado\n" );
			return 1;
		}
	printf( "ERROR: No se pudo cerrar el fichero\n" );
	return 0;
}

void add (FILE_OPN* file) {
	struct FILE_OPN* temp;
	if(files_opn==NULL) {
		files_opn = file;
	}
	else {
		temp = files_opn;
		while(temp->next!=NULL)
			temp = temp->next;
		temp->next = file;
	}		
}	

int parser_opn(char* msg){
	DIR *dir;
	int len=0;
	struct dirent *ent;
	char file[BUFSIZE];

	if(strchr(msg, ' ')!=NULL)
		strcpy(file, strchr(msg, ' '));
	else
		printf("ERROR: No hay archivo");
	
	dir=opendir("./data/");

	while((ent=readdir(dir))!=NULL) 
		if(ent->d_type==DT_REG && ent->d_name[0] != '.') {
			if(!strcmp(&file[1], ent->d_name)){
				struct FILE_OPN *temp;				
				temp = files_opn;
				if (temp==NULL)	{		
					strcpy(msg, "./data/");
					strcat(msg, &file[1]);
					return 1;
				}

				while(temp->next != NULL){
					if(!strcmp(temp->root,&file[1]))
						return 0;
					 temp = temp->next;
				}
				if(!strcmp(temp->root,&file[1]))
					return 0;

				strcpy(msg, "./data/");
				strcat(msg, &file[1]);
				return 1;
			}
		}
	closedir(dir);
	return 0;
}

int parser_cre(char* msg, int n_worker){
	DIR *dir;
	int len=0;
	struct dirent *ent;
	char file[BUFSIZE];
	char ruta[BUFSIZE];

	if(strchr(msg, ' ')!=NULL)
		strcpy(file, strchr(msg, ' '));
	else
		printf("ERROR: No hay archivo");

	dir=opendir("./data");

	while((ent=readdir(dir))!=NULL) 
		if(ent->d_type==DT_REG && ent->d_name[0] != '.') {
			if(!strcmp(&file[1], ent->d_name)){
				return 1;
			}
		}
	closedir(dir);
	if(n_worker == 0) {
		strcpy(ruta, "./data/");
		strcat(ruta, &file[1]);
		FILE *fp;
		fp = fopen ( ruta, "a+" );
		fclose ( fp );
	}
	return 0;
}

int parser_del(char* msg){
	DIR *dir;
	int len=0;
	struct dirent *ent;
	char file[BUFSIZE];

	if(strchr(msg, ' ')!=NULL)
		strcpy(file, strchr(msg, ' '));
	else
		printf("ERROR: No hay archivo");
	
	dir=opendir("./data");

	while((ent=readdir(dir))!=NULL) 
		if(ent->d_type==DT_REG && ent->d_name[0] != '.') {
			if(!strcmp(&file[1], ent->d_name)){
				strcpy(file, "./data/");
				strcat(file, ent->d_name);

				struct FILE_OPN *temp;				
				temp = files_opn;
				if (temp==NULL) {
					remove(file);			
					return 1;
				}

				while(temp->next != NULL){
					if(!strcmp(temp->root,ent->d_name))
						return 0;
					 temp = temp->next;
				}
				if(!strcmp(temp->root,ent->d_name));
					return 0;

				remove(file);	
				return 1;
			}
		}
	closedir(dir);
	return 0;
}

void parser( char* msg, int* clnt_id, int* n_worker){
	int i, len_id, len,total,ok;
	char target_id[BUFSIZE];
	char msg_temp[BUFSIZE];
	char action[BUFSIZE];
	char files[BUFSIZE];
	len = strlen(msg);

	len_id = strchr(msg, ' ') - msg-1;
	strncpy( target_id, msg+1, len_id );
	target_id[len_id] = 0;
	*clnt_id = atoi(target_id);
	total = len_id + 2;

	msg = msg + total;
	len_id = strchr(msg, ' ') - msg;  
	strncpy( target_id, msg, len_id );
	target_id[len_id] = 0;   
	*n_worker = atoi(target_id);
	total += len_id + 1;
	msg = msg + len_id + 1;
	strncpy( msg_temp, msg, len );
	msg = msg - total;
	strncpy( action, msg_temp, len );
	if(strchr(action, ' ')!=NULL)
		action[strlen(action) - strlen(strchr(action, ' '))] = '\0';
	
	ok = 0;

	if(!strcmp(action,"LSD") ){
		ok = 1;
		directory(files);
		strcat(msg_temp,files);
	}

	if(!strcmp(action,"DEL") ) {
		ok = 1;
		if(parser_del(msg_temp)) {
			printf("Elimino\n");
			sprintf(msg,"!%i OK\0",*clnt_id);
			return;
		}
		else
			if(*n_worker==0) {
				printf("No existe el archivo\n");
				sprintf(msg,"!%i ERROR: El archivo no existe o ya esta abierto\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"CRE") ){
		ok = 1;
		if(parser_cre(msg_temp,*n_worker)) {
			printf("ERROR: Ya existe un archivo con ese nombre\n");
			sprintf(msg,"!%i ERROR: Ya existe un archivo con ese nombre\0",*clnt_id);
			return;
		}
		else
			if(*n_worker==0) {	
				printf("Arhivo creado éxito\n");
				sprintf(msg,"!%i OK\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"OPN") ){
		ok = 1;
		if(parser_opn(msg_temp)) {
			printf("Arhivo abierto con éxito\n");
			int fd;
			char sfd[10];
			FILE *fp;
			fp = fopen ( msg_temp, "a+" );
			sprintf(sfd, "%i%i",my_id,fileno(fp));
			fd = atoi(sfd);
			sprintf(msg,"!%i OK FD %i\0",*clnt_id,fd);
			struct FILE_OPN *file;
			file = (struct FILE_OPN*) malloc (sizeof(struct FILE_OPN));
			file->next = NULL;
			file->clnt_id = *clnt_id;
			file->br = 0;
			file->root = malloc (strlen(msg_temp)*sizeof(char));
			sprintf(file->root,"%s",&strchr(&strchr(msg_temp, '/')[1], '/')[1]);
			printf("Ruta del archivo: %s\n",file->root);
			file->fd = fd;
			add(file);
			return;
		}
		else
			if(*n_worker==0) {	
				printf("ERROR: \n");
				sprintf(msg,"!%i ERROR: El archivo no existe o ya esta abierto\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"CLO") ){
		ok = 1;
		if(parser_clo(msg_temp,*clnt_id)) {
			printf("Arhivo cerrado con éxito\n");
			sprintf(msg,"!%i OK\0",*clnt_id);
			return;
		}
		else
			if(*n_worker==0) {	
				printf("ERROR: \n");
				sprintf(msg,"!%i ERROR: No hay ningun archivo abierto con ese FD\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"REA") ){
		ok = 1;
		if(parser_rea(msg_temp,*clnt_id)) {
			printf("Leyó con éxito\n");
			sprintf(msg,"!%i OK %s\0",*clnt_id,msg_temp);
			return;
		}
		else
			if(*n_worker==0) {	
				printf("ERROR: \n");
				sprintf(msg,"!%i ERROR: No hay ningun archivo abierto con ese FD\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"WRT") ){
		ok = 1;
		if(parser_wrt(msg_temp,*clnt_id)) {
			printf("Escribió con éxito\n");
			sprintf(msg,"!%i OK\0",*clnt_id);
			return;
		}
		else
			if(*n_worker==0) {	
				printf("ERROR: \n");
				sprintf(msg,"!%i ERROR: No hay ningun archivo abierto con ese FD\0",*clnt_id);
				return;
			}
	}

	if(!strcmp(action,"BYE") ){
		ok = 1;
		char fd[10];
		FILE_OPN *temp, *temp_free;
		if (files_opn==NULL) 	
			if(*n_worker > 0) {
				sprintf(msg,"?%i %i %s",*clnt_id,*n_worker-1,msg_temp); // Sigue la consulta a otro worker
				return;
			}
			else {
				sprintf(msg,"!%i OK",*clnt_id); //Responde al cliente 
				return;
			}
		temp = files_opn;
		if(temp->clnt_id==*clnt_id) {
			sprintf(fd,"%i",temp->fd);
			close(atoi(fd));
			temp_free = temp;
			files_opn = temp->next;
			free(temp_free);
		}
			
		while(temp->next != NULL){
			if(temp->next->clnt_id == *clnt_id) {
				sprintf(fd,"%i",temp->fd);
				close(atoi(fd));
				temp_free = temp->next;
				temp->next = temp->next->next;
				free(temp_free);
			}
			temp = temp->next;
			temp_free = temp;
		}

		if(temp->clnt_id==*clnt_id) {
			sprintf(fd,"%i",temp->fd);
			close(atoi(fd));
			temp_free->next = temp->next;
			free(temp->next);
		}
 	}

	if(ok!=1) {
		sprintf(msg,"!%i ERROR: Mala sintaxis",*clnt_id);
		return;
	}	
	
	if(*n_worker > 0) {
		sprintf(msg,"?%i %i %s",*clnt_id,*n_worker-1,msg_temp); // Sigue la consulta a otro worker
	}
	else {
		if(strchr(msg_temp, ' ')==NULL)
			sprintf(msg,"!%i OK",*clnt_id); //Responde al cliente 
		else
			sprintf(msg,"!%i OK%s",*clnt_id, strchr(msg_temp,' ')); //Responde al cliente 
			
	}	
	return;
}

void* send_msg( void* arg ) {
	char msg[BUFSIZE];
	int sock = (int) arg;        
	while (1) {
		fgets( msg, BUFSIZE, stdin );
		msg[strlen(msg)+1] = '\0';
		write( sock, msg, strlen(msg) );
	}
}

void* recv_msg( void* arg ) {
	int sock = (int) arg;
	int i,j;
	char recieved[BUFSIZE+IDSIZE+15];
	int len;
	while (1) {
		len = read( sock, recieved, BUFSIZE+IDSIZE+14 );
		if ( len == -1 )
			return (void*)1;
		recieved[len] = 0;
		printf("%s\n",recieved);
		parser(recieved,&i,&j);
		printf("Envia: %s\n",recieved);
		write( sock, recieved, strlen(recieved));
	}
}

int main( int argc, char** argv ) {
	int sock;
	struct sockaddr_in serv_addr;
	pthread_t send_thrd, recv_thrd;
	void* thr_rtn_val;
	char id[IDSIZE];

	sock = socket( PF_INET, SOCK_STREAM, 0 );
	if ( sock == -1 )
		printf("ERROR: No se pudo conectar\n");

	memset( &serv_addr, 0, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = inet_addr( "127.0.0.1");
	serv_addr.sin_port = htons( 8000 );

	if ( connect(sock, (struct sockaddr*) &serv_addr, sizeof(serv_addr)) == -1 )
		printf("ERROR: No se pudo conectar\n");

	write( sock, "Worker", sizeof("Worker") );
	read (sock,id,IDSIZE);
	my_id = atoi(id) + 1;
	
	printf("Este es mi id: %i\n",my_id);
	pthread_create( &send_thrd, NULL, send_msg, (void*) sock );
	pthread_create( &recv_thrd, NULL, recv_msg, (void*) sock );

	pthread_join( send_thrd, &thr_rtn_val );
	pthread_join( recv_thrd, &thr_rtn_val );        

	close( sock );
	return 0;
}
