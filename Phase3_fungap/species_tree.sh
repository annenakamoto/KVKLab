#!/bin/bash
#SBATCH --job-name=species_tree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/OrthoFinder_species_tree
source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder2

orthofinder -t 24 -f OrthoFinder_in

conda deactivate
