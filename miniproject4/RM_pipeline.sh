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

    # run RepeatMasker
    RepeatMasker -lib References/fngrep.fasta -dir RepeatMaskerOutput -gff -cutoff 250 -no_is -pa 24 References/$genome.fasta
    echo "ran RepeatMasker"
    
    # fun python script on RM output, pipe to awk for filtering
    python KVKLab/miniproject4/RM_columns.py RepeatMaskerOutput/$genome.fasta.out | awk -v PIDENT=$PIDENT -v LENGTH=$LENGTH -v OFS='\t' '{ if (((100.0 - $4) >= PIDENT) && ($2 >= LENGTH)) { print } }' > RM_filtered_$genome.txt
    echo "ran python script and filtered with awk"

    # use awk to convert the filtered RM output to bed file
    awk -v OFS='\t' '{ print $7, $8, $9, $12 }' RM_filtered_$genome.txt > RM_filtered_$genome.bed

    # use awk to get data from filtered RM output
    awk -v genome=$genome 'BEGIN { count=0; length=0; LTR=0; NLTR=0; DNAT=0 } 
        { count++; length += $1 }
        / LTR Retrotransposon/ { LTR++ }
        /Non-LTR Retrotransposon/ { NLTR++ }
        /DNA transposon, T/ { DNAT++ }
        END { print genome, '\n', "hits:", count, '\t', "total transposon length:", length, '\n',
            "LTR Retrotransposons:", LTR, '\n', "Non-LTR Retrotransposons:", NLTR, '\n', "DNA Transposons:", DNAT; }' RM_filtered_$genome.txt > RM_data_$genome.txt

done < RM_pipe_in.txt

