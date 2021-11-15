#!/bin/bash
#SBATCH --job-name=POT2_MUMmer
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Run MUMmer to find any POT2 + flanking sequences that have synteny
###     Generate fasta of these sequences for guy11, B71, and MZ5-1-6

GENOME=${1}     ### B71 or MZ5-1-6

cd /global/scratch/users/annen

### make chrom length file for slop
#cat JC_cons_genomes/${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > POT2_mummer/${GENOME}.len

### make bed file for slop
#cat JC_dist_indiv_TEs/POT2/POT2.${GENOME}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/make_bed.py > POT2_mummer/${GENOME}.POT2.bed

### Extract the POT2 + flanking sequences
#bedtools slop -i POT2_mummer/${GENOME}.POT2.bed -g POT2_mummer/${GENOME}.len -b 50000 > POT2_mummer/${GENOME}.POT2_flank.bed
#bedtools getfasta -s -name+ -fo POT2_mummer/${GENOME}.POT2_flank.fasta -fi JC_cons_genomes/${GENOME}.fasta -bed POT2_mummer/${GENOME}.POT2_flank.bed

### Run MUMmer
MUMmer/mummer-4.0.0rc1/nucmer -t 24 --maxmatch -p POT2_mummer/${GENOME}.guy11.POT2.mummer POT2_mummer/guy11.POT2_flank.fasta POT2_mummer/${GENOME}.POT2_flank.fasta
