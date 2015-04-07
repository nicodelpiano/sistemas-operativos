#include <stdio.h>
#include <omp.h>
#define N_NUM  20
#define N_PROC  4
int ARRAY[N_NUM];
int MIN = 100;
int A_MIN[N_PROC];


int buscarmin () {
	int i;
    int	w=omp_get_thread_num();
	for(i=(N_NUM/N_PROC)*w;i<(N_NUM/N_PROC)*(w+1);i++)
		if(ARRAY[i]<A_MIN[w])
			A_MIN[w] = ARRAY[i];
}

int main () {
	
	int i;
	double TI, TF;
	for(i=0;i<4;i++)
		A_MIN[i]=MIN;
	srand(time (NULL));
	for(i=0;i<N_NUM;i++){
		ARRAY[i] = random()% MIN;
		printf("%i ",ARRAY[i]);
	}
	omp_set_num_threads(N_PROC);
	TI = omp_get_wtime();
	#pragma omp parallel
		buscarmin();
	TF = omp_get_wtime();
	for(i=0;i<4;i++)
		if(MIN>A_MIN[i])
			MIN = A_MIN[i];

	printf("Minimio %i, Tiempo %g\n",MIN,TF-TI);
	return 0;
}
