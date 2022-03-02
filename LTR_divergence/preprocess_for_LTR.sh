#!/bin/bash
#SBATCH --job-name=LTR_preprocess
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Preprocess for annotating LTRs for LTR divergence analysis (for MAGGY, GYPSY1, Copia, and MGRL3)

cd /global/scratch/users/annen/LTR_divergence

### Filter REPHITS library of each TE to only include elements from the polished domain-based tree and make bedfiles
###     TE libraries are at /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta
###     TEs in high quality trees are at /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs/${TE}.${DOM}.fa_align.Matches.${leng}min.fa
echo "*** Making libraries of elements from polished domain based tree ***"

# MAGGY
echo "*** MAGGY ***"
> hq_REPHITS_MAGGY_I.fasta
> MAGGY_I.guy11.bed
> MAGGY_I.US71.bed
> MAGGY_I.B71.bed
> MAGGY_I.LpKY97.bed
> MAGGY_I.MZ5-1-6.bed
grep ">" /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs/MAGGY_I.RVT_1.fa_align.Matches.155min.fa | tr \# \:| tr \{ \( | tr \} \) | sort -u | awk '{ print substr($1, 1, length($1)-2) }' | while read line; do
    grep -A 1 ${line} /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_MAGGY_I.fasta >> hq_REPHITS_MAGGY_I.fasta
    genome=$(echo ${line} | awk -v FS=":" '{ print $4 }')
    echo ${line} | python /global/scratch/users/annen/KVKLab/LTR_divergence/name2bed.py >> MAGGY_I.${genome}.bed
done

# # GYPSY1
# echo "*** GYPSY1 ***"
# > hq_REPHITS_GYPSY1_MG.fasta
# > GYPSY1_MG.guy11.bed
# > GYPSY1_MG.US71.bed
# > GYPSY1_MG.B71.bed
# > GYPSY1_MG.LpKY97.bed
# > GYPSY1_MG.MZ5-1-6.bed
# grep ">" /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs/GYPSY1_MG.RVT_1.fa_align.Matches.155min.fa | tr \# \:| tr \{ \( | tr \} \) | awk '{ print substr($1, 1, length($1)-2) }' | while read line; do
#     grep -A 1 ${line} /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_GYPSY1_MG.fasta >> hq_REPHITS_GYPSY1_MG.fasta
#     genome=$(echo ${line} | awk -v FS=":" '{ print $4 }')
#     echo ${line} | python /global/scratch/users/annen/KVKLab/LTR_divergence/name2bed.py >> GYPSY1_MG.${genome}.bed
# done

# # Copia
# echo "*** Copia ***"
# > hq_REPHITS_Copia_elem.fasta
# > Copia_elem.guy11.bed
# > Copia_elem.US71.bed
# > Copia_elem.B71.bed
# > Copia_elem.LpKY97.bed
# > Copia_elem.MZ5-1-6.bed
# grep ">" /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs/Copia_elem.RVT_2.fa_align.Matches.170min.fa | tr \# \:| tr \{ \( | tr \} \) | awk '{ print substr($1, 1, length($1)-2) }' | while read line; do
#     grep -A 1 ${line} /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_Copia_elem.fasta >> hq_REPHITS_Copia_elem.fasta
#     genome=$(echo ${line} | awk -v FS=":" '{ print $4 }')
#     echo ${line} | python /global/scratch/users/annen/KVKLab/LTR_divergence/name2bed.py >> Copia_elem.${genome}.bed
# done

# # MGRL3
# echo "*** MGRL3 ***"
# > hq_REPHITS_MGRL3_I.fasta
# > MGRL3_I.guy11.bed
# > MGRL3_I.US71.bed
# > MGRL3_I.B71.bed
# > MGRL3_I.LpKY97.bed
# > MGRL3_I.MZ5-1-6.bed
# grep ">" /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs/MGRL3_I.rve.fa_align.Matches.71min.fa | tr \# \:| tr \{ \( | tr \} \) | awk '{ print substr($1, 1, length($1)-2) }' | while read line; do
#     grep -A 1 ${line} /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_MGRL3_I.fasta >> hq_REPHITS_MGRL3_I.fasta
#     genome=$(echo ${line} | awk -v FS=":" '{ print $4 }')
#     echo ${line} | python /global/scratch/users/annen/KVKLab/LTR_divergence/name2bed.py >> MGRL3_I.${genome}.bed
# done

