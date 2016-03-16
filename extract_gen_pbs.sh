#!/bin/bash

#PBS -N extractdata
#PBS -o extractdata-output
#PBS -e extractdata-error
#PBS -t 1-23
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=2
#PBS -S /bin/bash

set -e

echo "Running on ${HOSTNAME}"

if [ -n "${1}" ]; then
  echo "${1}"
  PBS_ARRAYID=${1}
fi

i=${PBS_ARRAYID}

apps/gtool-0.7.5

genfile="/panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/genotypes/dosage/data_chr${i}"
samplefile="/panfs/panasas01/shared/alspac/studies/latest/alspac/genetic/variants/arrays/gwas/imputed/1000genomes/released/27Feb2015/data/data.sample"

# Change this file to point to where you want the results to go
outfile="${HOME}/results_chr${i}"

# Enter file with list of IDs to extract
keepids=""

# Enter file with list of SNPs to keep
keepsnps=""


gtool \
	--g ${genfile} \
	--s ${samplefile} \
	--inclusion ${keepsnps} \
	--sample_id ${keepids} \
	--og ${outfile} \
	--os ${outfile}.sample


# Note: change --inclusion flag to --exclusion to remove SNPs
#       change --sample_id to --sample_excl to remove IDs
#       change the #PBS -N, -o and -e flags to whatever names you want
