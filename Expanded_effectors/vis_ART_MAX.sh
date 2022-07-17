#!/bin/bash
#SBATCH --job-name=vis_ART_MAX
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make bed files of ART and MAX for each genome to visualize
### /global/scratch/users/annen/Expanded_effectors/GENE_BED/info_genes_${GENOME}.bed contains the locations of ART and MAX

cd /global/scratch/users/annen/Expanded_effectors

while read GENOME; do
    # ART bed
    cat GENE_BED/info_genes_${GENOME}.bed | awk -v OFS='\t' '$8 ~ "ART" { print $1, $2, $3, $4 "_" $8}' > ART_${GENOME}.bed
    # MAX bed
    cat GENE_BED/info_genes_${GENOME}.bed | awk -v OFS='\t' '$8 !~ "x" && $8 !~ "ART" { print $1, $2, $3, $4 "_" $8}' > MAX_${GENOME}.bed
done < rep_genome_list.txt

