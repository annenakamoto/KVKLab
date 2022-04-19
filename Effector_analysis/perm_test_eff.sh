#!/bin/bash
#SBATCH --job-name=permut_test_eff
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run permutation tests on the Effector Distances to TEs data
###     uses python script for permutation tests

cd /global/scratch/users/annen/TE_dist_Eff

> perm_test_results.txt
while read GENOME; do
    while read TE; do
        /global/scratch/users/annen/KVKLab/Effector_analysis/perm_test.py ${TE} ${GENOME} TEs_eff.${GENOME}.DATA.txt ${TE}_eff.${GENOME}.DATA.txt >> perm_test_results.txt
    done < te_list.txt 
done < genome_list.txt
