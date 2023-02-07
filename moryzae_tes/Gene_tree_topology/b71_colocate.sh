#!/bin/bash
#SBATCH --job-name=b71_colocate
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make a bed file to see if any genes with POT2 topology trees are colocated in B71
###     this might indicate larger region of recombination
### list of POT2 topo genes: /global/scratch/users/annen/treeKO_analysis/POT2_topo.B71.DATA.txt
### gene bedfile: /global/scratch/users/annen/Expanded_effectors/GENE_BED/genes_B71.bed

cd /global/scratch/users/annen

> treeKO_analysis/b71_POT2_topo.bed
cat treeKO_analysis/POT2_topo.B71.DATA.txt | awk '/POT2_topo/ { print $1; }' | while read gene; do
    grep ${gene} Expanded_effectors/GENE_BED/genes_B71.bed >> treeKO_analysis/b71_POT2_topo.bed
done

> treeKO_analysis/guy11_POT2_topo.bed
cat treeKO_analysis/POT2_topo.guy11.DATA.txt | awk '/POT2_topo/ { print $1; }' | while read gene; do
    grep ${gene} Expanded_effectors/GENE_BED/genes_guy11.bed >> treeKO_analysis/guy11_POT2_topo.bed
done


