#include <stdio.h>
#include <pthread.h>

#define N 3
#define ARRLEN	1024

int arr[ARRLEN];
pthread_mutex_t s = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond1 = PTHREAD_COND_INITIALIZER; //Si un escritor esta accediendo al arreglo
pthread_cond_t cond2 = PTHREAD_COND_INITIALIZER; //Si lectores estan accediendo al arreglo
pthread_cond_t cond3 = PTHREAD_COND_INITIALIZER; //Si hay un escritor en espera que acceda al arreglo ni bien sea posible

int escribiendo = 0;
int leyendo = 0;
int escritor_esperando = 0;
void *escritor(void *arg) {
  int i;
  int num = *((int *)arg);
  for (;;) {
    sleep(random()%2);
    pthread_mutex_lock(&s); 
    while(leyendo) {
        escritor_esperando = 1;
	pthread_cond_wait(&cond2,&s);
    }
    escribiendo = 1;
    for (i=0; i<ARRLEN; i++) {
      arr[i] = num;
    }
    //printf("ESCRIBE %d\n",num);
    escribiendo = 0;
    escritor_esperando = 0;
    pthread_cond_broadcast(&cond3);
    pthread_cond_broadcast(&cond1);
    pthread_mutex_unlock(&s);  
}
  return NULL;
}

void *lector(void *arg) {
  int v, i, err;
  int num = *((int *)arg);
  for (;;) {
    sleep(random()%2);
    pthread_mutex_lock(&s);
    while(escritor_esperando){
    	pthread_cond_wait(&cond3,&s);
   }

    while(escribiendo)
	pthread_cond_wait(&cond1,&s);
    err = 0;
    v = arr[0];
    leyendo++;
    pthread_mutex_unlock(&s);
    for (i=1; i<ARRLEN; i++) {
      if (arr[i]!=v) {
        err=1;
        break;
      }
    }
    pthread_mutex_lock(&s);
    leyendo--;
    
    if (err) printf("Lector %d, error de lectura\n", num);
    else printf("Lector %d, dato %d\n", num, v);
    pthread_cond_broadcast(&cond2);
    pthread_mutex_unlock(&s);
  }
  return NULL;
}

int main() {
  int i;
  pthread_t lectores[N], escritores[N];
  int arg[N];

  for (i=0; i<ARRLEN; i++) {
    arr[i] = -1;
  }
  for (i=0; i<N; i++) {
    arg[i] = i;
    pthread_create(&lectores[i], NULL, lector, (void *)&arg[i]);
    pthread_create(&escritores[i], NULL, escritor, (void *)&arg[i]);
  }
  pthread_join(lectores[0], NULL); // Espera para siempre 
  return 0;
}

