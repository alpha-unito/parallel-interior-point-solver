#pragma once

#include <vector>
#include <utility>
#include <cmath>
#include <algorithm>
#include <iostream>
#include <ranges>
#include <cuda_runtime.h>
#include <chrono>

using size_type = std::size_t;
using data_type = double;

template<typename matrix>
void print_matrix(const matrix &Mat, const size_type &Nrow, const size_type &Ncol) {
    for (std::size_t i{0}; i < Nrow; ++i) {
        for (std::size_t j{0}; j < Ncol; ++j) {
            std::cout << Mat[i * Ncol + j] << "    ";
        }
        std::cout << std::endl;
    }

}

template<typename matrix>
void print_vector(const matrix &Mat, const size_type &N) {
    for (std::size_t i{0}; i < N; ++i) {
        std::cout << Mat[i] << "   ";
    }
    std::cout << std::endl;

}

void
Kamarkar(std::vector <data_type> &, std::vector <data_type> &, std::vector <data_type> &, std::vector <data_type> &,
         std::vector <data_type> &, std::vector <data_type> &, std::vector <data_type> &, std::vector <data_type> &,
         std::vector <data_type> &, std::vector <data_type> &, const size_type, const size_type, const size_type,
         const size_type, const data_type, const int, const double);
