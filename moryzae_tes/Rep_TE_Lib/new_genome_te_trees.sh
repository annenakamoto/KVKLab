#!/bin/bash
#SBATCH --job-name=new_TE_dom_trees
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Make new domain based TE trees including the new genomes

TE=$1   # RepBase element (ex. MAGGY)
DOM=$2  # pfam domain (ex. RVT_1)
LST=$3  # list of genomes


cd /global/scratch/users/annen/Rep_TE_Lib

> NEW_GENOMES/REPHITS_${TE}.fasta
while read genome; do
    cat RMask_out/${genome}.RM.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/filt_te_hits.py RMask_out/${genome}.RM.uniq.txt > RMask_out/${genome}.RM.filt.fasta
    cat RMask_out/${genome}.RM.filt.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/spec_te_hits.py $TE $genome >> NEW_GENOMES/REPHITS_${TE}.fasta
done < ${LST}
echo "created RepeatMasker hits library for ${TE}"


source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

cd /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib

translate -a -o REPHITS_${TE}_trans.fasta /global/scratch/users/annen/Rep_TE_Lib/NEW_GENOMES/REPHITS_${TE}.fasta

### Align domains using hmmalign and format output
hmmalign --trim --amino --informat fasta -o ${TE}.${DOM}_align.sto ${DOM}.hmm REPHITS_${TE}_trans.fasta
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

### get rid of illegal characters
cat 1${TE}.${DOM}.fa_align.Matches.${leng}min.fa | tr \: \# | tr \( \{ | tr \) \} > ${TE}.${DOM}.fa_align.Matches.${leng}min.fa

conda deactivate
cp ${TE}.${DOM}.fa_align.Matches.${leng}min.fa /global/scratch/users/annen/Rep_TE_Lib/NEW_TE_TREES

cd /global/scratch/users/annen/Rep_TE_Lib/NEW_TE_TREES

echo "********* STARTING TO MAKE TREE *********"
raxmlHPC-PTHREADS-SSE3 -T 24 -n Raxml_${TE}.${DOM}.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s ${TE}.${DOM}.fa_align.Matches.${leng}min.fa
echo "ran RAXML for ${TE}.${DOM}"