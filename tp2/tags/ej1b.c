#include <stdio.h>
#include <omp.h>
#define N_VISITANTES 10000000
#define N_PROC 2
int visitantes = 0;
int choosing[N_PROC];
int ticket[N_PROC];

int max() {
	int l=-1;
	int i;
	for(i=0; i<N_PROC; i++)
		if(ticket[i] > l)
			l = ticket[i];
	return l+1;
}

int favoured (int i, int j) {
	if(ticket[i] > ticket[j] || ticket[i] == 0)
		return 0;
	else if (ticket[i] < ticket[j]) 
			return 1;
		else
			return i<j;
}

void lock(int i) {
	int otherproc;
	choosing[i]=1;
	ticket[i] = max();
	choosing[i] = 0;
	for(otherproc = 0; otherproc < N_PROC; otherproc++){
		while(choosing[otherproc]);
		while(favoured(otherproc,i));
	}
}

void unlock(int i) {
	ticket[i] = 0;
}

void molinete () {
	int i;
	printf("Hilo %d\n",omp_get_thread_num());
	for(i=0; i<N_VISITANTES;i++) {
		lock(omp_get_thread_num());
		visitantes++;
		unlock(omp_get_thread_num());
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


