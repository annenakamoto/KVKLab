#!/bin/bash
#SBATCH --job-name=gene_dist_TE
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### generate fasta files for ART & MAX effector nucleotide sequences

cd /global/scratch/users/annen/Expanded_effectors

while read GENOME; do
    ### make ART fasta
    echo "*** making ART fasta for ${GENOME} ***"
    cat GENE_BED/info_genes_${GENOME}.bed | awk -v OFS='\t' '/gene/&&/ART/ { print $1, $2, $3, $4 ":" $8; }' > tmp.${GENOME}.ART.bed
    bedtools getfasta -name -s -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -fo FASTA/${GENOME}.ART.fasta -bed tmp.${GENOME}.ART.bed
    rm tmp.${GENOME}.ART.bed
    ### make MAX fasta
    echo "*** making MAX fasta for ${GENOME} ***"
    cat GENE_BED/info_genes_${GENOME}.bed | awk -v OFS='\t' '(/MAX/||/AVR/||/TOX/)&&/gene/ { print $1, $2, $3, $4 ":" $8; }' > tmp.${GENOME}.MAX.bed
    bedtools getfasta -name -s -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -fo FASTA/${GENOME}.MAX.fasta -bed tmp.${GENOME}.MAX.bed
    rm tmp.${GENOME}.MAX.bed
done < genome_list.txt

