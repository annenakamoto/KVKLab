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

cd /global/scratch/users/annen/BUSCO_all_genomes
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO

# fungi_odb10 -> sordariomycetes_odb10    
busco -i /global/scratch/users/annen/ALL_GENOMES/$genome -l sordariomycetes_odb10 -o busco_$genome -m genome -c 24 -f --out_path BUSCO_out

#python3 anaconda3/envs/BUSCO/bin/generate_plot.py -wd BUSCO_sum

conda deactivate
