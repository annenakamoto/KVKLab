#!/bin/bash
#SBATCH --job-name=GC_content
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     For plotting GC content in IGV in the representative genomes
###     usage: genomewide_GC.sh <GENOME>

GENOME=$1

cd  /global/scratch/users/annen/visualize_GC

### Generate chromosome length file
cat ${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > ${GENOME}.len

### Generate bed file with genome broken into intervals of 200 bp and make a fasta file
bedtools makewindows -g ${GENOME}.len -w 200 > ${GENOME}_windowed.bed
bedtools getfasta -name+ -fo ${GENOME}_windowed.fasta -fi ${GENOME}.fasta -bed ${GENOME}_windowed.bed

### Determine %GC content for each interval
geecee -sequence ${GENOME}_windowed.fasta -outfile RIP_analysis/gc_${GENOME}.txt

### Parse output into a bed file for IGV







