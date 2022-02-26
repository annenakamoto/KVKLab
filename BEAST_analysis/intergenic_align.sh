#!/bin/bash
#SBATCH --job-name=intergenic_align
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Make intergenic nucleotide alignment (for BEAST)

cd /global/scratch/users/annen/GENOME_TREE

### make intergenic sequences bedfile (complement of genic bed)
while read GENOME; do
    ### Generate chromosome length file
    cat hq_genomes/${GENOME}.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > LEN/${GENOME}.len
    bedtools complement -i SCO_BED/SCO_${GENOME}.bed -g LEN/${GENOME}.len > INTERGENIC/int_${GENOME}.bed
done < genome_list.txt

### now what to do with intergenic regions bedfiles? Do genome-wide alignments to pick out the syntenic regions, then do alignments 


### genome-wide alignments to get syntenic regions (bedfile?)
### 
