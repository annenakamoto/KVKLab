#!/bin/bash
#SBATCH --job-name=LTR_flank
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Follows rmask_LTR.sh: Find flanking LTRs for the high quality tree internal regions of MAGGY, GYPSY1, Copia, and MGRL3 LTRs

GENOME=$1

cd /global/scratch/users/annen/LTR_divergence

### use previous internal + flank bedfiles made (LTR.GENOME.flank.bed) in blast_LTR.sh and intersect with RepeatMasker output
### this will give flanking LTRs of each internal region
while read LTR; do
    while read GENOME; do
        bedtools intersect -a ${LTR}.${GENOME}.flank.bed -b RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed -wo > FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed
        cat FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed | awk -v OFS='\t' '{ print $7, $8, $9, $10, $11, $12 }' > FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.vis.bed # jsut for visualization
        ### filter LTRs
        > MAPPING/${LTR}.${GENOME}_mapping.txt
        cat FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed | python /global/scratch/users/annen/KVKLab/LTR_divergence/filterLTRs.py MAPPING/${LTR}.${GENOME}_mapping.txt > LTR_PAIRS_BED/${LTR}.${GENOME}.bed
        cat LTR_PAIRS_BED/${LTR}.${GENOME}.bed | while read line; do
            name=$(echo ${line} | awk '{ print $4 }')
            echo ${line} | awk -v OFS='\t' '{ print $1, $2, $3, $4, $5, $6 }' > ${name}.bed
            bedtools getfasta -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed ${name}.bed > LTR_PAIRS_FASTA/${GENOME}.${name}.fasta
            rm ${name}.bed
        done
    done < repgenome_list.txt
done < LTRs_ofinterest.txt

### find the divergence between LTR pairs
while read GENOME; do
    ls LTR_PAIRS_FASTA | grep ${GENOME} | awk '/a.fasta/' | while read a; do
        b=$(echo "${a::-7}b.fasta")
        needle -asequence LTR_PAIRS_FASTA/${a} -bsequence LTR_PAIRS_FASTA/${b} -outfile LTR_NEEDLE/${GENOME}.${a::-7}.needle
    done
done < repgenome_list.txt
