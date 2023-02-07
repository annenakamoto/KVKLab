#!/bin/bash
#SBATCH --job-name=GC_content
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Analyzing RIP using GC content

cd  /global/scratch/users/annen

# ### GC content for TEs
# while read TE; do
#     geecee -sequence /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta -outfile RIP_analysis/gc_${TE}.txt
#     avg=$(cat RIP_analysis/gc_${TE}.txt | awk 'BEGIN { n=0; s=0; } { n+=1; s+=$2; } END { print s/n }')
#     echo "$TE: $avg"
# done < TEs_list.txt

# ### GC content for genomes
# while read GENOME; do
#     geecee -sequence /global/scratch/users/annen/JC_gist_genomes/${GENOME}.cds.fasta -outfile RIP_analysis/gc_${GENOME}.txt
#     avg=$(cat RIP_analysis/gc_${GENOME}.txt | awk 'BEGIN { n=0; s=0; } { n+=1; s+=$2; } END { print s/n }')
#     echo "$GENOME: $avg"
# done < rep_genomes_list.txt

# > GC_data.txt
# while read TE; do
#     cat RIP_analysis/gc_${TE}.txt | awk -v TE=$TE '{ print TE "\t" $1 "\t" $2 }' >> GC_data.txt
# done < TEs_list.txt


### creating TE libraries using just guy11 and FJ98099
while read TE; do
    > Rep_TE_Lib/Align_TEs/SEASE_${TE}.fasta
    while read genome; do
        cat Rep_TE_Lib/RMask_out/${genome}.RM.filt.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/spec_te_hits.py $TE $genome >> Rep_TE_Lib/Align_TEs/SEASE_${TE}.fasta
    done < SEASE_genomes_list.txt
    echo "created RepeatMasker hits library for ${TE} from guy11 and FJ98099"
done < TEs_list.txt

### GC content for TEs
while read TE; do
    geecee -sequence /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/SEASE_${TE}.fasta -outfile RIP_analysis/Neg_control/gc_${TE}.txt
    avg=$(cat RIP_analysis/Neg_control/gc_${TE}.txt | awk 'BEGIN { n=0; s=0; } { n+=1; s+=$2; } END { print s/n }')
    echo "$TE: $avg"
done < TEs_list.txt

### GC content for genomes
while read GENOME; do
    geecee -sequence /global/scratch/users/annen/JC_gist_genomes/${GENOME}.cds.fasta -outfile RIP_analysis/Neg_control/gc_${GENOME}.txt
    avg=$(cat RIP_analysis/Neg_control/gc_${GENOME}.txt | awk 'BEGIN { n=0; s=0; } { n+=1; s+=$2; } END { print s/n }')
    echo "$GENOME: $avg"
done < SEASE_genomes_list.txt

> GC_NegCtrl_data.txt
while read TE; do
    cat RIP_analysis/Neg_control/gc_${TE}.txt | awk -v TE=$TE '{ print TE "\t" $1 "\t" $2 }' >> GC_NegCtrl_data.txt
done < TEs_list.txt
