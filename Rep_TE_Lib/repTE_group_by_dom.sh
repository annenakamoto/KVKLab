#!/bin/bash
#SBATCH --job-name=group_by_dom
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=56:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Grouping TEs by the domains they contain, aligning the domains, and prodocing a phylogeny for the domain
###     Domains used:    
###         RVT_1	            PF00078.29
###         DDE_1	            PF03184.21
###         rve	                PF00665.28
###         Chromo	            PF00385.26
###         RNase_H	            PF00075.26
###         RVT_2	            PF07727.16
###         Exo_endo_phos_2     PF14529.8
###     following method in Phase1/domain_groups.sh
###     Usage: sbatch KVKLab/Rep_TE_Lib/repTE_group_by_dom.sh <domain_name> <domain_accession>

cd /global/scratch/users/annen/Rep_TE_Lib

name=$1     # ex: RVT_1
accn=$2     # ex: PF00078.29


source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

### make the domain-specific TE library
cat REPLIB_DOM_trans.fasta | python /global/scratch/users/annen/KVKLab/Phase1/dom_spec_lib.py $1 > DOMspecTE_LIBs/LIB_DOM_${1}.fasta

cd /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib
### Alignment and filtering
hmmfetch -o ${1}.hmm Pfam-A.hmm $2
echo "* fetched domains *"
hmmalign --trim --amino --informat fasta -o ${1}_align.sto ${1}.hmm /global/scratch/users/annen/Rep_TE_Lib/DOMspecTE_LIBs/LIB_DOM_${1}.fasta
echo "aligned ${1}"
tr \: \# <${1}_align.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > 1${1}.sto
echo "converted lower case characters (insertions) to gaps"
esl-reformat --mingap -o 2${1}.fa afa 1${1}.sto 
echo "removed all-gap columns so that the number of columns matches HMM length"
leng=$(grep LENG ${1}.hmm | awk '{ print int($2*0.7) }')
esl-alimanip -o 1${1}.fa --lmin $leng 2${1}.fa 
echo "trimmed sequences at minimum ~70% of the model"
esl-reformat -o ${1}_align.Matches.${leng}min.fa afa 1${1}.fa  
echo "reformatted to fasta"

conda deactivate

### Generating tree using RAxML
echo "********* STARTING TO MAKE TREE *********"
raxml -T 24 -n Raxml_${1}.out -f a -x 12345 -p 12345 -# 100 -m PROTCATJTT -s ${1}_align.Matches.${leng}min.fa
echo "ran RAXML for ${1}"

