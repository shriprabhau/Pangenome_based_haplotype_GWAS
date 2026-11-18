#!/bin/bash

#SBATCH --job-name=rename_vcf
#SBATCH --array=1-419
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00
#SBATCH --partition=work
#SBATCH --output=/path/to/workdir/logs/rename-%A_%a.out
#SBATCH --error=/path/to/workdir/logs/rename-%A_%a.err

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --clusters=<CLUSTER>
#SBATCH --account=<ACCOUNT>

set -euo pipefail

module load bcftools/1.15--haf5b3da_0

WORKDIR="/path/to/workdir"

VCFDIR="${WORKDIR}/4_vcfs"
OUTDIR="${WORKDIR}/5_renamed_vcfs"
TMPDIR_LOCAL="${WORKDIR}/tmp_reheader"

mkdir -p "${OUTDIR}"
mkdir -p "${TMPDIR_LOCAL}"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)

echo "================================="
echo "Job ID: ${SLURM_JOB_ID}"
echo "Array ID: ${SLURM_ARRAY_TASK_ID}"
echo "Sample: ${SAMPLE}"
echo "================================="

INPUT_VCF="${VCFDIR}/${SAMPLE}.vcf"
INPUT_GZ="${VCFDIR}/${SAMPLE}.vcf.gz"

# Compress if not already compressed
if [ -f "${INPUT_VCF}" ] && [ ! -f "${INPUT_GZ}" ]; then
    echo "Compressing ${INPUT_VCF}"
    bgzip -c "${INPUT_VCF}" > "${INPUT_GZ}"
fi

# Index original compressed VCF
tabix -f -p vcf "${INPUT_GZ}"

# Create sample rename file
RENAME_FILE="${TMPDIR_LOCAL}/rename_${SLURM_ARRAY_TASK_ID}.txt"

printf "SAMPLE\t%s\n" "${SAMPLE}" > "${RENAME_FILE}"

echo "Renaming sample from SAMPLE to ${SAMPLE}"

bcftools reheader \
    -s "${RENAME_FILE}" \
    "${INPUT_GZ}" \
    -o "${OUTDIR}/${SAMPLE}.vcf.gz"

# Index renamed VCF
tabix -f -p vcf "${OUTDIR}/${SAMPLE}.vcf.gz"

echo "Checking sample name:"
bcftools query -l "${OUTDIR}/${SAMPLE}.vcf.gz"

rm -f "${RENAME_FILE}"

echo "Finished ${SAMPLE}"
