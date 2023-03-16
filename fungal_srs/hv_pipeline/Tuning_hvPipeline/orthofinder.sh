#!/bin/bash
#SBATCH --job-name=mmseqs_Zm
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
orthofinder -oa -f OrthoFinder_in -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -o OrthoFinder_out
conda deactivate
