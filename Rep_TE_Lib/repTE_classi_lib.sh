#!/bin/bash
#SBATCH --job-name=classify_lib
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Produce a new version of the TE library with all the individual TEs of interest classified
###     Uses manually curated text files of TE names (tree_${TE}.txt)
###     following method in Phase1/classi_lib.sh

cd /global/scratch/users/annen/Rep_TE_Lib/Classify_lib

> TE_name_map.txt
while read TE; do
    cat tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ; }' | python /global/scratch/users/annen/KVKLab/Phase1/rename_TE.py ${TE} >> TE_name_map.txt
done < TEs_of_intrest.txt

# reads from LIB_DOM.fasta.classified
cat TE_name_map.txt | python /global/scratch/users/annen/KVKLab/Phase1/rename_lib.py > REPLIB_CLASS.fasta
