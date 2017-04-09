#include <stdio.h>
#include <stdlib.h> //required for rand() only to initialize sample matrices
#include "cublas_v2.h"

extern "C" __declspec(dllexport)
void tester(double* x){
    double* y,*dy;
    y = (double*)calloc(2, sizeof(double));
    printf("Hello\n");
    for(int i = 0; i < 2; ++i){
        y[i] = x[i] + 2.;
    }
    cudaMalloc(&dy, 2 * sizeof(double));
    cudaMemcpy(dy,y,2*sizeof(double),cudaMemcpyHostToDevice);

    cudaMemcpy(x,dy,2 * sizeof(double), cudaMemcpyDeviceToHost);
    cudaFree(dy);
    free(y);
}
extern "C" __declspec(dllexport)
void mmult(double* A, double* B, double* C, int* m, int* k, int* n){
#ifdef TESTING
    printf("entered dll function mmult\n");
#endif
    int M = *m;
    int K = *k;
    int N = *n;
    double *da,*db,*dc;
    cudaMalloc(&da, M * K * sizeof(double));
    cudaMalloc(&db, K * N * sizeof(double));
    cudaMalloc(&dc, M * N * sizeof(double));

    cudaMemcpy(da, A, M * K * sizeof(double),cudaMemcpyHostToDevice);
    cudaMemcpy(db, B, K * N * sizeof(double),cudaMemcpyHostToDevice);

#ifdef TESTING
    for(int i = 0; i < M; ++i){
        for(int j = 0; j < K; ++j){
            printf("%7.4f ",A[j * M + i]);
        }
        printf("\n");
    }
    for(int i = 0; i < K; ++i){
        for(int j = 0; j < N; ++j){
            printf("%7.4f ",B[j * K + i]);
        }
        printf("\n");
    }
#endif


    double alpha = 1., beta = 0.;

    cublasHandle_t han;

    cublasCreate(&han);
    {//dispensible
        int cublasversion;    
        cublasGetVersion(han, &cublasversion);
        printf("cublas version is %i\n", cublasversion);
    }
        cublasDgemm(han, CUBLAS_OP_N, CUBLAS_OP_N, 
                    M,N,K, 
                    &alpha, 
                    da, M, 
                    db, K, 
                    &beta, 
                    dc, M);

    cudaMemcpy(C,dc,M * N * sizeof(double),cudaMemcpyDeviceToHost);

#ifdef TESTING
    for(int i = 0; i < M; ++i){
        for(int j = 0; j < N; ++j){
            printf("%7.4f ",C[j * M + i]);
        }
        printf("\n");
    }
#endif
    cublasDestroy(han);

    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
}
int main(){
    int M,N,K;
    M = N = K = 4;
    double* A = (double*)calloc(M * K, sizeof(double));
    double* B = (double*)calloc(K * N, sizeof(double));
    double* C = (double*)calloc(M * N, sizeof(double));
    
    //initialize a
    for(int i = 0; i < M * K; ++i){ A[i] = i + 1.;}
    printf("A:\n");
    for(int i = 0; i < M; ++i){
        for(int j = 0; j < K; ++j){
            printf("%7.4f ",A[j * M + i]);
        }
        printf("\n");
    }
    for(int i = 0; i < K * N; ++i){ B[i] = i * 3 - 2.;}
    printf("B:\n");
    for(int i = 0; i < K; ++i){
        for(int j = 0; j < N; ++j){
            printf("%7.4f ",B[j * K + i]);
        }
        printf("\n");
    }

    mmult(A, B, C, &M, &K, &N);
    printf("C:\n");
    for(int i = 0; i < M; ++i){
        for(int j = 0; j < N; ++j){
            printf("%7.4f ",C[j * M + i]);
        }
        printf("\n");
    }

    free(A);
    free(B);
    free(C);
}

