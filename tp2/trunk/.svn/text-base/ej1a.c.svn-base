#include <stdio.h>
#include <omp.h>
#define N_VISITANTES 10000000
#define N_PROC 2
int visitantes = 0;

void molinete () {
	int i;
	printf("Hilo %d\n",omp_get_thread_num());
	for(i=0; i<N_VISITANTES;i++) {
		visitantes++;
	}
}

int main(){
	int i;
	#pragma omp parallel for
	for(i=0; i<N_PROC;i++) 
		molinete();
	printf("Hubo %d visitantes\n", visitantes);
	return 0;
}

