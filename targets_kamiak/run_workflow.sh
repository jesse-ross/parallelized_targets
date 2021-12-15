#!/bin/bash
#SBATCH --partition=cahnrs         ### Partition (like a queue in PBS)
#SBATCH --job-name=targets_test    ### Job Name
#SBATCH -o targets_test.out          ### File in which to store job output
#SBATCH --time=7-00:00:00          ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1                  ### Node count required for the job
#SBATCH --ntasks-per-node=1        ### Number of tasks to be launched per Node
#SBATCH --cpus-per-task=1         ### Number of threads per task (OMP threads)
#SBATCH --mail-type=ALL # Email notification: BEGIN,END,FAIL,ALL
#SBATCH --mail-user=matthew.brousil@wsu.edu # Email address for notifications
#SBATCH --get-user-env             ### Import your user environment setup
#SBATCH --verbose                  ### Increase informational messages
#SBATCH --mem=2048          ### Amount of memory in MB

# Load R on compute node
module load r/4.0.2

# Working dir
echo $PWD

echo "Run script run_workflow.R"

Rscript --vanilla run_workflow.R
