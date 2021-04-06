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
pfam_scan.pl -fasta LIB.fasta -dir PFAM_files -e_dom 0.01 -e_seq 1 -outfile pfam_LIB.out

source deactivate