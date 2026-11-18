#!/bin/bash -l

# Script for running SLURM jobs using multithreaded programs on Pawsey Setonix (2022)
# Copyright statement: Copyright (c) 2022 Applied Bioinformatics Group, UWA, Perth WA, Australia

# Available partitions:
##	Name	Time limit (h)	Cores/node	No. nodes	MEM/node (Gb)	Mem/core (Gb)	
## 	work	24		128		316		230		~2
## 	long	96		128		8		230		~2
##	highmem 24		128		8		980		~8
##	copy	24		64		8		118		~2
##	debug	1		128		8		230		~2

# User defined SLURM commands. #CPUS per task (no. threads program uses) should be a multiple of 8.
#SBATCH --job-name=phase_impute
#SBATCH --time=14:00:00
#SBATCH --cpus-per-task=112
#SBATCH --partition=work
#SBATCH --output=/path/to/workdir/logs/impute_out
#SBATCH --error=/path/to/workdir/logs/impute_err
#SBATCH --mail-user=

# Generic SLURM commands
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --clusters=<CLUSTER>
#SBATCH --account=<ACCOUNT>
#SBATCH --mail-type=ALL
#SBATCH --export=NONE 

# SLURM useful commands: sbatch, squeue, scancel
# Run this script using sbatch [slurm].sh

echo "========================================="
echo "SLURM_JOB_ID = $SLURM_JOB_ID"
echo "SLURM_NODELIST = $SLURM_NODELIST"
if [ ! -z $SLURM_ARRAY_TASK_ID ]; then
	echo "SLURM_ARRAY_TASK_ID = $SLURM_ARRAY_TASK_ID"
fi
echo "========================================="

OUT_DIR="/path/to/workdir/7_downstream"

# Script to run (srun -m command recommended by Pawsey to pack threads) 
time srun -m block:block:block java -Xmx200g -jar /path/to/beagle.jar \
    gt="${OUT_DIR}/pang_snps_mnps_indels_filtered.dedup.vcf.gz" \
    out="${OUT_DIR}/pang_snps_mnps_indels_filtered.phased" \
    ne=10000 \
    nthreads=112
