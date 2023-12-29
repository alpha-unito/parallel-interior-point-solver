#!/bin/bash

# submit this job to a slurm managed node
# to generate all the matrices used for testing purpose

#SBATCH -N 1
#SBATCH --ntasks=80

# #SBATCH -o out1Node.log
# #SBATCH -e out1Node.err
#SBATCH -t 04:00:00
#SBATCH --mem=0

python3 gen_mat.py 100 10000 A_10_10K.csv B_10K.csv
python3 gen_mat.py 500 10000 A_50_10K.csv B_10K.csv
python3 gen_mat.py 1000  10000 A_100_10K.csv B_10K.csv
python3 gen_mat.py 2000  10000 A_200_10K.csv B_10K.csv
python3 gen_mat.py 3000  10000 A_300_10K.csv B_10K.csv
python3 gen_mat.py 4000  10000 A_400_10K.csv B_10K.csv
python3 gen_mat.py 5000  10000 A_500_10K.csv B_10K.csv
python3 gen_mat.py 6000  10000 A_600_10K.csv B_10K.csv
python3 gen_mat.py 7000  10000 A_700_10K.csv B_10K.csv
python3 gen_mat.py 8000  10000 A_800_10K.csv B_10K.csv

mv A_* matricesWS
mv B_* matricesWS


