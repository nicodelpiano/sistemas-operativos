#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define N 1024
int A[N][N],B[N][N],C[N][N];

void dumpMatrix(int A[N][N]) {
 int i,j;
  for (i=0;i<N;i++) {
    for (j=0;j<N;j++) {
      printf("%d ",A[i][j]);
    }
    printf("\n");
  }
  printf("*******************************************************\n");
}

int main() {
  int i,j,k;

  #pragma omp parallel for private(j)
  for (i=0;i<N;i++)
    for (j=0;j<N;j++) {
      A[i][j]=i + 1000*j;
      B[j][i]=j + i*1000;  //B transpuesta
    }

  #pragma omp parallel for private(j,k)
  for (i=0;i<N;i++){
    for (j=0;j<N;j++){ 
      for (k=0;k<N;k++) 
        C[i][j]+=A[i][k]*B[j][k]; //Acomodo los indices de forma optima 
    }
  }
  
  return 0;
}

