#!/bin/bash
#SBATCH --job-name=busco
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Re-making the comprehensive TE library with only the high quality representative genomes:
###     Oryza:		Guy11
###     Setaria:	US71
###     Leersia:	Lh88405
###     Triticum:	B71
###     Lolium:		LpKY97
###     Eleusine:	MZ5-1-6
### following method in Phase1/robustTE_library.sh

cd /global/scratch/users/annen/Rep_TE_Lib

### concatenate RepBase and de novo annotated TE libraries
cat fngrep.fasta > REPLIB_uncl.fasta

while read GENOME; do
    cat denovo_annot/rmdb_$GENOME-families.fasta >> REPLIB_uncl.fasta
done < rep_genome_list.txt

while read GENOME; do
    cat denovo_annot/irf_$GENOME.fasta >> REPLIB_uncl.fasta
done < rep_genome_list.txt

### run the library through CD-HIT

