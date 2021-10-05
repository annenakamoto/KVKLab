#!/bin/bash
#SBATCH --job-name=jukes_cantor
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### find Jukes-Cantor distances

NUM=$1    ### first argument is the number of sequences in fasta file
FASTA=$2  ### second argument is the path to fasta file

source activate /global/scratch/users/annen/anaconda3/envs/biopython

python KVKLab/Jukes-Cantor/jc_dist_BOYAN.py $NUM $FASTA

conda deactivate
