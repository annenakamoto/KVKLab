#!/bin/bash
#SBATCH --job-name=of_jobqueue
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### started by run_of_parallel_blast.sh, uses jobqueue to parallelize blast searches

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

cd ${SLURM_SUBMIT_DIR}

module purge

export PERL5LIB=''

module load parallel
parallel -j ${SLURM_NTASKS} < jobqueue_${node}
