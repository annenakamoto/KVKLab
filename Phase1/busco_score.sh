#!/bin/bash
#SBATCH --job-name=Robust_TE_library
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO

while read GENOME; do
    
    busco -i References/$GENOME.fasta -l fungi_odb10 -o busco_$GENOME -m genome -c 24 -f --out_path BUSCO_out

done < KVKLab/Phase1/robustTE_pipe_in.txt

source deactivate
