#!/bin/bash
#SBATCH --job-name=make_lib
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
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
#cat fngrep.fasta > REPLIB_uncl.fasta

#while read GENOME; do
#    cat denovo_annot/rmdb_$GENOME-families.fasta >> REPLIB_uncl.fasta
#done < rep_genome_list.txt

#while read GENOME; do
#    cat denovo_annot/irf_$GENOME.fasta >> REPLIB_uncl.fasta
#done < rep_genome_list.txt

### run the library through CD-HIT
#cd-hit-est -i REPLIB_uncl.fasta -o REPLIB_clust -c 1.0 -aS 0.99 -g 1 -d 0 -T 24 -M 0

### parse the clustered library to prioritize RepBase, RepeatModeler, then IRF to be the representative element
#awk 'BEGIN { max=0; clust=0; rb=0; }
#     />Cluster/ { max=0; rb=0; clust=$2 }
#     !/>irf-|>ltr-|>rnd-|>Cluster/ { if(substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3); rb=1 } }
#     />ltr-/ || />rnd-/ { if(max==0 || rb==0 && substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
#     />irf-/ && /\*/ { if(max==0) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
#     END { for(i in a) { print a[i]; } }' REPLIB_clust.clstr > REPLIB_list.txt

#cat REPLIB_list.txt | python /global/scratch/users/annen/KVKLab/Phase1/robustTE_prioritize.py REPLIB_uncl.fasta > REPLIB_clust.fasta

### running pfam_scan.pl on the clustered REPLIB_clust.fasta, translating it to protein sequences
#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
#pfam_scan.pl -fasta REPLIB_clust.fasta -dir PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile pfam_REPLIB.out
#cat pfam_REPLIB.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_pfam.py > pfam_REPLIB_list.txt
#conda deactivate

### running rpsblast on the clustered REPLIB_clust.fasta
rpstblastn -query REPLIB_clust.fasta -db CDD_lib/CDD_lib -out cdd_REPLIB.out -evalue 0.001 -outfmt 6
cat cdd_REPLIB.out | python /global/scratch/users/annen/KVKLab/Phase1/parse_cdd.py > cdd_REPLIB_list.txt

### create final clustered library with domains
cat pfam_REPLIB_list.txt cdd_REPLIB_list.txt | python /global/scratch/users/annen/KVKLab/Phase1/parse_domlib.py REPLIB_clust.fasta > REPLIB_DOM.fasta

