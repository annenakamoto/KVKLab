#!/bin/bash
#SBATCH --job-name=busco_phylo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### run busco phylogenomics to set up files for making a genome tree based on busco genes

working_dir=${1}
species=${2}        ## Species shorthand, ie. Mo, Zt, Sc, Nc

### setup: cd into working_dir, mkdir ${species}BUSCO and place the busco results dir for each genome in here

cd ${working_dir}

### run busco phylogenomics to generate supermatrix concatenated alignment
module purge
source activate /global/scratch/users/annen/anaconda3/envs/BUSCO_phylogenomics
python /global/scratch/users/annen/BUSCO_phylogenomics/BUSCO_phylogenomics.py -i BUSCO -o ${species}BUSCO_PHYLO -t ${SLURM_NTASKS} --supermatrix_only --gene_tree_program fasttree > BUSCO_phylogenomics.LOG.txt
conda deactivate

module load fasttreeMP
FastTreeMP -gamma -out ${species}.FASTTREE ${species}BUSCO_PHYLO/supermatrix/SUPERMATRIX.fasta

