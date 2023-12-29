#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks=80
#SBATCH --cpus-per-task=1
# Number of GPUs per node
#SBATCH --gres=gpu:1

# #SBATCH -o out1Node.log
# #SBATCH -e out1Node.err
#SBATCH -t 04:00:00
#SBATCH --mem=0

source ~/.bashrc_slurm 

module load nvhpc-hpcx-cuda11/23.5

cd /beegfs/home/gmalenza/src/PhD/InteriorPointSolver/Giulio


./KamarkarC++.x ./matrices/A_1K_2K.csv ./matrices/B_2K.csv 1000 2000 10 0.0000001 > log.1K_2K_C++
./KamarkarC++.cuda ./matrices/A_1K_2K.csv ./matrices/B_2K.csv 1000 2000 10 0.0000001 > log.1K_2K_CUDA

./KamarkarC++.x ./matrices/A_2K_4K.csv ./matrices/B_4K.csv 2000 4000 10 0.0000001 > log.2K_4K_C++
./KamarkarC++.cuda ./matrices/A_2K_4K.csv ./matrices/B_4K.csv 2000 4000 10 0.0000001 > log.2K_4K_CUDA

./KamarkarC++.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > log.4K_8K_C++
./KamarkarC++.cuda ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > log.4K_8K_CUDA

./KamarkarC++.x ./matrices/A_8K_16K.csv ./matrices/B_16K.csv 8000 16000 10 0.0000001 > log.8K_16K_C++
./KamarkarC++.cuda ./matrices/A_8K_16K.csv ./matrices/B_16K.csv 8000 16000 10 0.0000001 > log.8K_16K_CUDA

./KamarkarC++.x ./matrices/A_16K_32K.csv ./matrices/B_32K.csv 16000 32000 10 0.0000001 > log.16K_32K_C++
./KamarkarC++.cuda ./matrices/A_16K_32K.csv ./matrices/B_32K.csv 16000 32000 10 0.0000001 > log.16K_32K_CUDA

./KamarkarC++.x ./matrices/A_16K_64K.csv ./matrices/B_64K.csv 16000 64000 10 0.0000001 > log.16K_64K_C++
./KamarkarC++.cuda ./matrices/A_16K_64K.csv ./matrices/B_64K.csv 16000 64000 10 0.0000001 > log.16K_64K_CUDA

./KamarkarC++.x ./matrices/A_32K_64K.csv ./matrices/B_64K.csv 32000 64000 10 0.0000001 > log.32K_64K_C++
./KamarkarC++.cuda ./matrices/A_32K_64K.csv ./matrices/B_64K.csv 32000 64000 10 0.0000001 > log.32K_64K_CUDA



