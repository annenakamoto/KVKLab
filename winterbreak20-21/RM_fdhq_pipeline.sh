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
    RepeatMasker -lib References/fng_guy11dn_noUN.fasta -dir RepeatMaskerOutput -gff -cutoff 250 -no_is -pa 24 hq_genomes/$genome.fasta
    
    # run python script on RM output, pipe to awk for filtering
    python KVKLab/winterbreak20-21/RM_fdhq_columns.py RepeatMaskerOutput/$genome.fasta.out | awk -v PIDENT=$PIDENT -v LENGTH=$LENGTH -v OFS='\t' '{ if (((100.0 - $4) >= PIDENT) && ($2 >= LENGTH)) { print } }' > RM_fdhq_filtered_$genome.txt

    # use awk to convert the filtered RM output to bed file
    awk -v OFS='\t' '{ print $7, $8, $9, $12 }' RM_fdhq_filtered_$genome.txt > RM_fdhq_filtered_$genome.bed

    # use awk to get data from filtered RM output
    awk -v genome=$genome 'BEGIN { count=0; LTR=0; NLTR=0; DNAT=0; UNKN=0; } 
        { count++; len+=$1; }
        { a[$12]++ }
        { b[$1]++ }
        / LTR Retrotransposon/ { LTR++ }
        /Non-LTR Retrotransposon/ { NLTR++ }
        /DNA transposon, T/ { DNAT++ }
        /, Unknown,/ { UNKN++ }
        END { print genome, "\nhits", "\t", count,
            "\nLTR Retrotransposons", "\t", LTR, "\nNon-LTR Retrotransposons", "\t", NLTR, "\nDNA Transposons", "\t", DNAT, "\nUnknown", "\t", UNKN;
            for (j in b) { print j, "\t", b[j] }
            for (i in a) { print i, "\t", a[i] } }' RM_fdhq_filtered_$genome.txt > RM_fdhq_data_$genome.txt

done < KVKLab/winterbreak20-21/RM_fdhq_in.txt

