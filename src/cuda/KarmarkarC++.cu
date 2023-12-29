#include "cusolverDn.h"
#include "myutilsCUDA.h"
#include <cublas_v2.h>

constexpr size_type Nblock  = 1024;
constexpr size_type Nthread = 256;

constexpr data_type ONE  = 1.0;
constexpr data_type MONE = -1.0;
constexpr data_type ZERO = 0.0;

/*
    x_i=x_i*y_i
*/
__global__ void sym_rank1(data_type *inout, const data_type *in, const size_type N) {

    int xid = threadIdx.x + (blockDim.x * blockIdx.x);

    while (xid < N) {
        inout[xid] = inout[xid] * in[xid];
        xid += blockDim.x * gridDim.x;
    }
}
/*
    A_ij=A_ij*x_j
*/
__global__ void sym_rank2(data_type *A, const data_type *x, const size_type Nrow,
                          const size_type Ncol) {

    std::size_t tid = blockIdx.x;
    // xid<Ncol

    while (tid < Nrow) {
        std::size_t xid = threadIdx.x;
        while (xid < Ncol) {
            A[tid * Ncol + xid] = A[tid * Ncol + xid] * x[xid];
            xid += blockDim.x;
        }
        tid += gridDim.x;
    }
}

__global__ void copy(data_type *A, data_type *B, const size_type N) {
    int xid = threadIdx.x + (blockDim.x * blockIdx.x);

    while (xid < N) {
        B[xid] = A[xid];
        xid += blockDim.x * gridDim.x;
    }
}

__global__ void dsum(data_type *A, data_type y, const size_type N) {
    int xid = threadIdx.x + (blockDim.x * blockIdx.x);

    while (xid < N) {
        A[xid] = y;
        xid += blockDim.x * gridDim.x;
    }
}

