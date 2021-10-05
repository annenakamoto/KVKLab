#!/bin/bash
#SBATCH --job-name=domseq_TE_trees
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Make individual TE trees based on the protein sequence of a domain

TE=$1   # RepBase element (ex. MAGGY)
DOM=$2  # pfam domain (ex. RVT_1)

source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

cd /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib

### Align domains using hmmalign
hmmalign --trim --amino --informat fasta -o ${TE}.${DOM}_align.sto ${DOM}.hmm /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta
echo "aligned ${DOM} in ${TE} TEs"

tr \: \# < ${TE}.${DOM}_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1${TE}.${DOM}.sto
echo "converted lower case characters (insertions) to gaps"
esl-reformat --mingap -o 2${TE}.${DOM}.fa afa 1${TE}.${DOM}.sto
echo "removed all-gap columns so that the number of columns matches HMM length"
leng=$(grep LENG ${DOM}.hmm | awk '{ print int($2*0.7) }')
esl-alimanip -o 1${TE}.${DOM}.fa --lmin $leng 2${TE}.${DOM}.fa
echo "trimmed sequences at minimum ~70% of the model"
esl-reformat -o 1${TE}.${DOM}.fa_align.Matches.${leng}min.fa afa 1${TE}.${DOM}.fa
echo "reformatted to fasta"

conda deactivate

cp 1${TE}.${DOM}.fa_align.Matches.${leng}min.fa /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs

cd /global/scratch/users/annen/Rep_TE_Lib/Align_domseq_TEs

echo "********* STARTING TO MAKE TREE *********"
raxml -T 24 -n Raxml_${TE}.${DOM}.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s 1${TE}.${DOM}.fa_align.Matches.${leng}min.fa
echo "ran RAXML for ${TE}.${DOM}"
