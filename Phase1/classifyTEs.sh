#!/bin/bash
#SBATCH --job-name=Robust_TE_library
#SBATCH --account=ac_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/

cat LIB_DOM.fasta | python KVKLab/Phase1/parse_classifyTEs.py > unique_classifications_RC.txt
