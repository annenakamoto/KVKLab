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

# make file containing the orthogroup + tree of genes that follow POT2 HT topology (based on closest distance within tree between B71 and guy11 genes)
> POT2_topo.DATA.txt
ls ROOTED | while read TREE; do
    cat ROOTED/${TREE} | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/is_POT2_topo.py ${TREE} >> POT2_topo.DATA.txt
    echo "*** finished ${TREE} ***"
done

conda deactivate
echo "*** DONE ***"

# make file for plotting distance and permutation tests
> POT2_topo.guy11.DATA.txt
cat /global/scratch/users/annen/treeKO_analysis/gene_POT2.guy11.DATA.txt | while read line; do
    match=$(grep $(echo ${line} | awk '{ print $4 }') POT2_topo.DATA.txt)
    if [ -z "${match}" ]; then
        # empty
        echo ${line} | awk -v OFS='\t' '{ print $1, $2, $3, $4, $5, $6, "x" }' >> POT2_topo.guy11.DATA.txt
    else
        echo ${line} | awk -v OFS='\t' '{ print $1, $2, $3, $4, $5, $6, "POT2_topo" }' >> POT2_topo.guy11.DATA.txt
    fi
done

> POT2_topo.B71.DATA.txt
cat /global/scratch/users/annen/treeKO_analysis/gene_POT2.B71.DATA.txt | while read line; do
    match=$(grep $(echo ${line} | awk '{ print $4 }') POT2_topo.DATA.txt)
    if [ -z "${match}" ]; then
        # empty
        echo ${line} | awk -v OFS='\t' '{ print $1, $2, $3, $4, $5, $6, "x" }' >> POT2_topo.B71.DATA.txt
    else
        echo ${line} | awk -v OFS='\t' '{ print $1, $2, $3, $4, $5, $6, "POT2_topo" }' >> POT2_topo.B71.DATA.txt
    fi
done

