/*
Kamarkar algorithm stdpar
*/

#include <chrono>
#include <cmath>
#include <fstream>
#include <iostream>
#include <utility>
#include <vector>

#include "omp.h"

using size_type = std::size_t;
using data_type = double;

constexpr data_type ONE  = 1.0;
constexpr data_type MONE = -1.0;
constexpr data_type ZERO = 0.0;

void print_vector(data_type *vec, size_type N) {
    for (int i = 0; i < N; ++i) {
        std::cout << vec[i] << std::endl;
    }
}

void print_matrix(data_type *mat, size_type Nrow, size_type Ncol) {
    for (int i = 0; i < Nrow; ++i) {
        for (int j = 0; j < Ncol; ++j) {
            std::cout << mat[i * Ncol + j] << " ";
        }
        std::cout << std::endl;
    }
}

/*
    x_i=x_i*y_i
*/
void sym_rank1(data_type *inout, const data_type *in, const size_type N) {

#pragma omp parallel for
    for (size_type i = 0; i < N; i++) {
        inout[i] = inout[i] * in[i];
    }
}

/*
    A_ij=A_ij*x_j
*/
void sym_rank2(data_type *A, const data_type *x, const size_type Nrow, const size_type Ncol) {

#pragma omp parallel for collapse(2)
    for (size_type i = 0; i < Nrow; i++) {
        for (size_type j = 0; j < Ncol; j++) {
            A[i * Ncol + j] = A[i * Ncol + j] * x[j];
        }
    }
}

void copy(data_type *A, data_type *B, const size_type N) {

#pragma omp parallel for
    for (size_type i = 0; i < N; ++i) {
        B[i] = A[i];
    }
}

void dsum(data_type *A, data_type y, const size_type N) {

#pragma omp parallel for
    for (size_type i = 0; i < N; ++i) {
        A[i] = y;
    }
}

void dgemv_transpose(data_type *A, data_type *b, data_type *c, const data_type alpha,
                     const size_type Nrow, const size_type Ncol) {

    for (size_type i = 0; i < Nrow; ++i) {
#pragma omp parallel for
        for (size_type j = 0; j < Ncol; ++j) {
            c[j] += alpha * A[i * Ncol + j] * b[i];
        }
    }
}

void dgemv(data_type *A, data_type *b, data_type *c, const data_type alpha, const size_type Nrow,
           const size_type Ncol) {

#pragma omp parallel for
    for (size_type i = 0; i < Nrow; ++i) {
        double tmp = 0.0;
        for (size_type j = 0; j < Ncol; ++j) {
            tmp += A[i * Ncol + j] * b[j];
        }
        c[i] = alpha * tmp;
    }
}

void dgemm_transpose(data_type *B_out, data_type *B_in, const size_type Nrow,
                     const size_type Ncol) {

#pragma omp parallel for collapse(2)
    for (size_type i = 0; i < Nrow; ++i) {
        for (size_type j = 0; j < Nrow; ++j) {
            double tmp = 0.0;
            for (size_type k = 0; k < Ncol; ++k) {
                tmp += B_in[i * Ncol + k] * B_in[j * Ncol + k];
            }
            B_out[i * Nrow + j] = tmp;
        }
    }
}

void chol_fact(data_type *L, const size_type Nrow) {
    for (size_type k = 0; k < Nrow; ++k) {
        L[k * Nrow + k] = std::sqrt(L[k * Nrow + k]);

#pragma omp parallel for
        for (size_type i = k + 1; i < Nrow; ++i) {
            L[i * Nrow + k] /= L[k * Nrow + k];
        }

#pragma omp parallel for collapse(2)
        for (size_type j = k + 1; j < Nrow; ++j) {
            for (size_type i = j; i < Nrow; ++i) {
                L[i * Nrow + j] = L[i * Nrow + j] - L[i * Nrow + k] * L[j * Nrow + k];
            }
        }
    }
}

void transpose(data_type *L, size_type Nrow) {

#pragma omp parallel for collapse(2)
    for (size_type a = 1; a < Nrow; a++) {
        for (size_type b = 0; b < a; b++) {
            data_type tmp   = L[a * Nrow + b];
            L[a * Nrow + b] = L[b * Nrow + a];
            L[b * Nrow + a] = tmp;
        }
    }
}

void solv_chol(data_type *L, data_type *w, data_type *c, const size_type Nrow) {

    // for(size_type i=0; i<Nrow; i++){
    //     double sum=0.0;
    //     for(size_type j=0; j<i; j++){
    //         sum+=L[i*Nrow+j]*w[j];
    //     }
    //     w[i]=(c[i]-sum)/L[i*Nrow+i];
    // }

#pragma omp parallel for
    for (size_type i = 0; i < Nrow; i++) {
        w[i] = c[i] / L[i * Nrow + i];
    }

    for (size_type i = 0; i < Nrow; i++) {
        double sum = 0.0;
#pragma omp parallel for reduction(+ : sum)
        for (size_type j = 0; j < i; j++) {
            sum += L[i * Nrow + j] * w[j];
        }
        w[i] -= sum / L[i * Nrow + i];
    }

    transpose(L, Nrow);

#pragma omp parallel for
    for (int64_t i = Nrow - 1; i >= 0; --i) {
        w[i] = w[i] / L[i * Nrow + i];
    }

    for (int64_t i = Nrow - 1; i >= 0; --i) {
        double sum = 0.0;
#pragma omp parallel for reduction(+ : sum)
        for (int64_t j = Nrow - 1; j > i; --j) {
            sum += L[i * Nrow + j] * w[j];
        }
        w[i] -= sum / L[i * Nrow + i];
    }
}

