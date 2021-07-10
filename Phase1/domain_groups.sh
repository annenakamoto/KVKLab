#!/bin/bash
#SBATCH --job-name=domain_groups
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

#cd /global/scratch/users/annen/CDD_Profiles

# make library of cdd accessions to domain name
#echo "" > cdd_NAMES.txt
#while read acc; do
#acc2=${acc%.smp}
#echo $acc2
#grep -i -m 1 $acc2 cdd.versions | awk '{ print "CDD:" $3, $2 }' >> cdd_NAMES.txt
#done < CDD_profiles_acc.pn

cd /global/scratch/users/annen/

# Translate CDD accession output into domain names
#cat cdd_LIB_list.txt | python KVKLab/Phase1/cdd_to_name.py > cdd_LIB_list_N.txt

# group TEs by the domains they contain
#cat pfam_LIB_list.txt cdd_LIB_list_N.txt | python KVKLab/Phase1/group_by_domain.py > domain_groups_LIB.txt

source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
#translate -a -o LIB_DOM_trans.fasta.classified LIB_DOM.fasta.classified 
#cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py RVT_1 > LIB_DOM_RVT_1.fasta
#cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py DDE_1 > LIB_DOM_DDE_1.fasta

cd /global/scratch/users/annen/PFAM_files

#echo "" > PFAM_name_acc.txt

# get the specific accession numbers and the name
#while read acc; do
#grep -B 1 $acc Pfam-A.hmm | awk '{ print $2 }' >> PFAM_name_acc.txt
#done < PFAM_domains_specific.txt


# fetch top 2 domains: RVT_1 and DDE_1
#hmmfetch -o RVT_1.hmm Pfam-A.hmm PF00078.29
#hmmfetch -o DDE_1.hmm Pfam-A.hmm PF03184.21
#echo "* fetched domains *"

#hmmalign --trim --amino --informat fasta -o RVT_1_align.sto RVT_1.hmm /global/scratch/users/annen/LIB_DOM_RVT_1.fasta
#echo "aligned RVT_1"
#hmmalign --trim --amino --informat fasta -o DDE_1_align.sto DDE_1.hmm /global/scratch/users/annen/LIB_DOM_DDE_1.fasta
#echo "aligned DDE_1"

awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' RVT_1_align.sto > 1r.sto    #converts lower case characters (insertions) to gaps w/o changing names
awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' DDE_1_align.sto > 1d.sto
echo "converted lower case characters (insertions) to gaps"

esl-reformat --mingap -o 2r.fa afa 1r.sto                                                     #removes all-gap columns so that the number of columns matches HMM length
esl-reformat --mingap -o 2d.fa afa 1d.sto 
echo "removed all-gap columns so that the number of columns matches HMM length"

#cut -d '[' -f 1 2.fa| sed 's/>A--------/>Athaliana/g' > RVT_3_align.Matches.fa           #Shortens titles and restores gappy names

esl-alimanip -o 1r.fa --lnfract 0.7 2r.fa                                   #Trims sequences at 237aa/seq minimum ~70% of the model
esl-alimanip -o 1d.fa --lnfract 0.7 2d.fa 

#mv 1.fa RVT_3_align.Matches.237min.fa

esl-reformat -o RVT_1_align.Matches.70min.fa afa 1r.fa                                   #reformats to fasta
esl-reformat -o DDE_1_align.Matches.70min.fa afa 1d.fa  
echo "reformatted to fasta"

#mv 1.fa RVT_3_align.Matches.237min.fa

raxml -T 24 -n Raxml.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s RVT_1_align.Matches.70min.fa  #runs ML with Bailey et al parameters on 8 cores
raxml -T 24 -n Raxml.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s DDE_1_align.Matches.70min.fa
echo "ran RAXML"

conda deactivate
