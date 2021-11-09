#!/bin/bash
#SBATCH --job-name=visualize_TEs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Generate bed files to visualize TE position and JC distance

cd /global/scratch/users/annen/visualize_TEs

while read TE; do
    cat ${TE}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/visualize.py ${TE}.filt.JC.out.txt > ${TE}.bed
done < TE_list.txt
