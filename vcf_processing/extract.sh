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
#SBATCH --job-name=bcf_extract
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=24
#SBATCH --partition=work
#SBATCH --output=/path/to/workdir/logs/bcf_extract_out
#SBATCH --error=/path/to/workdir/logs/bcf_extract_err
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

INPUT_DIR="/path/to/workdir/6_output"
OUTPUT_DIR="/path/to/workdir/7_downstream"

# Script to run (srun -m command recommended by Pawsey to pack threads) 
module load bcftools/1.15--haf5b3da_0
#mkdir -p "${OUTPUT_DIR}"

bcftools view \
    -v snps,mnps,indels \
    --threads 24 \
    "${INPUT_DIR}/pangenome_variants.vcf.gz" \
    -Oz \
    -o "${OUTPUT_DIR}/pang_snps_mnps_indels.vcf.gz"

tabix -f -p vcf "${OUTPUT_DIR}/pang_snps_mnps_indels.vcf.gz"

# Quick check
bcftools stats "${OUTPUT_DIR}/pang_snps_mnps_indels.vcf.gz" > "${OUTPUT_DIR}/pang_snps_mnps_indels_stats.txt"
