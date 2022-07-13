#!/bin/bash
#SBATCH --job-name=ART_MAX_pav
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Determine PAV of ART and MAX effectors in M. oryzae genomes of different lineages

cd /global/scratch/users/annen/Expanded_effectors

> ART_MAX_pav.DATA.txt
> ART_MAX_pav.copynum.DATA.txt
while read g; do
    MGG=$(echo ${g} | awk '{ print $1 }')
    GROUP=$(echo ${g} | awk '{ print $2 }')
    ### columns: Group, OG, 70-15_gene, guy11_gene, etc.
    grep ${MGG} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups.txt | python /global/scratch/users/annen/KVKLab/Expanded_effectors/pav_line.py ${GROUP} "names" > ART_MAX_pav.DATA.txt
    grep ${MGG} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups.txt | python /global/scratch/users/annen/KVKLab/Expanded_effectors/pav_line.py ${GROUP} "num" > ART_MAX_pav.copynum.DATA.txt
done < ART_MAX_list.txt

