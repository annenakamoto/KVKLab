#!/bin/bash
#SBATCH --job-name=syri_B71_EA18
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Make new domain based TE trees including the new genomes

cd /global/scratch/users/annen/SV_B71_EA18
module load seqtk

grep "chromosome" EA18.fasta | awk '{ print substr($1, 2)}' > EA18_chromnames.txt
grep "chromosome" B71.fasta | awk '{ print substr($1, 2)}' > B71_chromnames.txt

seqtk subseq EA18.fasta EA18_chromnames.txt | seqtk rename - chr > EA18_chrom_only.fasta
seqtk subseq B71.fasta B71_chromnames.txt | seqtk rename - chr > B71_chrom_only.fasta

module purge
module load mummer
source activate /global/scratch/users/annen/anaconda3/envs/syri ## use source instead of conda

nucmer --maxmatch -p EA18_v_B71_full -l 40 -g 90 -c 100 -b 200 -t 24 EA18_chrom_only.fasta B71_chrom_only.fasta
delta-filter -m -i 90 -l 100 EA18_v_B71_full.delta > EA18_v_B71_full.filtered.delta
show-coords -THrd EA18_v_B71_full.filtered.delta > EA18_v_B71_full.filtered.coords
~/syri/syri/bin/syri -c EA18_v_B71_full.filtered.coords -d EA18_v_B71_full.filtered.delta -r MZ5-1-6_chrom_only.fasta -q B71_chrom_only.fasta --nc 5 --all
