#!/bin/bash
#SBATCH --job-name=test_slurm_submission
#SBATCH --time=0:05:00
#SBATCH --output=test_slurm_submission.out
#SBATCH --partition=workq
#SBATCH --account=iidd
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem=4GB

module load cray-R
LD_LIBRARY_PATH=/home/jross/zeromq/lib Rscript test_clustermq_submission.R
