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

while read GENOME; do
    sbatch -W KVKLab/Phase1/robustTE_denovo.sh $GENOME
done < KVKLab/Phase1/robustTE_pipe_in.txt
wait

# combine RepeatModleler, IRF, and RepBase (References/fngrep.fasta) libraries
cat References/fngrep.fasta > unclib.fasta
while read GENOME; do
    cat unclib.fasta rmdb_$GENOME-families.fa > unclib_$GENOME.fasta
done < KVKLab/Phase1/robustTE_pipe_in.txt

while read GENOME; do
    cat unclib.fasta irf_$GENOME.fasta > unclib_$GENOME.fasta
done < KVKLab/Phase1/robustTE_pipe_in.txt

# run CD-HIT to remove repeats, obtain high quality comprehensive TE library
cd-hit-est -i unclib.fasta -o clustlib.fasta -c 1.0 -aS 0.99 -g 1 -d 0 -T 24

# parse the clustered library to prioritize RepBase, RepeatModeler, then IRF to be the representative element
awk 'BEGIN { max=0; clust=0; }
    />Cluster/ { max=0; clust=$2 }
    !/>irf-|>Cluster/ { if(substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
    />irf-/ && /\*/ { if(max==0) {  max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
    END { for(i in a) { print a[i]; } }' clustlib.fasta.clstr | python KVKLab/Phase1/robustTE_prioritize.py unclib.fasta > LIB.fasta


# scan library for HMM PFAM profile domains using pfam_scan.pl
# scan library for CDD profile domains using RPS-BLAST

# run RepeatMasker on GENOME using high quality TE library that was scanned for domains
#RepeatMasker -lib <domain-scanned lib> -dir robustTE_RepeatMaskerOut -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc hq_genomes/$GENOME.fasta

# scan output for HMM PFAM profile domains using pfam_scan.pl
# scan output for CDD profile domains using RPS-BLAST
# add length, % length, and keywords columns to output using a python script (robustTE_cols.py)

# plot results in R

source deactivate
