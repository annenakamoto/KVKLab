#!/bin/bash
#SBATCH --job-name=LTR_align
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Follows blast_LTR.sh: Align the blast hits for MAGGY, GYPSY1, Copia, and MGRL3

cd /global/scratch/users/annen/LTR_divergence

LTR=$1

### align all the sequnces in ${LTR}_blast.fasta
echo "*** aligning ${LTR} seqs ***"
mafft --thread 24 ${LTR}_blast.fasta > ${LTR}_blast.afa
trimal -in ${LTR}_blast.afa -out ${LTR}_blast.trim.afa -noallgaps

### generate a consensus sequence using the alignment (will go into library for RepeatMasking in next step)
echo "*** generating ${LTR} consensus ***"
cons -sequence ${LTR}_blast.trim.afa -outseq ${LTR}_LTR_cons.fasta -name ${LTR}_LTR
echo "*** done ***"
