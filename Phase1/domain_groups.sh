#!/bin/bash
#SBATCH --job-name=domain_groups
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=01:00:00
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

#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
#translate -a -o LIB_DOM_trans.fasta.classified LIB_DOM.fasta.classified 
#cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py RVT_1 > LIB_DOM_RVT_1.fasta
#cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py DDE_1 > LIB_DOM_DDE_1.fasta
#cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py rve > LIB_DOM_rve.fasta

#cat LIB_DOM_RVT_1.fasta | python KVKLab/Phase1/unique_classes.py > PFAM_files/RVT_1_unique_classes.txt
#cat LIB_DOM_DDE_1.fasta | python KVKLab/Phase1/unique_classes.py > PFAM_files/DDE_1_unique_classes.txt
#cat LIB_DOM_rve.fasta | python KVKLab/Phase1/unique_classes.py > PFAM_files/rve_unique_classes.txt

echo "" > PFAM_files/ALL_unique_classes.txt
while read dom; do
    #cat LIB_DOM_trans.fasta.classified | python KVKLab/Phase1/dom_spec_lib.py $dom > LIB_DOM_${dom}.fasta
    echo "" >> PFAM_files/ALL_unique_classes.txt
    echo \> ${dom} >> PFAM_files/ALL_unique_classes.txt
    cat LIB_DOM_${dom}.fasta | python KVKLab/Phase1/unique_classes.py >> PFAM_files/ALL_unique_classes.txt
done < pfam_doms.txt


cd /global/scratch/users/annen/PFAM_files

#echo "" > PFAM_name_acc.txt

# get the specific accession numbers and the name
#while read acc; do
#grep -B 1 $acc Pfam-A.hmm | awk '{ print $2 }' >> PFAM_name_acc.txt
#done < PFAM_domains_specific.txt


# fetch top 2 domains: RVT_1 and DDE_1
#hmmfetch -o RVT_1.hmm Pfam-A.hmm PF00078.29
#hmmfetch -o DDE_1.hmm Pfam-A.hmm PF03184.21
#hmmfetch -o rve.hmm Pfam-A.hmm PF00665.28
#echo "* fetched domains *"

#hmmalign --trim --amino --informat fasta -o RVT_1_align.sto RVT_1.hmm /global/scratch/users/annen/LIB_DOM_RVT_1.fasta
#echo "aligned RVT_1"
#hmmalign --trim --amino --informat fasta -o DDE_1_align.sto DDE_1.hmm /global/scratch/users/annen/LIB_DOM_DDE_1.fasta
#echo "aligned DDE_1"
#hmmalign --trim --amino --informat fasta -o rve_align.sto rve.hmm /global/scratch/users/annen/LIB_DOM_rve.fasta
#echo "aligned rve"

#tr \: \# <RVT_1_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1r.sto    #converts lower case characters (insertions) to gaps w/o changing names, and gets rid of ":" raxml illegal character
#tr \: \# <DDE_1_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1d.sto
#tr \: \# <rve_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1rve.sto
#echo "converted lower case characters (insertions) to gaps"

#esl-reformat --mingap -o 2r.fa afa 1r.sto                                                     #removes all-gap columns so that the number of columns matches HMM length
#esl-reformat --mingap -o 2d.fa afa 1d.sto 
#esl-reformat --mingap -o 2rve.fa afa 1rve.sto 
#echo "removed all-gap columns so that the number of columns matches HMM length"

#esl-alimanip -o 1r.fa --lmin 155 2r.fa                                   #Trims sequences at minimum ~70% of the model
#esl-alimanip -o 1d.fa --lmin 122 2d.fa 
#esl-alimanip -o 1rve.fa --lmin 71 2rve.fa 

#esl-reformat -o RVT_1_align.Matches.155min.fa afa 1r.fa                                   #reformats to fasta
#esl-reformat -o DDE_1_align.Matches.122min.fa afa 1d.fa  
#esl-reformat -o rve_align.Matches.71min.fa afa 1rve.fa  
#echo "reformatted to fasta"

cd /global/scratch/users/annen/

# use ModelGenerator to find the best substitution model, with 4 gamma categories (this is the # that RAXML uses too)
#java -jar modelgenerator_v_851/modelgenerator.jar PFAM_files/RVT_1_align.Matches.155min.fa 4
#echo "ran ModelGenerator for RVT_1"
#java -jar modelgenerator_v_851/modelgenerator.jar PFAM_files/DDE_1_align.Matches.122min.fa 4
#echo "ran ModelGenerator for DDE_1"
#java -jar modelgenerator_v_851/modelgenerator.jar PFAM_files/rve_align.Matches.71min.fa 4
#echo "ran ModelGenerator for rve"
cd /global/scratch/users/annen/PFAM_files

#cat RVT_1_align.Matches.155min.fa rve_align.Matches.71min.fa | python /global/scratch/users/annen/KVKLab/Phase1/multi_domain.py > RVT_1_rve_align.Matches.fa

#raxml -T 24 -n Raxml_RVT_1.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s RVT_1_align.Matches.155min.fa  #runs ML with Bailey et al parameters on 8 cores
#echo "ran RAXML for RVT_1."
#raxml -T 24 -n Raxml_DDE_1.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s DDE_1_align.Matches.122min.fa
#echo "ran RAXML for DDE_1"
#raxml -T 24 -n Raxml_rve.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s rve_align.Matches.71min.fa
#echo "ran RAXML for rve"
#raxml -T 24 -n Raxml_RVT_1_rve.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s RVT_1_rve_align.Matches.fa
#echo "ran RAXML for RVT_1 + rve"

#conda deactivate