void read_matrix(std::string pathname, std::vector<double> &A_vec, const int &Nrow,
                 const int &Ncol) {
    std::ifstream matrix_file;
    matrix_file.open(pathname);
    for (int i = 0; i < Nrow; i++) {
        for (int j = 0; j < Ncol; j++) {
            matrix_file >> A_vec[j * Nrow + i];
        }
    }
}

void read_vec(std::string pathname, std::vector<double> &v_vec, const int &Ncol) {
    std::ifstream vector_file;
    vector_file.open(pathname);
    for (int i = 0; i < Ncol; i++) {
        vector_file >> v_vec[i];
    }
}

int main(int argc, char *argv[]) {

    if (argc != 7) {
        std::cout << "Insert [A matrix filename] [B vector filename] [A matrix Nrow]  [A matrix "
                     "Ncol] [maxIter] [tolerance]"
                  << std::endl;
        exit(10);
    }
    std::cout << "argc " << argc << " Nrow " << argv[1] << " Ncol " << argv[2] << std::endl;
    const int Nrow{std::stoi(argv[3])};
    const int Ncol{std::stoi(argv[4])};
    const int maxIter{std::stoi(argv[5])};
    const double tol{std::stod(argv[6])};

    const int N{Nrow * Ncol};
    const int N1{(Nrow + 1) * Ncol};
    double res{1.0};
    size_type iter{0};
    size_type m = Nrow + 1;
    size_type n = Nrow + 1;
    size_type k = Ncol;

    std::chrono::time_point<std::chrono::high_resolution_clock> start;
    std::chrono::time_point<std::chrono::high_resolution_clock> end;

    std::vector<data_type> A_vec(N);
    std::vector<data_type> B_vec(N1);
    std::vector<data_type> BB_vec((Nrow + 1) * (Nrow + 1));
    std::vector<data_type> c_vec(Ncol);
    std::vector<data_type> c_ori(Ncol);
    std::vector<data_type> c_vec1(Nrow + 1);
    std::vector<data_type> x_vec(Ncol);
    std::vector<data_type> w_vec(Nrow + 1);
    std::vector<data_type> w_vec1(Ncol);
    std::vector<data_type> d_vec(Ncol);
    std::vector<data_type> y_vec(Ncol);

    data_type norm;
    data_type norm_dot;
    data_type alpha = static_cast<data_type>((Ncol - 1.0) / (3.0 * Ncol) *
                                             (1.0 / std::sqrt(Ncol * (Ncol - 1.0))));

    read_matrix(std::string(argv[1]), A_vec, Nrow, Ncol);
    read_vec(std::string(argv[2]), c_vec, Ncol);

#pragma omp parallel for
    for (int i = 0; i < Ncol; ++i) {
        x_vec[i] = (1.0 / Ncol);
        c_ori[i] = c_vec[i];
    }

#pragma omp parallel for
    for (int j = 0; j < Ncol; ++j) {
        B_vec[Nrow * Ncol + j] = 1.0;
    }

    while (res > tol) {

        start = std::chrono::high_resolution_clock::now();

        sym_rank1(c_vec.data(), x_vec.data(), Ncol);

        sym_rank2(A_vec.data(), x_vec.data(), Nrow, Ncol);

        copy(A_vec.data(), B_vec.data(), Nrow * Ncol);

        dgemv(B_vec.data(), c_vec.data(), c_vec1.data(), ONE, Nrow + 1, Ncol);

        dgemm_transpose(BB_vec.data(), B_vec.data(), Nrow + 1, Ncol);

        chol_fact(BB_vec.data(), Nrow + 1);

        solv_chol(BB_vec.data(), w_vec.data(), c_vec1.data(), Nrow + 1);

        dgemv_transpose(B_vec.data(), w_vec.data(), c_vec.data(), MONE, Nrow + 1, Ncol);

        norm = 0.0;
#pragma omp parallel for reduction(+ : norm)
        for (size_type i = 0; i < Ncol; ++i) {
            norm += c_vec[i] * c_vec[i];
        }

        norm = std::sqrt(norm);

        double tmp = -alpha / norm;

        dsum(d_vec.data(), 1.0 / Ncol, Ncol);

#pragma omp parallel for
        for (size_type i = 0; i < Ncol; ++i) {
            d_vec[i] += tmp * c_vec[i];
        }

        norm_dot = 0.0;
#pragma omp parallel for reduction(+ : norm_dot)
        for (size_type i = 0; i < Ncol; ++i) {
            norm_dot += x_vec[i] * d_vec[i];
        }
        norm_dot = 1.0 / norm_dot;

        sym_rank1(x_vec.data(), d_vec.data(), Ncol);

#pragma omp parallel for
        for (size_type i = 0; i < Ncol; ++i) {
            x_vec[i] = x_vec[i] * norm_dot;
        }

        res = 0.0;
#pragma omp parallel for reduction(+ : res)
        for (size_type i = 0; i < Ncol; ++i) {
            res += c_ori[i] * x_vec[i];
        }

        res = std::abs(res);
        end = std::chrono::high_resolution_clock::now();
        
        std::cout << "[Iter " << iter << "] norm " << norm << " norm dot " << 1 / norm_dot << " res "
                  << res << " Iter Time: " << std::chrono::duration<double>(end - start).count()
                  << std::endl;

        if (++iter > maxIter) {
            std::cout << "Reached max iterations iter=" << iter << std::endl;
            break;
        }
    }
}
