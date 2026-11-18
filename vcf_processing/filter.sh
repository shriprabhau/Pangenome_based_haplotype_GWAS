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
#SBATCH --job-name=bcffilter
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=24
#SBATCH --partition=work
#SBATCH --output=/path/to/workdir/logs/bcf_filter_out
#SBATCH --error=/path/to/workdir/logs/bcf_filter_err
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

DOWNSTREAM_DIR="/path/to/workdir/7_downstream"

echo "========================================="
echo "SLURM_JOB_ID = $SLURM_JOB_ID"
echo "SLURM_NODELIST = $SLURM_NODELIST"
if [ ! -z $SLURM_ARRAY_TASK_ID ]; then
	echo "SLURM_ARRAY_TASK_ID = $SLURM_ARRAY_TASK_ID"
fi
echo "========================================="

# Script to run (srun -m command recommended by Pawsey to pack threads) 
module load bcftools/1.15--haf5b3da_0
time srun -m block:block:block bcftools view \
	--threads 24 \
	-i 'MAF>=0.05 && F_MISSING<=0.10' \
	"${DOWNSTREAM_DIR}/pang_snps_mnps_indels.norm.sorted.clean.tags.vcf.gz" \
	-Oz \
	-o "${DOWNSTREAM_DIR}/pang_snps_mnps_indels_filtered.vcf.gz"

tabix -f -p vcf "${DOWNSTREAM_DIR}/pang_snps_mnps_indels_filtered.vcf.gz"
bcftools view -H \
	    "${DOWNSTREAM_DIR}/pang_snps_mnps_indels_filtered.vcf.gz" \
	    | wc -l

bcftools stats \
    "${DOWNSTREAM_DIR}/pang_snps_mnps_indels_filtered.vcf.gz" \
    > "${DOWNSTREAM_DIR}/pang_snps_mnps_indels_filtered_stats.txt"
