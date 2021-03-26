#!/bin/bash
#SBATCH --job-name=Robust_TE_library
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

# combine RepeatModleler, IRF, and RepBase (References/fngrep.fasta) libraries
cat References/fngrep.fasta > unclib.fasta
while read GENOME; do
    cat rmdb_$GENOME-families.fasta >> unclib.fasta
done < KVKLab/Phase1/robustTE_pipe_in.txt

while read GENOME; do
    cat irf_$GENOME.fasta >> unclib.fasta
done < KVKLab/Phase1/robustTE_pipe_in.txt

# run CD-HIT to remove repeats, obtain high quality comprehensive TE library
cd-hit-est -i unclib.fasta -o clustlib.fasta -c 1.0 -aS 0.99 -g 1 -d 0 -T 24

# parse the clustered library to prioritize RepBase, RepeatModeler, then IRF to be the representative element
awk 'BEGIN { max=0; clust=0; rb=0; }
    />Cluster/ { max=0; rb=0; clust=$2 }
    !/>irf-|>ltr-|>rnd-|>Cluster/ { if(substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3); rb=1 } }
    />ltr-/ || />rnd-/ { if(max==0 || rb==0 && substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
    />irf-/ && /\*/ { if(max==0) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
    END { for(i in a) { print a[i]; } }' clustlib.fasta.clstr > LIB_list.txt # | python KVKLab/Phase1/robustTE_prioritize.py unclib.fasta > LIB.fasta


# scan library for HMM PFAM profile domains using pfam_scan.pl
# scan library for CDD profile domains using RPS-BLAST

source deactivate