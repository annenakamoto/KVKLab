#!/bin/bash
#SBATCH --job-name=syri_B71_EA18
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Align the chromosome level assemblies (EA18, B71, LpKY97, MZ5-1-6)

cd /global/scratch/users/annen/SV_B71_EA18
module load seqtk

# grep "chromosome" EA18.fasta | awk '{ print substr($1, 2)}' > EA18_chromnames.txt
# grep "chromosome" B71.fasta | awk '{ print substr($1, 2)}' > B71_chromnames.txt
# grep "chromosome" LpKY97.fasta | awk '!/Min/ { print substr($1, 2)}' > LpKY97_chromnames.txt
# grep "chromosome" MZ5-1-6.fasta | awk '{ print substr($1, 2)}' > MZ5-1-6_chromnames.txt

# seqtk subseq EA18.fasta EA18_chromnames.txt | seqtk rename - chr > EA18_chrom_only.fasta
# seqtk subseq B71.fasta B71_chromnames.txt | seqtk rename - chr > B71_chrom_only.fasta
# seqtk subseq LpKY97.fasta LpKY97_chromnames.txt | seqtk rename - chr > LpKY97_chrom_only.fasta
# seqtk subseq MZ5-1-6.fasta MZ5-1-6_chromnames.txt | seqtk rename - chr > MZ5-1-6_chrom_only.fasta

module purge
module load mummer
source activate /global/scratch/users/annen/anaconda3/envs/syri ## use source instead of conda

# nucmer --maxmatch -p EA18_v_B71_full -l 40 -g 90 -c 100 -b 200 -t 24 EA18_chrom_only.fasta B71_chrom_only.fasta
# delta-filter -m -i 90 -l 100 EA18_v_B71_full.delta > EA18_v_B71_full.filtered.delta
# show-coords -THrd EA18_v_B71_full.filtered.delta > EA18_v_B71_full.filtered.coords
# ~/syri/syri/bin/syri -c EA18_v_B71_full.filtered.coords -d EA18_v_B71_full.filtered.delta -r EA18_chrom_only.fasta -q B71_chrom_only.fasta --prefix EA18_v_B71 --nc 5 --all

# nucmer --maxmatch -p B71_v_LpKY97_full -l 40 -g 90 -c 100 -b 200 -t 24 B71_chrom_only.fasta LpKY97_chrom_only.fasta
# delta-filter -m -i 90 -l 100 B71_v_LpKY97_full.delta > B71_v_LpKY97_full.filtered.delta
# show-coords -THrd B71_v_LpKY97_full.filtered.delta > B71_v_LpKY97_full.filtered.coords
# ~/syri/syri/bin/syri -c B71_v_LpKY97_full.filtered.coords -d B71_v_LpKY97_full.filtered.delta -r B71_chrom_only.fasta -q LpKY97_chrom_only.fasta --prefix B71_v_LpKY97 --nc 5 --all

# nucmer --maxmatch -p LpKY97_v_MZ5-1-6_full -l 40 -g 90 -c 100 -b 200 -t 24 LpKY97_chrom_only.fasta MZ5-1-6_chrom_only.fasta
# delta-filter -m -i 90 -l 100 LpKY97_v_MZ5-1-6_full.delta > LpKY97_v_MZ5-1-6_full.filtered.delta
# show-coords -THrd LpKY97_v_MZ5-1-6_full.filtered.delta > LpKY97_v_MZ5-1-6_full.filtered.coords
# ~/syri/syri/bin/syri -c LpKY97_v_MZ5-1-6_full.filtered.coords -d LpKY97_v_MZ5-1-6_full.filtered.delta -r LpKY97_chrom_only.fasta -q MZ5-1-6_chrom_only.fasta --prefix LpKY97_v_MZ5-1-6 --nc 5 --all

nucmer --maxmatch -p B71_v_EA18_full -l 40 -g 90 -c 100 -b 200 -t 24 B71_chrom_only.fasta EA18_chrom_only.fasta
delta-filter -m -i 90 -l 100 B71_v_EA18_full.delta > B71_v_EA18_full.filtered.delta
show-coords -THrd B71_v_EA18_full.filtered.delta > B71_v_EA18_full.filtered.coords
~/syri/syri/bin/syri -c B71_v_EA18_full.filtered.coords -d B71_v_EA18_full.filtered.delta -r B71_chrom_only.fasta -q EA18_chrom_only.fasta --prefix B71_v_EA18 --nc 5 --all

conda deactivate
source activate /global/scratch/users/annen/anaconda3/envs/plotsr

# echo -e $(realpath EA18_chrom_only.fasta)"\t"EA18 > genomes_list
# echo -e $(realpath B71_chrom_only.fasta)"\t"B71 >> genomes_list
# echo -e $(realpath LpKY97_chrom_only.fasta)"\t"LpKY97 >> genomes_list
# echo -e $(realpath MZ5-1-6_chrom_only.fasta)"\t"MZ5-1-6 >> genomes_list

# plotsr --sr EA18_v_B71syri.out --sr B71_v_LpKY97syri.out --sr LpKY97_v_MZ5-1-6syri.out --genomes genomes_list -o EA18_B71_LpKY97_MZ5-1-6.png --tracks POT2.EA18.bed

echo -e $(realpath B71_chrom_only.fasta)"\t"B71 > genomes_list
echo -e $(realpath EA18_chrom_only.fasta)"\t"EA18 >> genomes_list

plotsr --sr B71_v_EA18syri.out --genomes genomes_list -o B71_v_EA18_w_POT2.png --tracks POT2.B71.chromnames.bed

conda deactivate
