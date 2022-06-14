#!/bin/bash
#SBATCH --job-name=soloLTRs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find soloLTRs to calculate LTR removal intensity (NO GOOD, use soloLTR_analysys.sh)

cd /global/scratch/users/annen/SOLO_LTRs

### use previous internal + flank bedfiles made (LTR.GENOME.flank.bed) in blast_LTR.sh and intersect with RepeatMasker output
### this will give flanking LTRs of each internal region (will include ones with a flanking LTR on only one side)
while read LTR; do
    while read GENOME; do
        # find flanking LTRs
        > MAPPING/${LTR}.${GENOME}_mapping.txt
        cat /global/scratch/users/annen/LTR_divergence/FLANKING_LTR_BED/${LTR}.${GENOME}.LTR_flank.bed | python /global/scratch/users/annen/KVKLab/soloLTR_analysis/not_soloLTRs.py MAPPING/${LTR}.${GENOME}_mapping.txt > FLANKING_LTR_BED/${LTR}.${GENOME}.flank.bed
        # find solo LTRs (remove flanking), bedfiles for all LTRs are at: /global/scratch/users/annen/LTR_divergence/RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed
        # -v: Only report those entries in A that have no overlap in B
        bedtools intersect -v -a /global/scratch/users/annen/LTR_divergence/RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed -b FLANKING_LTR_BED/${LTR}.${GENOME}.flank.bed > SOLO_LTR_BED/${LTR}.${GENOME}.solo.unnamed.bed
        # remane solo LTRs
        cat SOLO_LTR_BED/${LTR}.${GENOME}.solo.unnamed.bed | python /global/scratch/users/annen/KVKLab/soloLTR_analysis/name_solos.py ${LTR} > NAMED_SOLO_LTR_BED/${LTR}.${GENOME}.solo.bed
    done < repgenome_list.txt
done < LTRs_ofinterest.txt


