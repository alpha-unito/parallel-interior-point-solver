# parallel-interior-point-solver

A parallel implementation for Karmarkar's interior point solver. This work has been presented at the 2024 edition of PDP (Parallel, Distributed and network based Processing)

# Interior point solver
A parallel implementation of Karmarkars's interior point method algorithm using OpenMP and CUDA. Developed by 
[Marco Edoardo Santimaria](https://alpha.di.unito.it/marco-santimaria/), [Samuele Fonio](https://alpha.di.unito.it/samuele-fonio/) and [Giulio Malenza](https://alpha.di.unito.it/giulio-malenza/)


## Usage
To compile the project you will need the following requirements:
- g++ >= 10
- Make
- (optional) CUDA if you plan to use NVIDIA GPU support

### Compile target
The Makefile has the following targets:
- cuda: build the project to run on cuda devices
- openmp: build the project to run on CPUs with OpenMP framework. This is also the target to run the single thread version of the software
- makeMatrix: This target uses python3 to generate random matrices to perform benchmarks. To use this target, you need to run the following command: `DIAGSIZE=<value> CUT=<value> make makeMatrix`, where DIAGSIZE is the number of columns and CUT is the number of rows
By default, Makefile will compile for bot cuda and openmp targets.


### Main binary usage:
Once compiled, inside `build/` there will be the main executables:
- if compiled with `cuda` target, the executable will be `build/Karmarkar.cuda`
- if compiled with `openmp` target, the executable will be `build/Karmarkar.openmp`

Both the executable have a common interface and the executable shall be run in the following way:

```build/Karmarkar.<target> [A matrix filename] [B vector filename] [A matrix Nrow] [A matrix Ncol] [maxIter] [tolerance]```

