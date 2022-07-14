#!/bin/bash
#SBATCH --job-name=vis_genes
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Visualize genes, with effector info

GENOME=$1

### genomes in original .gff are of form gene_00001, gene_00002, etc.
### genomes in OG and SCO files are of form gene_0_guy11, gene_1_guy11, etc.
### want to change the gene names to their OGs, and indicate if they're SCOs and/or Effectors
###     gene_00001 -> gene_0_guy11 -> SCO_OG0000001_guy11
###     gene_00002 -> gene_1_guy11 -> OG0000002_guy11
###     gene_00003 -> gene_2_guy11 -> E_OG0000003_guy11
###     gene_00004 -> gene_3_guy11 -> E_SCO_OG0000004_guy11
###         etc... (these are just examples, not actual data)

cd /global/scratch/users/annen
cat visualize_OGs/${GENOME}.gff | awk '$3 ~ /gene/ { print $1 "\t" $4 "\t" $5 "\t" substr($9, 4, 10) }' > Expanded_effectors/GENE_BED/${GENOME}.bed

cd /global/scratch/users/annen/Expanded_effectors/GENE_BED

c=0
> genes_${GENOME}.bed
while read line; do
    ### name to find gene in OG and SCO files
    name="gene_${c}_${GENOME}"
    ### write line with new genome name to file
    echo ${line} | awk -v N=${name} '$4 { print $1 "\t" $2 "\t" $3 "\t" N }' >> genes_${GENOME}.bed
    ((c+=1))
done < ${GENOME}.bed

> info_genes_${GENOME}.bed
echo -e "chr\tstart\tend\tgene\tEFF\tMGG_orthogroup\tSCO" >> info_genes_${GENOME}.bed  ### col names
while read line; do
    name=$(echo line | awk '{ print $4 }')
    ### determine if the gene is a predicted effector
    EFF=$(grep ${name} /global/scratch/users/annen/Effector_analysis/${GENOME}_effector_protein_names)
    if [ ! -z "${EFF}" ]; then
        EFF_col="EFF"
    else
        EFF_col="x"
    fi
    ### determine the orthogroup the gene is in, using orthogroups with MGG reference genes
    OG=$(grep ${name} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups.txt | awk -F ":" '{ print $1; }')
    ### determine if the orthogroup is a SCO in this orthofinder run
    SCO=$(grep ${OG} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jul13/Orthogroups/Orthogroups_SingleCopyOrthologues.txt)
    if [ ! -z "${SCO}" ]; then
        SCO_col="SCO"
    else
        SCO_col="x"
    fi
    echo -e "${line}\t${EFF_col}\t${OG}\t${SCO_col}" >> info_genes_${GENOME}.bed
done < genes_${GENOME}.bed
