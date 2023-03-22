#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoGENOMES_all

source activate /global/scratch/users/annen/anaconda3/envs/
datasets download genome taxon 'Pyricularia oryzae' --include genome --assembly-source GenBank
conda deactivate


