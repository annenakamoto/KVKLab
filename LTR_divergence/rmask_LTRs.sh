#!/bin/bash
#SBATCH --job-name=LTR_rmask
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Follows align_LTR.sh: Run RepeatMasker on representative genomes using new library including MAGGY, GYPSY1, Copia, and MGRL3 LTRs

GENOME=$1

cd /global/scratch/users/annen/LTR_divergence

### add LTRs to library for ReapeatMasker
#cat *cons* /global/scratch/users/annen/Rep_TE_Lib/REPLIB_CLASS.fasta > LTR_REPLIB_CLASS.fasta

### Run RepeatMasker using LTR_REPLIB_CLASS.fasta TE library on GENOME
RepeatMasker -lib LTR_REPLIB_CLASS.fasta -dir RepeatMasker_out -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta

### create bed file of the RepeatMasker output, where the name of each entry is name_of_element:chrom:start-end (in the genome)
awk -v OFS='\t' '$1 ~ /^[0-9]+$/ && /\+/ { print $5, $6, $7, $10 ":" $5 ":" $6 "-" $7, 0, $9 } 
                 $1 ~ /^[0-9]+$/ && !/\+/ { print $5, $6, $7, $10 ":" $5 ":" $6 "-" $7, 0, "-" }' RepeatMasker_out/${GENOME}.fasta.out > RM_BED/${GENOME}.bed

### create separate bed files for each LTR of interest (visualize in IGV)
grep "Copia_elem_LTR" RM_BED/${GENOME}.bed > RM_LTR_BED_FASTA/${GENOME}.Copia_elem_LTR.bed
grep "GYPSY1_MG_LTR" RM_BED/${GENOME}.bed > RM_LTR_BED_FASTA/${GENOME}.GYPSY1_MG_LTR.bed
grep "MAGGY_I_LTR" RM_BED/${GENOME}.bed > RM_LTR_BED_FASTA/${GENOME}.MAGGY_I_LTR.bed
grep "MGRL3_I_LTR" RM_BED/${GENOME}.bed > RM_LTR_BED_FASTA/${GENOME}.MGRL3_I_LTR.bed

### getfasta for each LTR
bedtools getfasta -s -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed RM_LTR_BED_FASTA/${GENOME}.Copia_elem_LTR.bed > RM_LTR_BED_FASTA/${GENOME}.Copia_elem_LTR.fasta
bedtools getfasta -s -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed RM_LTR_BED_FASTA/${GENOME}.GYPSY1_MG_LTR.bed > RM_LTR_BED_FASTA/${GENOME}.GYPSY1_MG_LTR.fasta
bedtools getfasta -s -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed RM_LTR_BED_FASTA/${GENOME}.MAGGY_I_LTR.bed > RM_LTR_BED_FASTA/${GENOME}.MAGGY_I_LTR.fasta
bedtools getfasta -s -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed RM_LTR_BED_FASTA/${GENOME}.MGRL3_I_LTR.bed > RM_LTR_BED_FASTA/${GENOME}.MGRL3_I_LTR.fasta

### name pairs of LTRs flanking an internal region after looking at IGV


