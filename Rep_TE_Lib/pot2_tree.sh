#!/bin/bash
#SBATCH --job-name=pot2_tree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Produce tree for POT2 using more than just the representative genomes
###     Domain-based tree method

G=$1 # "2" or "A" (all)

cd /global/scratch/users/annen/Rep_TE_Lib

> Align_local/REPHITS_POT2_${G}.fasta
while read genome; do
    cat RMask_out/${genome}.RM.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/filt_te_hits.py RMask_out/${genome}.RM.uniq.txt > RMask_out/${genome}.RM.filt.fasta
    cat RMask_out/${genome}.RM.filt.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/spec_te_hits.py POT2 $genome >> Align_local/REPHITS_POT2_${G}.fasta
done < pot2_${G}_genome_list.txt 
echo "created RepeatMasker hits library for POT2, with 2 genomes from each lineage"

source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

cd /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib

translate -a -o REPHITS_POT2_${G}_trans.fasta /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_POT2_${G}.fasta

### Align domains using hmmalign and format output
hmmalign --trim --amino --informat fasta -o POT2_${G}.DDE_1_align.sto DDE_1.hmm REPHITS_POT2_${G}_trans.fasta
echo "aligned DDE_1 in POT2_2"
tr \: \# < POT2_${G}.DDE_1_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1POT2_${G}.DDE_1.sto
echo "converted lower case characters (insertions) to gaps"
esl-reformat --mingap -o 2POT2_${G}.DDE_1.fa afa 1POT2_${G}.DDE_1.sto
echo "removed all-gap columns so that the number of columns matches HMM length"
leng=$(grep LENG DDE_1.hmm | awk '{ print int($2*0.7) }')
esl-alimanip -o 1POT2_${G}.DDE_1.fa --lmin $leng 2POT2_${G}.DDE_1.fa
echo "trimmed sequences at minimum ~70% of the model"
esl-reformat -o 1POT2_${G}.DDE_1.fa_align.Matches.${leng}min.fa afa 1POT2_${G}.DDE_1.fa
echo "reformatted to fasta"

### get rid of illegal characters
cat 1POT2_${G}.DDE_1.fa_align.Matches.${leng}min.fa | tr \: \# | tr \( \{ | tr \) \} > POT2_${G}.DDE_1.fa_align.Matches.${leng}min.fa

conda deactivate
cp POT2_${G}.DDE_1.fa_align.Matches.${leng}min.fa /global/scratch/users/annen/Rep_TE_Lib/POT2_tree

cd /global/scratch/users/annen/Rep_TE_Lib/POT2_tree

echo "********* STARTING TO MAKE TREE *********"
raxml -T 24 -n Raxml_POT2_${G}.DDE_1.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s POT2_${G}.DDE_1.fa_align.Matches.${leng}min.fa
echo "ran RAXML for POT2_${G}.DDE_1"


