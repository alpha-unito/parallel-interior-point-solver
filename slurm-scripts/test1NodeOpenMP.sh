#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=80

# #SBATCH -o out1Node.log
# #SBATCH -e out1Node.err
#SBATCH -t 04:00:00

source ~/.bashrc_slurm 

module load nvhpc-hpcx-cuda11/23.5

cd /beegfs/home/gmalenza/src/PhD/InteriorPointSolver/Giulio

mkdir scalingMultiOpenMP
export OMP_NUM_THREADS=80

./KamarkarC++.Multi ./matrices/A_1K_2K.csv ./matrices/B_2K.csv 1000 2000 10 0.0000001 > scalingMultiOpenMP/log.1K_2K_C++Multi
./KamarkarOpenMP.x ./matrices/A_1K_2K.csv ./matrices/B_2K.csv 1000 2000 10 0.0000001 > scalingMultiOpenMP/log.1K_2K_OpenMP

./KamarkarC++.Multi ./matrices/A_2K_4K.csv ./matrices/B_4K.csv 2000 4000 10 0.0000001 > scalingMultiOpenMP/log.2K_4K_C++Multi
./KamarkarOpenMP.x ./matrices/A_2K_4K.csv ./matrices/B_4K.csv 2000 4000 10 0.0000001 > scalingMultiOpenMP/log.2K_4K_OpenMP

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > scalingMultiOpenMP/log.4K_8K_C++Multi
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > scalingMultiOpenMP/log.4K_8K_OpenMP

./KamarkarC++.Multi ./matrices/A_8K_16K.csv ./matrices/B_16K.csv 8000 16000 10 0.0000001 > scalingMultiOpenMP/log.8K_16K_C++Multi
./KamarkarOpenMP.x ./matrices/A_8K_16K.csv ./matrices/B_16K.csv 8000 16000 10 0.0000001 > scalingMultiOpenMP/log.8K_16K_OpenMP

./KamarkarC++.Multi ./matrices/A_16K_32K.csv ./matrices/B_32K.csv 16000 32000 10 0.0000001 > scalingMultiOpenMP/log.16K_32K_C++Multi
./KamarkarOpenMP.x ./matrices/A_16K_32K.csv ./matrices/B_32K.csv 16000 32000 10 0.0000001 > scalingMultiOpenMP/log.16K_32K_OpenMP







