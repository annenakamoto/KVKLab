#!/bin/bash
#SBATCH --job-name=busco_Mo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder

module purge
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO_phylogenomics
python ../../BUSCO_phylogenomics/BUSCO_phylogenomics.py -i MoBUSCO -o MoBUSCO_PHYLO -t 24 --supermatrix_only --gene_tree_program fasttree
conda deactivate

