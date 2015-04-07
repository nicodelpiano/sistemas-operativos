#include <stdio.h>
#include <pthread.h>

#define N_VISITANTES 10000002
#define N_MOLINETES 7

pthread_mutex_t lk;
int visitantes = 0;

void* molinete(void* arg)
{
	int w = *(int*)arg;
	int i,dif;
	dif=N_VISITANTES/N_MOLINETES;

	for (i=0;i<(N_VISITANTES/N_MOLINETES);i++) {
		pthread_mutex_lock(&lk);
		visitantes++;
		pthread_mutex_unlock(&lk);
	}
	
	if(!w){ //Por si la division no es entera
		for (i=0; i<N_VISITANTES - N_MOLINETES*dif ;i++) {
			pthread_mutex_lock(&lk);
			visitantes++;
			pthread_mutex_unlock(&lk);
		}
	}
}

int main ()
{
	int i;
	pthread_t th[N_MOLINETES];
	pthread_t args[N_MOLINETES];

	pthread_mutex_init(&lk, NULL);

	for(i=0; i<N_MOLINETES; ++i) {
		args[i] = i;
		pthread_create(&th[i], NULL, molinete, args+i);
	}

	for(i=0; i<N_MOLINETES; ++i)
		pthread_join(th[i], NULL);

	printf("Hoy hubo %d visitantes!\n", visitantes);
	return 0;
}
