#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>

#define N_FILOSOFOS 5
#define ESPERA 50000

pthread_mutex_t tenedor[N_FILOSOFOS];
sem_t S;

void pensar(int i) {
	printf("Filosofo %d pensando...\n",i);
	usleep(random() % ESPERA);
}

void comer(int i) {
	printf("Filosofo %d comiendo...\n",i);
	usleep(random() % ESPERA);
}

void tomar_tenedores(int i) {
	pthread_mutex_lock(&(tenedor[i])); /* Toma el tenedor a su derecha */
	sleep(1);
	pthread_mutex_lock(&(tenedor[(i+1)%N_FILOSOFOS])); /* Toma el tenedor a su izquierda */
}

void dejar_tenedores(int i) {
	pthread_mutex_unlock(&(tenedor[i])); /* Deja el tenedor de su derecha */
	pthread_mutex_unlock(&(tenedor[(i+1)%N_FILOSOFOS])); /* Deja el tenedor de su izquierda */
}

void *filosofo(void *arg) {
	int i = *(int*)arg;
	for (;;) {
		sem_wait(&S);
		tomar_tenedores(i);
		comer(i);
		dejar_tenedores(i);
		sem_post(&S);
		pensar(i);
	}
}

int main () {
	int args[N_FILOSOFOS];
	pthread_t th[N_FILOSOFOS];
	int i;

	sem_init(&S, 0, 4);
	for (i=0;i<N_FILOSOFOS;i++)
		pthread_mutex_init(&tenedor[i], NULL);

	for (i=0;i<N_FILOSOFOS;i++) {
		args[i] = i;
		pthread_create(&th[i], NULL, filosofo, &args[i]);
	}

	pthread_join(th[0], NULL);

	return 0;
}
