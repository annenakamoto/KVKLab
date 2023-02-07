#!/bin/bash
#SBATCH --job-name=nucseq_TE_trees
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Make individual TE trees based on the nucleotide sequence of a domain

TE=$1   # RepBase element (ex. MAGGY)
DOM=$2  # pfam domain (ex. RVT_1)

source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

cd /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib

# Stockholm, Pfam, A2M, PSIBLAST
hmmalign --trim --amino --informat fasta -o ${TE}.${DOM}_align.a2m --outformat A2M ${DOM}.hmm REPHITS_${TE}_trans.fasta
echo "aligned ${DOM} in ${TE} TEs, output in A2M format"

hmmalign --trim --amino --informat fasta -o ${TE}.${DOM}_align.pfam --outformat Pfam ${DOM}.hmm REPHITS_${TE}_trans.fasta
echo "aligned ${DOM} in ${TE} TEs, output in Pfam format"

conda deactivate
