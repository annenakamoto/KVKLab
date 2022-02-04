#!/bin/bash
#SBATCH --job-name=pot2_flank
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Grab all flanking genes of POT2 copies in B71 and guy11 to find potentially transferred regions
###     Then I can manually look at those gene trees

cd /global/scratch/users/annen/POT2_flank

### make chrom length file for slop
cat /global/scratch/users/annen/JC_cons_genomes/guy11.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > guy11.len
cat /global/scratch/users/annen/JC_cons_genomes/B71.fasta | python /global/scratch/users/annen/KVKLab/POT2_HT/chrom_len.py > B71.len

### Get POT2 coordinates + 50,000 bp flank on each side
bedtools slop -i POT2.guy11.bed -g guy11.len -b 50000 > guy11.POT2_flank.bed
bedtools slop -i POT2.B71.bed -g B71.len -b 50000 > B71.POT2_flank.bed

### Grab all genes in that region OG_guy11.bed
bedtools intersect -a guy11.POT2_flank.bed -b OG_guy11.bed -wa -wb > guy11.POT2_genes.bed
bedtools intersect -a B71.POT2_flank.bed -b OG_B71.bed -wa -wb > B71.POT2_genes.bed

### Find POT2 in guy11 and B71 that have the most genes in common (rank)
python /global/scratch/users/annen/KVKLab/POT2_HT/shared_OGs.py guy11.POT2_genes.bed B71.POT2_genes.bed > FILTERED_guy11_B71_POT2.txt

### run mummer on the filtered hits
while read line; do
    # bedtools getfasta -s -name+ -fo POT2_mummer/${GENOME}.POT2_flank.fasta -fi JC_cons_genomes/${GENOME}.fasta -bed POT2_mummer/${GENOME}.POT2_flank.bed
    
    # /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/nucmer -t 24 --maxmatch -p nucmer_out/${query_b}.${ref_b} ${ref} ${query}
    # /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/show-coords nucmer_out/${query_b}.${ref_b}.delta > show_coords_out/${query_b}.${ref_b}.coords
    # /global/scratch/users/annen/MUMmer/mummer-4.0.0rc1/mummerplot --postscript --color -p mummerplot_out/${query_b}.${ref_b} nucmer_out/${query_b}.${ref_b}.delta
    # ps2pdf mummerplot_out/${query_b}.${ref_b}.ps pdf_plots/${query_b}.${ref_b}.pdf
    # convert -density 150 pdf_plots/${query_b}.${ref_b}.pdf -quality 90 jpg_plots/${query_b}.${ref_b}.jpg
done < FILTERED_guy11_B71_POT2.txt



