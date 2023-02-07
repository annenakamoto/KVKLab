#!/bin/bash
#SBATCH --job-name=soloLTRs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find soloLTRs to calculate LTR removal intensity

cd /global/scratch/users/annen/SOLO_LTRs

###  Find solo LTRs by using all TE hits (not domain-based tree filtered) and all LTR hits (from LTR divergence analysis)
###  fasta files for all TEs are at: /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta (need to convert to bed file)
###  bedfiles for all LTRs are at: /global/scratch/users/annen/LTR_divergence/RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed
while read LTR; do
    while read GENOME; do
        # make all TEs bedfile for LTR in genome
        #cat /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${LTR}.fasta | python /global/scratch/users/annen/KVKLab/soloLTR_analysis/tobed.py ${GENOME} > REPHITS/REPHITS.${GENOME}.${LTR}.bed
        
        # find solo LTRs
        # -v: Only report those entries in A that have no overlap in B.
        #bedtools intersect -v -a /global/scratch/users/annen/LTR_divergence/RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed -b REPHITS/REPHITS.${GENOME}.${LTR}.bed > UNNAMED_SOLOS/${LTR}.${GENOME}.unnamed.solo.bed
        #cat UNNAMED_SOLOS/${LTR}.${GENOME}.unnamed.solo.bed | python /global/scratch/users/annen/KVKLab/soloLTR_analysis/name_solos.py ${LTR} > NEW_SOLOS/${LTR}.${GENOME}.solo.bed

        # find flanking LTRs
        # -wo: 	Write the original A and B entries plus the number of base pairs of overlap between the two features. Only A features with overlap are reported. Restricted by -f and -r.
        #bedtools intersect -wo -a /global/scratch/users/annen/LTR_divergence/RM_LTR_BED_FASTA/${GENOME}.${LTR}_LTR.bed -b REPHITS/REPHITS.${GENOME}.${LTR}.bed > UNNAMED_FLANK/${LTR}.${GENOME}.unnamed.flank.bed
        > NEW_MAPPING/${LTR}.${GENOME}.mapping.txt
        cat UNNAMED_FLANK/${LTR}.${GENOME}.unnamed.flank.bed | python /global/scratch/users/annen/KVKLab/soloLTR_analysis/name_flank.py ${LTR} "NEW_MAPPING/${LTR}.${GENOME}.mapping.txt" > NEW_FLANK/${LTR}.${GENOME}.flank.bed

    done < repgenome_list.txt
done < LTRs_ofinterest.txt