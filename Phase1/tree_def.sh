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
# te_spec_lib.py reads from LIB_DOM_trans.fasta.classified
cat MUSCLE_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ":" $3 ; }' | python KVKLab/Phase1/te_spec_lib.py > MUSCLE_out/LIB_DOM_${TE}.fasta
echo "created library for ${TE}"

muscle -in MUSCLE_out/LIB_DOM_${TE}.fasta -out MUSCLE_out/${TE}_aligned.afa
echo "completed MSA for ${TE}"
