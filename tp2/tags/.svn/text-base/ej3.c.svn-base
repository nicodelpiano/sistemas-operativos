#include <stdio.h>
#include <omp.h>

int es_primo=1;

int primo(long long n){

	int	w=omp_get_thread_num();
	int	q=omp_get_num_threads();
	long long i;
	if (w==0) {
		for(i=2;i<(n/q)*(w+1);i++){
			if (es_primo == 0)
				return 0;
			if (n % i == 0) {
				es_primo = 0;
				return 0;
			}
		}
	}
	else {
		for(i=(n/q)*w;i<(n/q)*(w+1);i++){
			if (es_primo == 0)
				return 0;
			if (n % i == 0) {
				es_primo = 0;
				return 0;
			}
		}
	}
}


/*int main(int argc, char **argv){

	long long i,n;
	double TI, TF;
	if (argc<2)
		return -1;
	sscanf(argv[1], "%lld", &n);
	TI = omp_get_wtime();
	#pragma omp parallel
		primo(n);
	TF = omp_get_wtime();
	printf("El numero %lld %s primo.\n",n, es_primo ? "es" : "no es");
	printf("Tiempo: %f\n",TF-TI);
	return 0;
}*/

int main(int argc, char **argv){

	long long i,n;
	double TI, TF;
	if (argc<2)
		return -1;
	sscanf(argv[1], "%lld", &n);
	TI = omp_get_wtime();
	#pragma omp parallel for
		for (i=2;i<n;i++) {
			if (n % i == 0){
				es_primo=0;
			}
		}
	TF = omp_get_wtime();
	printf("El numero %lld %s primo.\n",n, es_primo ? "es" : "no es");
	printf("Tiempo: %f\n",TF-TI);
	return 0;
}





