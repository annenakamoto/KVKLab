#!/bin/bash
#SBATCH --job-name=needle_ART_MAX
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### generate fasta files for ART & MAX effector nucleotide sequences

cd /global/scratch/users/annen/Expanded_effectors
