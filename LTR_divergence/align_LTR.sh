#!/bin/bash
#SBATCH --job-name=LTR_align
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Follows preprocess_for_LTR.sh: Use bedfiles to get the internal + flanking LTR region (for MAGGY, GYPSY1, Copia, and MGRL3)

cd /global/scratch/users/annen/LTR_divergence

LTR_in=$1

> LTRs_ofinterest.txt
echo "MAGGY_I" >> LTRs_ofinterest.txt
echo "GYPSY1_MG" >> LTRs_ofinterest.txt
echo "Copia_elem" >> LTRs_ofinterest.txt
echo "MGRL3_I" >> LTRs_ofinterest.txt
> repgenome_list.txt
echo "guy11" >> repgenome_list.txt
echo "US71" >> repgenome_list.txt
echo "B71" >> repgenome_list.txt
echo "LpKY97" >> repgenome_list.txt
echo "MZ5-1-6" >> repgenome_list.txt

### get chromosome lengths
while read GENOME; do
    cat /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > LEN/${GENOME}.len
done < repgenome_list.txt

### use bedtools slop to get the element + 1000 bp on each side
while read LTR; do
    echo "*** slop and getfasta for ${LTR} ***"
    > ${LTR}_flank.fasta
    while read GENOME; do
        bedtools slop -i ${LTR}.${GENOME}.bed -g LEN/${GENOME}.len -b 1000 > ${LTR}.${GENOME}.flank.bed
        bedtools getfasta -s -name+ -fi /global/scratch/users/annen/GENOME_TREE/hq_genomes/${GENOME}.fasta -bed ${LTR}.${GENOME}.flank.bed >> ${LTR}_flank.fasta
    done < repgenome_list.txt
done < LTRs_ofinterest.txt

### align the LTR elements + flanking regions (${LTR}_flank.fasta)

echo "*** aligning ${LTR_in} ***"
mafft --globalpair --thread 24 ${LTR_in}_flank.fasta > ${LTR_in}_flank.afa

### manually look at alignment and see where to trim it


