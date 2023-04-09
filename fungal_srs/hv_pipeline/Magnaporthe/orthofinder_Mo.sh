#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run OrthoFinder on Magnaporthe proteomes

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
module purge

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
orthofinder -os -f MoPROTEOMES -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -X -o OrthoFinder_out
conda deactivate
