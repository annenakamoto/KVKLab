#!/bin/bash
#SBATCH --job-name=Robust_TE_pipeline
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
#source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

# de novo repeat annotations for each genome
#delim=","
#while read GENOME; do
#    jid=$(sbatch KVKLab/Phase1/robustTE_denovo.sh $GENOME | cut -d ' ' -f4)$delim$jid
#done < KVKLab/Phase1/robustTE_pipe_in.txt
#echo $jid

# create the comprehensive repeat library
# get pfam domains and scan LIB.txt for HMM PFAM profile domains using pfam_scan.pl
# scan LIB.txt for CDD profile domains using RPS-BLAST
#sbatch --dependency=afterok:${jid%?} KVKLab/Phase1/robustTE_library.sh

# run RepeatMasker on all genomes using LIB_DOM.fasta and scan the output for domains
delim=","
while read GENOME; do
    jid=$(sbatch KVKLab/Phase1/robustTE_RMask.sh $GENOME | cut -d ' ' -f4)$delim$jid
done < KVKLab/Phase1/robustTE_pipe_in.txt
echo $jid

# add length, % length, and keywords columns to output using a python script (robustTE_cols.py)

# plot results in R
