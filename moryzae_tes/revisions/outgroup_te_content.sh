#!/bin/bash
#SBATCH --job-name=outgroup_te_content
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### annotate TEs in more outgroups

###     Run RepeatMasker on the input genome and scan output for domains
###     Generate a data file for the genome
###     following method in Phase1/robustTE_RMask.sh

cd /global/scratch/users/annen/Rep_TE_Lib/RMask_out

GENOME=$1

### run RepeatMasker on GENOME using high quality TE library that was scanned for domains
RepeatMasker -lib REPLIB_CLASS.fasta -dir RepeatMasker_out -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc hq_genomes/$GENOME.fasta

### create fasta file of the RepeatMasker output, where the name of each entry is >name_of_element:start-end (in the genome)
awk -v OFS='\t' '$1 ~ /^[0-9]+$/ && /\+/ { print $5, $6, $7, $10 ":" $5 ":" $6 "-" $7, 0, $9 } 
                 $1 ~ /^[0-9]+$/ && !/\+/ { print $5, $6, $7, $10 ":" $5 ":" $6 "-" $7, 0, "-" }' RepeatMasker_out/$GENOME.fasta.out > $GENOME.fasta.bed
bedtools getfasta -fo $GENOME.RM.fasta -name -s -fi hq_genomes/$GENOME.fasta -bed $GENOME.fasta.bed

### scan RepeatMasker fasta file ($GENOME.RM.fasta) for CDD profile domains using RPS-BLAST
rpstblastn -query $GENOME.RM.fasta -db /global/scratch/users/annen/Rep_TE_Lib/CDD_lib/CDD_lib -out $GENOME.RM.cdd.out -evalue 0.001 -outfmt 6

### parse rpsblast output into a text file list of elements and their domains ($GENOME.RM.cdd_list.txt)
cat $GENOME.RM.cdd.out | python py_helpers/parse_cdd.py > $GENOME.RM.cdd_list.txt


source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
### scan RepeatMasker fasta file ($GENOME.RM.fasta) for PFAM profile domains using pfam_scan.pl
pfam_scan.pl -fasta $GENOME.RM.fasta -dir /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile $GENOME.RM.pfam.out

### parse pfam_scan.pl output into a text file list of elements and their domains (pfam_LIB_list.txt)
cat $GENOME.RM.pfam.out | python py_helpers/parse_pfam.py > $GENOME.RM.pfam_list.txt

### merge cdd and pfam lists into one list
cat $GENOME.RM.cdd_list.txt $GENOME.RM.pfam_list.txt | python py_helpers/parse_cddpfam.py > $GENOME.RM.uniq.txt

### count the number of each element
cat $GENOME.RM.uniq.txt | python py_helpers/count_elems.py > data_$GENOME.txt

### find the number of bp each element takes up
cat $GENOME.RM.uniq.txt | python py_helpers/length_elems.py > data_bp_$GENOME.txt

source deactivate
