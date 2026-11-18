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
#SBATCH --job-name=bcf_norm
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=64
#SBATCH --mem=500G
#SBATCH --partition=highmem
#SBATCH --output=/path/to/workdir/logs/bcf_sort_out1
#SBATCH --error=/path/to/workdir/logs/bcf_sort_err1
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

DOWNSTREAM_DIR="/path/to/workdir/7_downstream"
REF="/path/to/workdir/0_reference/a55015_Genome.fasta"

# Script to run (srun -m command recommended by Pawsey to pack threads) 
module load bcftools/1.15--haf5b3da_0
#mkdir -p "${OUTPUT_DIR}"
bcftools norm \
    --threads 24 \
    -f "${REF}" \
    -m -any \
    "${DOWNSTREAM_DIR}/pang_others.vcf.gz" \
    -Oz \
    -o "${DOWNSTREAM_DIR}/pang_others.norm.vcf.gz"
bcftools sort \
    -Oz \
    -o "${DOWNSTREAM_DIR}/pang_others.norm.sorted.vcf.gz" \
    "${DOWNSTREAM_DIR}/pang_others.norm.vcf.gz"

tabix -f -p vcf \
    "${DOWNSTREAM_DIR}/pang_others.norm.sorted.vcf.gz"

bcftools stats \
    "${DOWNSTREAM_DIR}/pang_others.norm.sorted.vcf.gz" > "${DOWNSTREAM_DIR}/pang_others.norm.sorted_stats.txt"
