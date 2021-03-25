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
source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

delim=","
while read GENOME; do
    jid=$jid$delim$(sbatch KVKLab/Phase1/robustTE_denovo.sh $GENOME | cut -d ' ' -f4)
done < KVKLab/Phase1/robustTE_pipe_in.txt
echo $jid

sbatch --dependency=afterok:$jid KVKLab/Phase1/robustTE_library.sh

# run RepeatMasker on GENOME using high quality TE library that was scanned for domains
#RepeatMasker -lib <domain-scanned lib> -dir robustTE_RepeatMaskerOut -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc hq_genomes/$GENOME.fasta

# scan output for HMM PFAM profile domains using pfam_scan.pl
# scan output for CDD profile domains using RPS-BLAST
# add length, % length, and keywords columns to output using a python script (robustTE_cols.py)

# plot results in R

source deactivate
