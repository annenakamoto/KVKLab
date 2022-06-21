#!/bin/bash
#SBATCH --job-name=add_70-15
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run OrthoFinder, adding the 70-15 proteome (to get a mapping of MGG genes to my previous orthogroups)

cd /global/scratch/users/annen/GENOME_TREE

echo "*****START*****"
source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

### Previous orthofinder commands:
#orthofinder -fg OrthoFinder_out/Results_Nov22 -t 24 -a 5 -S diamond_ultra_sens
#orthofinder -oa -f PROTEOMES_filt -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -o OrthoFinder_out

### Use blast results from previous run and add the 70-15 proteome
orthofinder -b OrthoFinder_out/Results_Nov22 -f 70-15_PROTEOME -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -o OrthoFinder_70-15_out

conda deactivate
echo "*****DONE*****"
