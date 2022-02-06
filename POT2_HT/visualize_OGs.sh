#!/bin/bash
#SBATCH --job-name=vis_OGs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Visualize genome orthogroups, SCOs, AND Effectors!

GENOME=$1

### genomes in original .gff are of form gene_00001, gene_00002, etc.
### genomes in OG and SCO files are of form gene_0_guy11, gene_1_guy11, etc.
### want to change the gene names to their OGs, and indicate if they're SCOs and/or Effectors
###     gene_00001 -> gene_0_guy11 -> SCO_OG0000001_guy11
###     gene_00002 -> gene_1_guy11 -> OG0000002_guy11
###     gene_00003 -> gene_2_guy11 -> E_OG0000003_guy11
###     gene_00004 -> gene_3_guy11 -> E_SCO_OG0000004_guy11
###         etc... (these are just examples, not actual data)


#cat ${GENOME}.gff | awk '$3 ~ /gene/ { print $1 "\t" $4 "\t" $5 "\t" substr($9, 4, 10) }' > ${GENOME}.bed
cd /global/scratch/users/annen/visualize_OGs

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
            NEW_NAME1="SCO_${SCO}_${GENOME}"
        else
            NEW_NAME1="${OG}_${GENOME}"
        fi
    else
        NEW_NAME1=${name}
    fi
    ### look for name in list of effectors
    EFF=$(grep ${name} /global/scratch/users/annen/Effector_analysis/${GENOME}_effector_protein_names)
    if [ ! -z "${EFF}" ]; then
        NEW_NAME="E_${NEW_NAME1}"
    else
        NEW_NAME=${NEW_NAME1}
    fi

    ### write line with new genome name to file
    echo ${line} | awk -v N=${NEW_NAME} '$4 { print $1 "\t" $2 "\t" $3 "\t" N }' >> OG_${GENOME}.bed
    ((c+=1))
done < ${GENOME}.bed
