#!/bin/bash
#SBATCH --job-name=Robust_TE_library
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO

#while read GENOME; do
    
#    busco -i hq_genomes/$GENOME.fasta -l fungi_odb10 -o busco_$GENOME -m genome -c 24 -f --out_path BUSCO_out

#done < KVKLab/Phase1/robustTE_pipe_in.txt

python3 anaconda3/envs/BUSCO/bin/generate_plot.py -wd BUSCO_sum

source deactivate
