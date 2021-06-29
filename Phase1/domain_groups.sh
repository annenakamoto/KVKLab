#!/bin/bash
#SBATCH --job-name=domain_groups
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

# Translate CDD accession output into domain names
cat cdd_LIB_list.txt | python KVKLab/Phase1/cdd_to_name.py > cdd_LIB_list_N.txt



