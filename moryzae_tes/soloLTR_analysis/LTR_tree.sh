#!/bin/bash
#SBATCH --job-name=LTR_tree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make a tree of LTRs

cd /global/scratch/users/annen/SOLO_LTRs

LTR=$1

> FASTA_FOR_TREE/${LTR}.fasta
while read GENOME; do
    cat NEW_SOLOS/${LTR}.${GENOME}.solo.bed NEW_FLANK/${LTR}.${GENOME}.flank.bed | awk -v OFS='\t' -v genome=${GENOME} '{ print $1, $2, $3, genome "_" $4}' > BED_FOR_TREE/${LTR}.${GENOME}.all.bed
    bedtools getfasta -name -fo FASTA_FOR_TREE/${LTR}.${GENOME}.fasta -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed BED_FOR_TREE/${LTR}.${GENOME}.all.bed
    cat FASTA_FOR_TREE/${LTR}.${GENOME}.fasta | awk -v FS='(' '/>/ { print $1; } !/>/ { print; }' >> FASTA_FOR_TREE/${LTR}.fasta
done < repgenome_list.txt

mafft --thread 24 FASTA_FOR_TREE/${LTR}.fasta > ALIGNED_FOR_TREE/${LTR}.afa
trimal -in ALIGNED_FOR_TREE/${LTR}.afa -out ALIGNED_FOR_TREE/${LTR}.trim.afa -noallgaps
echo "*** aligned ${LTR} LTRs ***"
raxmlHPC-PTHREADS-SSE3 -T 24 -n Raxml_${LTR}.out -f a -x 12345 -p 12345 -# 100 -m GTRCAT -s ALIGNED_FOR_TREE/${LTR}.trim.afa
echo "*** made tree for ${LTR} LTRs ***"
