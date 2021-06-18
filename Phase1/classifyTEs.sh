#!/bin/bash
#SBATCH --job-name=Robust_TE_library
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

# find clusters for general classification at 50% identity level
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.50 --delta 10 --output LIB_DOM_50.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.53 --delta 10 --output LIB_DOM_53.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.56 --delta 10 --output LIB_DOM_56.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.59 --delta 10 --output LIB_DOM_59.clstr --threads 24 --align

# finds the classification for each cluster
cat LIB_DOM_50.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_50.txt
#cat LIB_DOM_53.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_53.txt
#cat LIB_DOM_56.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_56.txt
#cat LIB_DOM_59.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_59.txt

source deactivate