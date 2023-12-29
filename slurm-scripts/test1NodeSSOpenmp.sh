#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=80

# #SBATCH -o out1Node.log
# #SBATCH -e out1Node.err
#SBATCH -t 06:00:00

source ~/.bashrc_slurm 

module load nvhpc-hpcx-cuda11/23.5

cd /beegfs/home/gmalenza/src/PhD/InteriorPointSolver/Giulio

mkdir StrongScalingMultiOpenMP
export OMP_NUM_THREADS=1

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_1TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_1TH

export OMP_NUM_THREADS=10

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_10TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_10TH

export OMP_NUM_THREADS=20

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_20TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_20TH

export OMP_NUM_THREADS=30

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_30TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_30TH


export OMP_NUM_THREADS=40

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_40TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_40TH

export OMP_NUM_THREADS=50

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_50TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_50TH

export OMP_NUM_THREADS=60

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_60TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_60TH

export OMP_NUM_THREADS=70

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_70TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_70TH

export OMP_NUM_THREADS=80

./KamarkarC++.Multi ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.MULTI_80TH
./KamarkarOpenMP.x ./matrices/A_4K_8K.csv ./matrices/B_8K.csv 4000 8000 10 0.0000001 > StrongScalingMultiOpenMP/log.OpenMP_80TH









