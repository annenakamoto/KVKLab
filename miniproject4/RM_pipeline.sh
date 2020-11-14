#!/bin/bash
#SBATCH --job-name=guy11_repeat
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/

PIDENT=$1
LENGTH=$2

while read genome; do

    # run RepeatMasker -> python script to add columns -> awk filtering -> filtered output file
    RepeatMasker -lib References/fngrep.fasta -dir . -gff -cutoff 250 -no_is -pa 24 References/$genome.fasta
    echo "ran RepeatMasker"
    
    python2 KVKLab/miniproject4/RM_columns.py $genome.fasta.out | awk -v OFS='\t' '{ if ((100.0 - $2 >= $PIDENT) && ($17 >= $LENGTH)) { print } }' > RM_filtered_$genome.txt
    echo "ran python script and filtered with awk"

    # use awk to convert to bed file -> filtered output bed file
    awk -v OFS='\t' '{ print $5, $6, $7, $10 }' RM_filtered_$genome.txt > RM_filtered_$genome.bed

    # use awk to get data -> data text file
    #awk ...
    #> RM_data_$genome.txt

done < RM_pipe_in.txt

