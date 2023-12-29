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

mkdir WeakScalingMultiOpenMP
rm WeakScalingMultiOpenMP/*

export OMP_NUM_THREADS=1

./KamarkarC++.Multi ./matricesWS/A_10_10K.csv ./matricesWS/B_10K.csv 100 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_1TH
./KamarkarOpenMP.x ./matricesWS/A_10_10K.csv ./matricesWS/B_10K.csv 100 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_1TH

export OMP_NUM_THREADS=5

./KamarkarC++.Multi ./matricesWS/A_50_10K.csv ./matricesWS/B_10K.csv 500 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_5TH
./KamarkarOpenMP.x ./matricesWS/A_50_10K.csv ./matricesWS/B_10K.csv 500 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_5TH

export OMP_NUM_THREADS=10

./KamarkarC++.Multi ./matricesWS/A_100_10K.csv ./matricesWS/B_10K.csv 1000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_10TH
./KamarkarOpenMP.x ./matricesWS/A_100_10K.csv ./matricesWS/B_10K.csv 1000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_10TH

export OMP_NUM_THREADS=20

./KamarkarC++.Multi ./matricesWS/A_200_10K.csv ./matricesWS/B_10K.csv 2000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_20TH
./KamarkarOpenMP.x ./matricesWS/A_200_10K.csv ./matricesWS/B_10K.csv 2000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_20TH

export OMP_NUM_THREADS=30
./KamarkarC++.Multi ./matricesWS/A_300_10K.csv ./matricesWS/B_10K.csv 3000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_30TH
./KamarkarOpenMP.x ./matricesWS/A_300_10K.csv ./matricesWS/B_10K.csv 3000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_30TH

export OMP_NUM_THREADS=40
./KamarkarC++.Multi ./matricesWS/A_400_10K.csv ./matricesWS/B_10K.csv 4000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_40TH
./KamarkarOpenMP.x ./matricesWS/A_400_10K.csv ./matricesWS/B_10K.csv 4000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_40TH

export OMP_NUM_THREADS=50
./KamarkarC++.Multi ./matricesWS/A_500_10K.csv ./matricesWS/B_10K.csv 5000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_50TH
./KamarkarOpenMP.x ./matricesWS/A_500_10K.csv ./matricesWS/B_10K.csv 5000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_50TH

export OMP_NUM_THREADS=60
./KamarkarC++.Multi ./matricesWS/A_600_10K.csv ./matricesWS/B_10K.csv 6000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_60TH
./KamarkarOpenMP.x ./matricesWS/A_600_10K.csv ./matricesWS/B_10K.csv 6000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_60TH

export OMP_NUM_THREADS=70
./KamarkarC++.Multi ./matricesWS/A_700_10K.csv ./matricesWS/B_10K.csv 7000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_70TH
./KamarkarOpenMP.x ./matricesWS/A_700_10K.csv ./matricesWS/B_10K.csv 7000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_70TH

export OMP_NUM_THREADS=80
./KamarkarC++.Multi ./matricesWS/A_800_10K.csv ./matricesWS/B_10K.csv 8000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.MULTI_80TH
./KamarkarOpenMP.x ./matricesWS/A_800_10K.csv ./matricesWS/B_10K.csv 8000 10000 10 0.0000001 > WeakScalingMultiOpenMP/log.OpenMP_80TH





