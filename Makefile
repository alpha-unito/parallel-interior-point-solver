NVCC := $(shell which nvcc)
NVCpp := $(shell which nvc++)
CC := $(shell which g++)

all: cuda openmp

cuda: makedir src/cuda/KarmarkarC++.cu src/cuda/main_cuda.cpp src/cuda/myutilsCUDA.h
	@if [ "$(NVCC)" == "" ]; then \
		echo "NVCC compiler not found"; \
		exit 1; \
	fi
	$(NVCC) -arch=sm_80 -O3 -c src/cuda/KarmarkarC++.cu -o build/KarmarkarCUDA.o
	$(NVCC) -std=c++17 -O3 --library cublas --library cusolver -c src/cuda/main_cuda.cpp -o build/main_cuda.o
	$(NVCC) -std=c++17 -O3 --library cublas --library cusolver build/KarmarkarCUDA.o  build/main_cuda.o -o build/Karmarkar.cuda
	cp build/Karmarkar.cuda .


openmp: makedir src/KarmarkarOpenMP.cpp
	@if [ "$(CC)" == "" ]; then \
		echo "g++ compiler not found"; \
		exit 1; \
	fi
	$(CC) -std=c++17 -O3 -fopenmp src/KarmarkarOpenMP.cpp -o build/Karmarkar.openmp
	cp build/Karmarkar.openmp .

sequential: openmp
	@echo "|==========================================================|"
	@echo "|                                                          |"
	@echo "|    WARNING: to launch a sequential code run, please      |"
	@echo "|    run the OpenMP implementation with a                  |"
	@echo "|    single thread by setting the environment variable     |"
	@echo "|    OMP_NUM_THREADS=1                                     |"
	@echo "|                                                          |"
	@echo "|==========================================================|"

makeMatrix: matrix-creation/gen_mat.py
	@if [ "$(DIAGSIZE)" == "" ]; then \
		echo "DIAGSIZE not set!"; \
		echo "usage: DIAGSIZE=<value> CUT=<value> make makeMatrix"; \
		exit 1; \
	fi
	@if [ "$(CUT)" == "" ]; then \
		echo "CUT not set!"; \
		echo "usage: DIAGSIZE=<value> CUT=<value> make makeMatrix"; \
		exit 1; \
	fi
	python3 matrix-creation/gen_mat.py $(DIAGSIZE) $(CUT) A_32K_64K.csv B_64K.csv

makedir:
	mkdir -p build

clean:
	rm -rf build
	rm -rf *.csv

