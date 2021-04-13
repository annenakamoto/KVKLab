#!/bin/bash
#SBATCH --job-name=Robust_TE_library
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
#source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler

# combine RepeatModleler, IRF, and RepBase (References/fngrep.fasta) libraries
#cat References/fngrep.fasta > unclib.fasta
#while read GENOME; do
#    cat rmdb_$GENOME-families.fasta >> unclib.fasta
#done < KVKLab/Phase1/robustTE_pipe_in.txt

#while read GENOME; do
#    cat irf_$GENOME.fasta >> unclib.fasta
#done < KVKLab/Phase1/robustTE_pipe_in.txt

# run CD-HIT to remove repeats, obtain high quality comprehensive TE library
#cd-hit-est -i unclib.fasta -o clustlib.fasta -c 1.0 -aS 0.99 -g 1 -d 0 -T 24 -M 0

# parse the clustered library to prioritize RepBase, RepeatModeler, then IRF to be the representative element
#awk 'BEGIN { max=0; clust=0; rb=0; }
#    />Cluster/ { max=0; rb=0; clust=$2 }
#    !/>irf-|>ltr-|>rnd-|>Cluster/ { if(substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3); rb=1 } }
#    />ltr-/ || />rnd-/ { if(max==0 || rb==0 && substr($2, 1, length($2)-3)+0>max) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
#    />irf-/ && /\*/ { if(max==0) { max=substr($2, 1, length($2)-3)+0; a[clust]=substr($3, 1, length($3)-3) } }
#    END { for(i in a) { print a[i]; } }' clustlib.fasta.clstr > LIB_list.txt

#cat LIB_list.txt | python KVKLab/Phase1/robustTE_prioritize.py unclib.fasta > LIB.fasta
#source deactivate

# scan library for HMM PFAM profile domains using pfam_scan.pl
#cd /global/scratch/users/annen/PFAM_files
#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

#echo "" > PFAM_domains_specific.txt

# get the specific accession numbers
#while read acc; do
#grep $acc Pfam-A.hmm | awk '{ print $2 }' >> PFAM_domains_specific.txt
#done < PFAM_domains.txt

# fetch all the domains in PFAM_domains_specific.txt
#hmmfetch -o PFAM_lib/Pfam-A.hmm -f Pfam-A.hmm PFAM_domains_specific.txt

# generate binaries for PFAM_domains.hmm library 
#hmmpress PFAM_lib/Pfam-A.hmm

#cd /global/scratch/users/annen
# running pfam_scan.pl on the clustered LIB.fasta, translating it to protein sequences
#pfam_scan.pl -fasta LIB.fasta -dir PFAM_files/PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile pfam_LIB.out

#cat pfam_LIB.out | python KVKLab/Phase1/parse_pfam.py > pfam_LIB_list.txt
#source deactivate

# scan library for CDD profile domains using RPS-BLAST
source activate /global/scratch/users/annen/anaconda3/envs/RepeatModeler
cd /global/scratch/users/annen/CDD_Profiles

# using the list of PSSM id's (CDD_profiles.txt) get a list of the accessions (CDD_profiles_acc.pn)
#echo "" > CDD_profiles_acc.pn
#while read pssm; do
#grep -m 1 $pssm cdd.versions | awk '{ print $1 ".smp" }' >> CDD_profiles_acc.pn
#done < CDD_profiles.txt

# making rps database of CDD domains and running rpsblast
makeprofiledb -title CDD_lib -in CDD_profiles_acc.pn -out CDD_lib -threshold 9.82 -scale 100.0 -dbtype rps -index true
echo "made database"
cd /global/scratch/users/annen
rpsblast -query LIB.fasta -db CDD_Profiles/CDD_lib -out cdd_LIB.out -evalue 0.001
echo "ran rpsblast"

# parse rpsblast output into a text file list of elements and their domains (cdd_LIB_list.txt)

source deactivate
