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
source activate RepeatModeler

GENOME=$1

# run RepeatModeler on GENOME
BuildDatabase -name GENOME_rmdb -engine ncbi GENOME.fasta
RepeatModeler -engine ncbi -pa 24 -database GENOME_rmdb

# run IRF on GENOME

# combine RepeatModleler, IRF, and RepBase libraries
# run CD-HIT to remove repeats, obtain high quality TE library for GENOME

# run RepeatMasker on GENOME using high quality TE library
#RepeatMasker -lib <high quality TE library> -dir robustTE_RepeatMaskerOut -gff -cutoff 250 -no_is -nolow -pa 24 hq_genomes/GENOME.fasta

# scan output for HMM PFAM profile domains using pfam_scan.pl
# scan output for CDD profile domains using RPS-BLAST
# add length, % length, and keywords columns to output using a python script (robustTE_cols.py)

# plot results in R

source deactivate
