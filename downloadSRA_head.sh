#!/bin/bash 
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jic118@ucsd.edu

input=/new-stg/home/jiarui/spectral_e/raw_file/lung_cancer/GSE211087_SRR_Acc_List.txt
script='array.sh'

N=5

# ### intersect
FILECOUNT=$(wc -l < "${input}")
if (( $FILECOUNT > ${N} )); then
  PARALLELJOBS=${N}
else
  PARALLELJOBS=$FILECOUNT
fi

ARRAYCOMMAND="1-${FILECOUNT}%${PARALLELJOBS}"
sbatch --wait -a $ARRAYCOMMAND ${script} ${input} 
wait 
