#!/bin/bash
#SBATCH --job-name=align_og
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### align genes within an orthogroup (OG)

working_dir=${1}    ## ORTHOFINDER directory for the species

cd ${working_dir}
mkdir -p OG_ALIGNMENTS
prefix=OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences

start=1             ## align all OGs if args 2 and 3 not specified
stop=$(ls ${prefix} | wc -l)
start=${2}          ## align OGs in index range start to stop, inclusive, if specified
stop=${3}

module purge
source activate /global/scratch/users/annen/anaconda3/envs/mafft

### align with mafft
ls ${prefix} | sed -n "${start},${stop}p" | while read fa; do
    OG=$(echo ${fa} | awk '{ print substr($1,1,length($1)-3); }')
    echo "aligning ${OG}..."
    mafft --maxiterate 1000 --localpair --thread ${SLURM_NTASKS} --quiet ${prefix}/${OG}.fa > OG_ALIGNMENTS/${OG}.afa
    echo "done"
done

conda deactivate
