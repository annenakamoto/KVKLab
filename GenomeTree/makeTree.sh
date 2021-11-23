#!/bin/bash
#SBATCH --job-name=GenomeTree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make high quality genome tree

cd /global/scratch/users/annen/GENOME_TREE

#source activate /global/scratch/users/annen/anaconda3/envs/Biopython
#echo "*** Processing proteomes ***"
#cat PROTEOMES/genome_list.txt | python /global/scratch/users/annen/KVKLab/GenomeTree/process_faa_for_orthofinder.py
#echo "*** Done ***"
#conda deactivate

### Run OrthoFinder
source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
orthofinder -oa -f PROTEOMES_filt -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -o OrthoFinder_out
conda deactivate
