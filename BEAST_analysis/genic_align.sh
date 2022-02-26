#!/bin/bash
#SBATCH --job-name=genic_align
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make genic nucleotide alignment using SCOs (for BEAST)

cd /global/scratch/users/annen/GENOME_TREE 

### getfasta for the SCOs (one file for each SCO) and align them (into SCO_nuc_alignments)

### make SCO bedfiles for all the genomes and getfasta
# while read GENOME; do
#     cat GFF3/${GENOME}.gff3 | awk '$3 ~ /gene/ { print $1 "\t" $4 "\t" $5 "\t" substr($9, 4, 10) }' > GENE_BED/${GENOME}.bed
#     c=0
#     rm SCO_BED/*
#     while read line; do
#         ### name to find gene in OG and SCO files
#         name="gene_${c}_${GENOME}"
#         ### look for gene in Orthogroups
#         OG=$(grep ${name} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups.txt | awk -F ":" '{ print $1; }')
#         if [ ! -z "${OG}" ]; then
#             ### check if OG is a SCO
#             SCO=$(grep ${OG} /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups_SingleCopyOrthologues.txt)
#             if [ ! -z "${SCO}" ]; then
#                 ### add to SCO bed
#                 echo ${line} | awk -v og="${OG}_${GENOME}" '{ print $1 "\t" $2 "\t" $3 "\t" og; d}' >> SCO_BED/SCO_${GENOME}.bed
#             fi
#         fi
#         ((c+=1))
#     done < GENE_BED/${GENOME}.bed
#     bedtools getfasta -name+ -fo SCO_FASTA/SCO_${GENOME}.fasta -fi hq_genomes/${GENOME}.fasta -bed SCO_BED/SCO_${GENOME}.bed
# done < genome_list.txt

### rearrange the fasta files by SCO instead of by genome and align
while read SCO; do
    while read GENOME; do
        grep -A 1 ${SCO} SCO_FASTA/SCO_${GENOME}.fasta >> SCO_FASTA/${SCO}.fasta
    done  < genome_list.txt
    echo "***made ${SCO} SCO fasta***"
    mafft --maxiterate 1000 --globalpair --thread 24 SCO_FASTA/${SCO}.fasta > SCO_ALIGNMENTS/${SCO}.afa
    echo "***aligned ${SCO} SCO fasta***"
done < /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Nov22/Orthogroups/Orthogroups_SingleCopyOrthologues.txt

### align each SCO fasta file 

### concatenate all the SCO alignments and preprocess (this can go to BEAST analysis)

