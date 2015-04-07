#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <omp.h>
#include <pthread.h>

#define N_FILOSOFOS 5
#define ESPERA 50000

pthread_mutex_t tenedor[N_FILOSOFOS];

void pensar(int i){
	printf("Filosofo %d pensando...\n",i);
	usleep(random() % ESPERA);
}

void comer(int i){
	printf("Filosofo %d comiendo...\n",i);
	usleep(random() % ESPERA);
}

void tomar_tenedores_zurdo(int i) {
	pthread_mutex_lock(&(tenedor[(i+1)%N_FILOSOFOS])); /* Toma el tenedor a su izquierda */
	sleep(1);
	pthread_mutex_lock(&(tenedor[i])); /* Toma el tenedor a su derecha */
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

void diestro() {
	for (;;) {
		tomar_tenedores(omp_get_thread_num());
		comer(omp_get_thread_num());
		dejar_tenedores(omp_get_thread_num());
		pensar(omp_get_thread_num());
	}
}

void zurdo() {
	for (;;) {
		tomar_tenedores_zurdo(omp_get_thread_num());
		comer(omp_get_thread_num());
		dejar_tenedores(omp_get_thread_num());
		pensar(omp_get_thread_num());
	}
}

int main () {
	omp_set_num_threads(N_FILOSOFOS);

	#pragma omp parallel
	{
		#pragma omp sections nowait
		{
			#pragma omp section
			zurdo();
		}

		diestro();
	}

	return 0;
}
