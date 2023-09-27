#!/bin/bash
#SBATCH --job-name=te_content_unfilt
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### compare TE content with/wothout filtering for TE domains

cd /global/scratch/users/annen/Rep_TE_Lib/RMask_out

GENOME=$1

source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

### run RepeatMasker on GENOME using REPLIB_clust.fasta, which is the TE library before domain filtering
#RepeatMasker -lib ../REPLIB_clust_noirf.fasta -dir RepeatMasker_out_rev -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc hq_genomes/$GENOME.fasta

### format element name
awk -v OFS='\t' '$1 ~ /^[0-9]+$/ && /\+/ { print $10 ":" $5 ":" $6 "-" $7 "(" $9 ")"; } 
                 $1 ~ /^[0-9]+$/ && !/\+/ { print $10 ":" $5 ":" $6 "-" $7 "(" $9 ")"; }' RepeatMasker_out_rev/$GENOME.fasta.out > RepeatMasker_out_rev/$GENOME.fasta.names

### count the number of each element
cat RepeatMasker_out_rev/$GENOME.fasta.names | python /global/scratch/users/annen/KVKLab/moryzae_tes/revisions/py_helpers/count_elems.py > RepeatMasker_out_rev/data_$GENOME.txt

### find the number of bp each element takes up
cat RepeatMasker_out_rev/$GENOME.fasta.names | python /global/scratch/users/annen/KVKLab/moryzae_tes/revisions/py_helpers/length_elems.py > RepeatMasker_out_rev/data_bp_$GENOME.txt


source deactivate