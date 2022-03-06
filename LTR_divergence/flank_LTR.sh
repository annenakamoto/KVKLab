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

### use previous internal + flank bedfiles made (LTR.GENOME.flank.bed) in blash_LTR.sh and intersect with RepeatMasker output
### this will give flanking LTRs of each internal region
while read LTR; do
    while read GENOME; do
        bedtools intersect -a ${LTR}.${GENOME}.flank.bed -b RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed -wo > FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed
        ### filter LTRs
        > MAPPING/${LTR}.${GENOME}_mapping.txt
        cat FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed | python /global/scratch/users/annen/KVKLab/LTR_divergence/filterLTRs.py MAPPING/${LTR}.${GENOME}_mapping.txt > LTR_PAIRS_BED/${LTR}.${GENOME}.bed
    done < repgenome_list.txt
done < LTRs_ofinterest.txt



