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

# create represenative RepBase element-specific library (ex. MAGGY library)
# te_spec_lib.py reads from LIB_DOM.fasta.classified (nucleotide)
cat MAFFT_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ; }' | python KVKLab/Phase1/te_spec_lib.py > MAFFT_out/LIB_DOM_${TE}.fasta
echo "created seq library for ${TE}"

cd /global/scratch/users/annen/MAFFT_out

mafft LIB_DOM_${TE}.fasta > ${TE}_aligned.afa
echo "completed MSA for ${TE}"

raxml -T 24 -n Raxml_${TE}.out -f a -x 12345 -p 12345 -# 100 -m GTRCAT -s ${TE}_aligned.afa
echo "ran RAXML for ${TE}"
