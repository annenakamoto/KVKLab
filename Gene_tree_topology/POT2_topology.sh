#!/bin/bash
#SBATCH --job-name=POT2_topology
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Check for gene trees that follow a POT2 HT topology

cd /global/scratch/users/annen/treeKO_analysis
module unload python

source activate /global/scratch/users/annen/anaconda3/envs/treeKO   # to use ete2 python module

> POT2_topo.DATA.txt
ls ROOTED | while read TREE; do
    cat ROOTED/${TREE} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/is_POT2_topo.py ${TREE} >> POT2_topo.DATA.txt
    echo "*** finished ${TREE} ***"
done

conda deactivate
echo "*** DONE ***"
