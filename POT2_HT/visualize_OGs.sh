#!/bin/bash
#SBATCH --job-name=vis_OGs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Visualize genome orthogroups and SCOs

GENOME=$1

### genomes in original .gff are of form gene_00001, gene_00002, etc.
### genomes in OG and SCO files are of form gene_0_guy11, gene_1_guy11, etc.
###     gene_00001 -> gene_0_guy11
###     gene_00002 -> gene_1_guy11
###         etc...

#cat ${GENOME}.gff | awk '$3 ~ /gene/ { print $1 "\t" $4 "\t" $5 "\t" substr($9, 4, 10) }' > ${GENOME}.bed

c=0
> OG_${GENOME}.bed
while read line; do
    ### name to find gene in OG and SCO files
    name="gene_${c}_${GENOME}"
    ### look for gene in Orthogroups
    OG=$(grep ${name} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups.txt | awk -F ":" '{ print $1; }')
    if [ ! -z "${OG}" ]; then
        ### check if OG is a SCO
        SCO=$(grep ${OG} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups_SingleCopyOrthologues.txt)
        if [ ! -z "${SCO}" ]; then
            NEW_NAME="SCO_${SCO}_${genome}"
        else
            NEW_NAME="${OG}_${genome}"
        fi
    else
        NEW_NAME=${name}
    fi
    ### write line with new genome name to file
    echo ${line} | awk -v N=${NEW_NAME} '$4 { print $1 "\t" $2 "\t" $3 "\t" N }' >> OG_${GENOME}.bed
    ((c+=1))
done < ${GENOME}.bed
