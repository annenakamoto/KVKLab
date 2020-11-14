#!/bin/bash
#SBATCH --job-name=RM_pipeline
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
    RepeatMasker -lib References/fngrep.fasta -dir RepeatMaskerOutput -gff -cutoff 250 -no_is -pa 24 References/$genome.fasta
    echo "ran RepeatMasker"
    
    python KVKLab/miniproject4/RM_columns.py RepeatMaskerOutput/$genome.fasta.out | awk -v PIDENT=$PIDENT -v LENGTH=$LENGTH -v OFS='\t' '{ if (((100.0 - $4) >= PIDENT) && ($2 >= LENGTH)) { print } }' > RM_$genome_filtered.txt
    echo "ran python script and filtered with awk"

    # use awk to convert to bed file -> filtered output bed file
    awk -v OFS='\t' '{ print $7, $8, $9, $12 }' RM_$genome_filtered.txt > RM_$genome_filtered.bed

    # use awk to get data -> data text file
    awk -v genome=$genome 'BEGIN { count=0; } { count++ } END { print genome, "hits:", count; }' RM_$genome_filtered.txt > RM_$genome_data.txt

done < RM_pipe_in.txt

