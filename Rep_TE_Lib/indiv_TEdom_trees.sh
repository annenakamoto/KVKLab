#!/bin/bash
#SBATCH --job-name=TE_dom_tree
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Create a TE tree based on one domain
###     Usage: sbatch KVKLab/Rep_TE_Lib/indiv_TEdom_trees.sh <TE> <PFAM domain>

TE=$1   # RepBase element (ex. MAGGY)
DOM=$2  # pfam domain (ex. RVT_1)

cd /global/scratch/users/annen/Rep_TE_Lib/Align_TE_Doms
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

### scan RepeatMasker hits (REPHITS_${TE}.fasta) for DOM using pfam_scan.pl
pfam_scan.pl -fasta /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta -dir PFAM_libs/${DOM} -e_dom 0.01 -e_seq 0.01 -translate all -outfile ${TE}.pfam.out
echo "scanned ${TE} TEs for ${DOM} domain"

conda deactivate

### make a bed file of the pfam_scan.pl output
awk -v OFS='\t' '$18 ~ !/\#/ { print $1, $2, $3, $7, "0", $16 }' ${TE}.pfam.out > ${TE}.pfam.bed

### extract the domain sequences using bedtools getfasta
bedtools getfasta -fo ${TE}.${DOM}.fasta -name -s -fi /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta -bed ${TE}.pfam.bed
echo "got the ${DOM} domain sequences from each ${TE} TE"

### align extracted sequences using MAFFT
mafft ${TE}.${DOM}.fasta > Alignments/${TE}.${DOM}.afa
echo "aligned the ${DOM} domain sequences"

cd Alignments
### make the tree using RAxML
raxml -T 24 -n Raxml_${TE}.${DOM}.out -f a -x 12345 -p 12345 -# 100 -m GTRGAMMA -s ${TE}.${DOM}.afa
echo "made a tree for ${TE} using ${DOM} domain"
