#!/bin/bash 
#SBATCH --mem 90G
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jic118@ucsd.edu

# Mouse

inputpath=/new-stg/home/jiarui/spectral_e/raw_file/age_mouse/SRR24036956_fastq
refpath=/new-stg/home/jiarui/PROJECT/cellranger/opt/refdata-cellranger-arc-mm10-2020-A-2.0.0

cellranger-atac count --id=SRR24036956 \
                        --reference=$refpath \
                        --fastqs=$inputpath \
                        --description=18m_IL10plus_1 \
                        --localcores=8 \
                        --localmem=64


