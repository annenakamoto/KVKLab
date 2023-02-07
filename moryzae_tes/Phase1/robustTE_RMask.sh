#!/bin/bash
#SBATCH --job-name=RepeatMask
#SBATCH --account=ac_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/RepeatMask_part_class
source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

GENOME=$1

# run RepeatMasker on GENOME using high quality TE library that was scanned for domains
RepeatMasker -lib /global/scratch/users/annen/LIB_DOM_part_class.fasta -dir RepeatMasker_out -gff -cutoff 200 -no_is -nolow -pa 24 -gccalc /global/scratch/users/annen/hq_genomes/$GENOME.fasta

# create fasta file of the RepeatMasker output, where the name of each entry is >name_of_element:start-end (in the genome)
awk -v OFS='\t' '$1 ~ /^[0-9]+$/ { print $5, $6, $7, $10 ":" $5 ":" $6 "-" $7 }' RepeatMasker_out/$GENOME.fasta.out > $GENOME.fasta.bed
bedtools getfasta -fo $GENOME.RM.fasta -name -fi /global/scratch/users/annen/hq_genomes/$GENOME.fasta -bed $GENOME.fasta.bed

# scan RepeatMasker fasta file ($GENOME.RM.fasta) for CDD profile domains using RPS-BLAST
rpstblastn -query $GENOME.RM.fasta -db /global/scratch/users/annen/CDD_Profiles/CDD_lib -out $GENOME.RM.cdd.out -evalue 0.001 -outfmt 6

# parse rpsblast output into a text file list of elements and their domains ($GENOME.RM.cdd_list.txt)
cat $GENOME.RM.cdd.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_cdd.py > $GENOME.RM.cdd_list.txt

source deactivate
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
# scan RepeatMasker fasta file ($GENOME.RM.fasta) for PFAM profile domains using pfam_scan.pl
pfam_scan.pl -fasta $GENOME.RM.fasta -dir /global/scratch/users/annen/PFAM_files/PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile $GENOME.RM.pfam.out

# parse pfam_scan.pl output into a text file list of elements and their domains (pfam_LIB_list.txt)
cat $GENOME.RM.pfam.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_pfam.py > $GENOME.RM.pfam_list.txt

# merge cdd and pfam lists into one list
cat $GENOME.RM.cdd_list.txt $GENOME.RM.pfam_list.txt | python /global/scratch/users/annen/KVKLab/Phase1/parse_cddpfam.py > $GENOME.RM.uniq.txt

# count the number of each element
cat $GENOME.RM.uniq.txt | python /global/scratch/users/annen/KVKLab/Phase1/count_elems.py > data_$GENOME.txt

source deactivate