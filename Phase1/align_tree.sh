#!/bin/bash
#SBATCH --job-name=Robust_TE_pipeline
#SBATCH --account=ac_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

#cd /global/scratch/users/annen/DeepTE-master
#source activate /global/scratch/users/annen/anaconda3/envs/DeepTE

#./DeepTE.py -i fngrep.fasta -sp F -m F #-prop_thr 0.9

#source deactivate

cd /global/scratch/users/annen

MeShClust/MeShClust-1.0.0/bin/meshclust LIB_DOM.fasta --id 0.40 --delta 10 --output LIB_DOM.clstr --threads 24 --align

# produce alignment of all the elements in LIB_DOM.fasta
#muscle -in LIB_DOM.fasta -maxiters 2 > LIB_DOM_align.fasta

# generate tree using RAXML
#raxml -s LIB_DOM_align.fasta -n raxml -m GTRCAT -f a -x 1123 -p 2341 -# 100
