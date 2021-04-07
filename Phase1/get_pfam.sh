#!/bin/bash
#SBATCH --job-name=get_pfam
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/PFAM_files
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

#echo "" > PFAM_domains_specific.txt

# get the specific accession numbers
#while read acc; do
#grep $acc Pfam-A.hmm | awk '{ print $2 }' >> PFAM_domains_specific.txt
#done < PFAM_domains.txt

# fetch all the domains in PFAM_domains_specific.txt
#hmmfetch -o PFAM_lib/Pfam-A.hmm -f Pfam-A.hmm PFAM_domains_specific.txt

# generate binaries for PFAM_domains.hmm library 
#hmmpress PFAM_lib/Pfam-A.hmm

cd /global/scratch/users/annen
# running pfam_scan.pl on the clustered LIB.fasta, translating it to protein sequences
pfam_scan.pl -fasta LIB.fasta -dir PFAM_files/PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile pfam_LIB.out

cat pfam_LIB.out | python KVKLab/Phase1/parse_pfam.py > pfam_LIB_list.txt #LIB.fasta > LIB_dom.fasta


## testing pfam_scan on MAGGY_I (not part of pipeline)
#pfam_scan.pl -fasta References/MAGGY_I.fasta -dir PFAM_files/PFAM_lib -e_dom 0.01 -e_seq 0.01 -translate all -outfile pfam_MAGGY_I.out

source deactivate