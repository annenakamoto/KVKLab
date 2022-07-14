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
> OG_${GENOME}.bed
while read line; do
    ### name to find gene in OG and SCO files
    name="gene_${c}_${GENOME}"
    ### write line with new genome name to file
    echo ${line} | awk -v N=${name} '$4 { print $1 "\t" $2 "\t" $3 "\t" N }' >> genes_${GENOME}.bed
    ((c+=1))
done < ${GENOME}.bed
