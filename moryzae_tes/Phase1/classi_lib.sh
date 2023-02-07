#!/bin/bash
#SBATCH --job-name=classi_lib
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/

> TE_name_map.txt
while read TE; do
    cat MAFFT_out/tree_${TE}.txt | awk ' BEGIN { FS="#" } { gsub(/ /, "_"); print $1 "#" $2 ; }' | python KVKLab/Phase1/rename_TE.py ${TE} >> TE_name_map.txt
done < TEs_of_intrest.txt

# reads from LIB_DOM.fasta.classified
cat TE_name_map.txt | python KVKLab/Phase1/rename_lib.py > LIB_DOM_part_class.fasta
