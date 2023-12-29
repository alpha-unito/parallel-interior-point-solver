#include "myutilsCUDA.h"

#include <fstream>

void read_matrix(std::string pathname, std::vector<double> &A_vec, const int &Nrow,
                 const int &Ncol) {
    std::ifstream matrix_file;
    matrix_file.open(pathname);
    for (int i = 0; i < Nrow; i++) {
        for (int j = 0; j < Ncol; j++) {
            matrix_file >> A_vec[i * Ncol + j];
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
    const int N{Nrow * Ncol};
    const int N1{(Nrow + 1) * Ncol};
    const int maxIter{std::stoi(argv[5])};
    const double tol{std::stod(argv[6])};

    std::vector<data_type> A_vec(N);
    std::vector<data_type> B_vec(N1);
    std::vector<data_type> BB_vec((Nrow + 1) * (Nrow + 1));
    std::vector<data_type> c_vec(Ncol);
    std::vector<data_type> c_vec1(Nrow + 1);
    std::vector<data_type> x_vec(Ncol);
    std::vector<data_type> w_vec(Nrow + 1);
    std::vector<data_type> w_vec1(Ncol);
    std::vector<data_type> d_vec(Ncol);
    std::vector<data_type> y_vec(Ncol);

    data_type alpha = static_cast<data_type>((Ncol - 1.0) / (3.0 * Ncol) *
                                             (1.0 / std::sqrt(Ncol * (Ncol - 1.0))));

    read_matrix(std::string(argv[1]), A_vec, Nrow, Ncol);
    read_vec(std::string(argv[2]), c_vec, Ncol);

    for (int i = 0; i < Ncol; ++i) {
        x_vec[i] = (1.0 / Ncol);
    }
    Kamarkar(A_vec, B_vec, BB_vec, c_vec, c_vec1, x_vec, w_vec, w_vec1, d_vec, y_vec, Nrow, Ncol, N,
             N1, alpha, maxIter, tol);
}
