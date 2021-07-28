#!/bin/bash
#SBATCH --job-name=tree_msa
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/

TE=$1   # RepBase element (ex. MAGGY)
mode=$2 # nucleotide or protein library

# create represenative RepBase element-specific library (ex. MAGGY library)
# te_spec_lib.py reads from LIB_DOM_trans.fasta.classified or LIB_DOM.fasta.classified
if [ $mode = "protein" ]; then
cat MUSCLE_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ":" $3 ; }' | python KVKLab/Phase1/te_spec_lib.py ${mode} > MUSCLE_out/LIB_DOM_${TE}_${mode}.fasta
fi
if [ $mode = "nucleotide" ]; then
cat MUSCLE_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ; }' | python KVKLab/Phase1/te_spec_lib.py ${mode} | tr \: \# > MUSCLE_out/LIB_DOM_${TE}_${mode}.fasta
fi
echo "created ${mode} seq library for ${TE}"

muscle -in MUSCLE_out/LIB_DOM_${TE}_${mode}.fasta -out MUSCLE_out/${TE}_aligned_${mode}.afa
echo "completed ${mode} MSA for ${TE}"

cd /global/scratch/users/annen/MUSCLE_out

raxml -T 24 -n Raxml_${TE}_${mode}.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s ${TE}_aligned_${mode}.afa
echo "ran RAXML for ${mode} ${1}"
