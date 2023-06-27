#!/bin/bash
#SBATCH --job-name=align_og
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### align genes within an orthogroup (OG) and make tree

working_dir=${1}    ## ORTHOFINDER directory for the species

cd ${working_dir}
mkdir -p OG_ALIGNMENTS

### align with mafft
prefix=OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences
ls ${prefix} | while read fa; do
    OG=$(echo ${fa} | awk '{ print substr($1,1,length($1)-3); }')
    echo "aligning ${OG}..."
    mafft --maxiterate 1000 --localpair --thread ${SLURM_NTASKS} --quiet ${prefix}/${OG}.fa > OG_ALIGNMENTS/${OG}.afa
    echo "done"
done
