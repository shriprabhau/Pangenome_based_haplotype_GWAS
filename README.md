# Pangenome variant calling, haplotype clustering and GWAS

Short-read variant calling against a graph pangenome (minigraph-cactus), haplotype clustering of SNPs + InDels, and GWAS on SNPs vs haplotypes. Developed on *B. napus* (418 accessions) on a SLURM cluster.

## Pipeline

| Step | Dir | Tools |
|---|---|---|
| 1. Trim (fastp), map, pack, call, rename samples | `variant_calling` | fastp, vg giraffe/pack/call (v1.77.0), bcftools reheader |
| 2. Merge, extract SNPs/MNPs/InDels, norm, dedup, MAF/missingness filter, phase/impute | `vcf_processing` | bcftools, BEAGLE |
| 3. Haplotype clustering | `haplotype_clustering` | HaploVar (Nextflow) |
| 4. GWAS (SNPs and haplotypes): `data_prep.R` then `rmvp_run.R` (GLM, MLM, FarmCPU) | `GWAS` | rMVP |

Run order within a dir follows the table; scripts are SLURM jobs (`sbatch`), `samples.txt` drives the array jobs (line N = array task N).

## Notes
- Paths are placeholders (`/path/to/...`, `<ACCOUNT>`, `<CLUSTER>`); set them before running. `module load` lines and `partition` names are cluster-specific.
- Graph indexes are copied per array task (`copy_index.sh`) to avoid I/O contention.
- No data in the repo (see `.gitignore`).
