#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

working_dir=${1}    # ORTHOFINDER directory

cd ${working_dir}

### run orthofinder after parallel diamond blastp
orthofinder -os -M msa -A mafft -T fasttree -t ${SLURM_NTASKS} -a 5 -n out -b OrthoFinder_out/Results_out/WorkingDirectory

### MAKE GENOME TREE ###

