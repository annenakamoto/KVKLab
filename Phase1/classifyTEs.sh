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
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.60 --delta 10 --output LIB_DOM_60.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.65 --delta 10 --output LIB_DOM_65.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.66 --delta 10 --output LIB_DOM_66.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.67 --delta 10 --output LIB_DOM_67.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.68 --delta 10 --output LIB_DOM_68.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.70 --delta 10 --output LIB_DOM_70.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.80 --delta 10 --output LIB_DOM_80.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.85 --delta 10 --output LIB_DOM_85.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.90 --delta 10 --output LIB_DOM_90.clstr --threads 24 --align
#MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta.classified --id 0.95 --delta 10 --output LIB_DOM_95.clstr --threads 24 --align

# finds the classification for each cluster
#cat LIB_DOM_50.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_50.txt
#cat LIB_DOM_60.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_60.txt
#cat LIB_DOM_65.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_65.txt
#cat LIB_DOM_66.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_66.txt
#cat LIB_DOM_67.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_67.txt
#cat LIB_DOM_68.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_68.txt
#cat LIB_DOM_70.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_70.txt
#cat LIB_DOM_80.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_80.txt
#cat LIB_DOM_85.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_85.txt
#cat LIB_DOM_90.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_90.txt
#cat LIB_DOM_95.clstr | python KVKLab/Phase1/parse_classifyTEs.py > clust_class_95.txt

# just guy11 library for comparison
MeShClust/MeShClust-1.0.0/bin/meshclust guy11_LIB.fasta --id 0.50 --delta 10 --output guy11_LIB_50.clstr --threads 24 --align
cat guy11_LIB_50.clstr | python KVKLab/Phase1/parse_classifyTEs.py > guy11_clust_class_50.txt
#MeShClust/MeShClust-1.0.0/bin/meshclust guy11_LIB.fasta --id 0.50 --delta 10 --output guy11_LIB_50.clstr --threads 24 --align
#cat guy11_LIB_50.clstr | python KVKLab/Phase1/parse_classifyTEs.py > guy11_clust_class_50.txt

source deactivate
