#!/bin/bash
#SBATCH --job-name=Robust_TE_denovo
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

GENOME=$1

# run RepeatModeler on GENOME
BuildDatabase -name rmdb_$GENOME -engine ncbi hq_genomes/$GENOME.fasta
RepeatModeler -engine ncbi -pa 24 -database rmdb_$GENOME -LTRStruct -ninja_dir /global/scratch/users/annen/NINJA-0.95-cluster_only/NINJA

# run IRF on GENOME
./irf307.exe hq_genomes/$GENOME.fasta 2 3 5 80 10 20 500000 10000 -a3 -t4 1000 -t5 5000 -h -d -ngs > irf_$GENOME.dat

# parse irf output into fasta format
awk 'BEGIN { count=0; } { if ($18 != "") { count++; print ">irf-" count "_left#DNA/IRF" "\n" $18 "\n" ">irf-" count "_right#DNA/IRF" "\n" $19 } }' irf_$GENOME.dat > irf_$GENOME.fasta

source deactivate