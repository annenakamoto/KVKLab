#!/bin/bash
#SBATCH --job-name=orthofinder_blast
#SBATCH --partition=savio3
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

cd ${SLURM_SUBMIT_DIR}

module purge

export PERL5LIB=''

parallel -j ${SLURM_NTASKS} < jobqueue_${node}
