#!/bin/bash -l

# Script for running parllel SLURM jobs using multithreaded programs on Pawsey Setonix (2022)
# Copyright statement: Copyright (c) 2022 Applied Bioinformatics Group, UWA, Perth WA, Australia
# See https://support.pawsey.org.au/documentation/display/US/Example+Workflows#ExampleWorkflows-ArraysorpackingofmanyjobsrequiringGPUs for more info on array scripts

# Available partitions on setonix:
##	Name	Time limit (h)	Cores/node	No. nodes	MEM/node (Gb)	Mem/core (Gb)	
## 	work	24		128		316		230		~2
## 	long	96		128		8		230		~2
##	highmem 24		128		8		980		~8
##	copy	24		64		8		118		~2
##	debug	1		128		8		230		~2

# User defined SLURM commands
#SBATCH --job-name=vg_calling
#SBATCH --array=2-419		#This should match the number of input files (0-4 means 5 input files)
#SBATCH --cpus-per-task=32	#CPUs per task (no. threads program uses) should be a multiple of 8
#SBATCH --time=05:00:00		#Time limit per parallel job
#SBATCH --partition=work
#SBATCH --output=/path/to/workdir/logs/pack-%j_job
#SBATCH --error=/path/to/workdir/logs/pack-%j_err

# Generic SLURM commands
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --clusters=<CLUSTER>
#SBATCH --account=<ACCOUNT>

source /path/to/groupResource.cfg
image="/path/to/vg_v1.77.0.sif"
home_dir="/path/to/fake-home"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
WORKDIR="/path/to/workdir"
INDEX_NUM=${SLURM_ARRAY_TASK_ID}

INDEX_DIR=$(printf "/path/to/workdir/1_index_pool/indexes_%d" "${INDEX_NUM}")


#---
echo "All jobs in this array have:"
echo "- SLURM_ARRAY_JOB_ID=${SLURM_ARRAY_JOB_ID}"
echo "- SLURM_ARRAY_TASK_COUNT=${SLURM_ARRAY_TASK_COUNT}"
echo "- SLURM_ARRAY_TASK_MIN=${SLURM_ARRAY_TASK_MIN}"
echo "- SLURM_ARRAY_TASK_MAX=${SLURM_ARRAY_TASK_MAX}"
  
echo "This job in the array has:"
echo "- SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "- SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"

#--- 
echo "Processing ${SAMPLE}"
echo "Using index copy: ${INDEX_DIR}" 
# ---
module load singularity/4.1.0-nompi
time srun -m block:block:block singularity exec \
	"${image}" \
    	vg pack \
    	-x "${INDEX_DIR}/index.giraffe.gbz" \
    	-g "${WORKDIR}/2_gam_files/${SAMPLE}.gam" \
	-Q 5 \
	-u \
	-o "${WORKDIR}/3_pack_files/${SAMPLE}.pack" \
    	-t "${SLURM_CPUS_PER_TASK}"
echo "Finishing packing"


