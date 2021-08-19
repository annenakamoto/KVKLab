#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

genome=$1

cd /global/scratch/users/annen/
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO
    
busco -i ALL_GENOMES/$genome -l fungi_odb10 -o busco_$genome -m genome -c 24 -f --out_path BUSCO_all_genomes

#python3 anaconda3/envs/BUSCO/bin/generate_plot.py -wd BUSCO_sum

source deactivate
