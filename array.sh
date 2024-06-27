#!/bin/bash
#SBATCH --mem 70G
input=$1
i=$(sed -n -e "$SLURM_ARRAY_TASK_ID p" ${input} | awk -F"\t" '{print $1}')

outdir=${i}_fastq
mkdir -p ${outdir}
tmpdir=${outdir}/tmp
mkdir -p ${tmpdir}

parallel-fastq-dump --sra-id $i --threads 8 --outdir ${outdir} --split-files --gzip --tmpdir ${tmpdir}