void Kamarkar(std::vector<data_type> &A_vec, std::vector<data_type> &B_vec,
              std::vector<data_type> &BB_vec, std::vector<data_type> &c_vec,
              std::vector<data_type> &c_vec1, std::vector<data_type> &x_vec,
              std::vector<data_type> &w_vec, std::vector<data_type> &w_vec1,
              std::vector<data_type> &d_vec, std::vector<data_type> &y_vec, const size_type Nrow,
              const size_type Ncol, const size_type N, const size_type N1, const data_type alpha,
              const int max_iter, const double tol) {

    std::chrono::time_point<std::chrono::high_resolution_clock> start;
    std::chrono::time_point<std::chrono::high_resolution_clock> end;

    double *A_vec_dev;
    double *B_vec_dev;
    double *BB_vec_dev;
    double *c_vec_dev;
    double *co_vec_dev;
    double *c_vec1_dev;
    double *x_vec_dev;
    double *w_vec_dev;
    double *w_vec1_dev;
    double *d_vec_dev;
    double *y_vec_dev;

    double norm{0.0};
    double norm_dot{0.0};
    double res{1.0};

    cublasHandle_t handle;
    cusolverDnHandle_t cuSolverHandle;
    cublasFillMode_t uplo = CUBLAS_FILL_MODE_LOWER;

    cusolverDnCreate(&cuSolverHandle);
    cublasCreate(&handle);

    cudaMalloc(&A_vec_dev, sizeof(data_type) * N);
    cudaMalloc(&B_vec_dev, sizeof(data_type) * N1);
    cudaMalloc(&BB_vec_dev, sizeof(data_type) * (Nrow + 1) * (Nrow + 1));
    cudaMalloc(&c_vec_dev, sizeof(data_type) * Ncol);
    cudaMalloc(&co_vec_dev, sizeof(data_type) * Ncol);
    cudaMalloc(&c_vec1_dev, sizeof(data_type) * (Nrow + 1));
    cudaMalloc(&x_vec_dev, sizeof(data_type) * Ncol);
    cudaMalloc(&w_vec_dev, sizeof(data_type) * (Nrow + 1));
    cudaMalloc(&w_vec1_dev, sizeof(data_type) * Ncol);
    cudaMalloc(&d_vec_dev, sizeof(data_type) * Ncol);
    cudaMalloc(&y_vec_dev, sizeof(data_type) * Ncol);

    cudaMemcpy(A_vec_dev, A_vec.data(), sizeof(data_type) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(c_vec_dev, c_vec.data(), sizeof(data_type) * Ncol, cudaMemcpyHostToDevice);
    cudaMemcpy(x_vec_dev, x_vec.data(), sizeof(data_type) * Ncol, cudaMemcpyHostToDevice);

    cudaMemcpy(co_vec_dev, c_vec_dev, sizeof(double) * (Ncol), cudaMemcpyDeviceToDevice);

    for (int j = 0; j < Ncol; ++j) {
        B_vec[Nrow * Ncol + j] = 1.0;
    }

    cudaMemcpy(B_vec_dev, B_vec.data(), sizeof(data_type) * N1, cudaMemcpyHostToDevice);

    int iter = 0;
    int m    = Nrow + 1;
    int n    = Nrow + 1;
    int k    = Ncol;

    while (res > tol) {

        start = std::chrono::high_resolution_clock::now();

        norm     = 0.0;
        norm_dot = 0.0;

        sym_rank1<<<Nblock, Nthread>>>(c_vec_dev, x_vec_dev, Ncol);

        sym_rank2<<<Nblock, Nthread>>>(A_vec_dev, x_vec_dev, Nrow, Ncol);

        cudaMemcpy(B_vec_dev, A_vec_dev, sizeof(double) * (N), cudaMemcpyDeviceToDevice);

        // c1=B*c
        cublasDgemv(handle, CUBLAS_OP_T, Ncol, Nrow + 1, &ONE, B_vec_dev, Ncol, c_vec_dev, 1, &ZERO,
                    c_vec1_dev, 1);

        // B*BT, B=Nrow+1 x Ncol, BT=Ncol x Nrow+1       m=Nrow+1, n=Ncol,k=Ncol

        cublasDgemm(handle, CUBLAS_OP_T, CUBLAS_OP_N, m, n, k, &ONE, B_vec_dev, k, B_vec_dev, k,
                    &ZERO, BB_vec_dev, m);

        int bufferSize = 0;
        int *info      = NULL;
        double *buffer = NULL;
        int h_info     = 0;

        cusolverDnDpotrf_bufferSize(cuSolverHandle, uplo, n, BB_vec_dev, n, &bufferSize);

        cudaMalloc(&buffer, sizeof(double) * bufferSize);
        cudaMalloc(&info, sizeof(int));


        cusolverDnDpotrf(cuSolverHandle, uplo, n, BB_vec_dev, n, buffer, bufferSize, info);

        cudaMemcpy(&h_info, info, sizeof(int), cudaMemcpyDeviceToHost);
        if (0 != h_info) {
            fprintf(stderr, "Error: Cholesky factorization failed\n");
            std::cout << h_info << std::endl;
            exit(100);
        }

        cudaMemcpy(w_vec_dev, c_vec1_dev, sizeof(double) * (Nrow + 1), cudaMemcpyDeviceToDevice);

        cusolverDnDpotrs(cuSolverHandle, uplo, n, 1, BB_vec_dev, n, w_vec_dev, n, info);

        cublasDgemv(handle, CUBLAS_OP_N, Ncol, Nrow + 1, &MONE, B_vec_dev, Ncol, w_vec_dev, 1, &ONE,
                    c_vec_dev, 1);

        cublasDnrm2(handle, Ncol, c_vec_dev, 1, &norm); // euclidean norm

        double tmp = -alpha / norm;

        dsum<<<Nblock, Nthread>>>(d_vec_dev, 1.0 / Ncol, Ncol);

        cublasDaxpy(handle, Ncol, &tmp, c_vec_dev, 1, d_vec_dev, 1);

        cublasDdot(handle, Ncol, x_vec_dev, 1, d_vec_dev, 1, &norm_dot);

        sym_rank1<<<Nblock, Nthread>>>(x_vec_dev, d_vec_dev, Ncol);

        norm_dot = 1 / norm_dot;
        cublasDscal(handle, Ncol, &norm_dot, x_vec_dev, 1);

        cublasDdot(handle, Ncol, co_vec_dev, 1, x_vec_dev, 1, &res);

        res = std::abs(res);

        cudaMemcpy(x_vec.data(), x_vec_dev, sizeof(data_type) * (Ncol), cudaMemcpyDeviceToHost);

        end = std::chrono::high_resolution_clock::now();

        std::cout << "[Iter " << iter << "] norm " << norm << " norm dot " << 1 / norm_dot << " res "
                  << res << " Iter Time: " << std::chrono::duration<double>(end - start).count()
                  << std::endl;
        // print_vector(x_vec,Ncol);

        if (++iter > max_iter) {
            std::cout << "Reached max iterations iter=" << iter << std::endl;
            break;
        }
    }
}
