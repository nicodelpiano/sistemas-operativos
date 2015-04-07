#include <stdio.h>
#include <pthread.h>

#define N 35

void* fib(void *x) {
	int n = *(int*)x;

	if(n<2)
		return ;
	else {
		pthread_t t1,t2;
		int n1 = n-1, n2 = n-2;
		int f=0;

		if(n > N-5) {
			pthread_create(&t1, NULL, fib, &n1);
			pthread_create(&t2, NULL, fib, &n2);
			f = 1;
		} 
		else {
			fib(&n1);
			fib(&n2);
		}
		
		if(f) {
			pthread_join(t1, NULL);
			pthread_join(t2, NULL);
		}

		*(int*)x = n1+n2;
	}
}

int main() {
	int x = N;

	fib(&x);

	printf("%i\n",x);
	return 0;
}

