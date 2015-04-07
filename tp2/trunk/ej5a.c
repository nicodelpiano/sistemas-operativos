#include <stdio.h>
#include <pthread.h>

void* fib(void *x) {
	int n = *(int*)x;

	if(n<2)
		return ;
	else {
		pthread_t t1,t2;
		int n1=n-1,n2=n-2;
		pthread_create(&t1, NULL, fib, &n1);
		pthread_create(&t2, NULL, fib, &n2);
		pthread_join(t1, NULL);
		pthread_join(t2, NULL);
		*(int*)x = n1+n2;
	}
}

int main() {
	int x = 18;
	pthread_t t;

	pthread_create(&t, NULL, fib, &x);
	pthread_join(t, NULL);

	printf("%i\n",x);
	return 0;
}
	
