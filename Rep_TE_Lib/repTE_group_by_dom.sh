#!/bin/bash
#SBATCH --job-name=group_by_dom
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### following method in Phase1/domain_groups.sh

cd /global/scratch/users/annen/Rep_TE_Lib

name=$1     # ex: RVT_1
accn=$2     # ex: PF00078.29

### Translate CDD accession output into domain names
cat cdd_REPLIB_list.txt | python /global/scratch/users/annen/KVKLab/Phase1/cdd_to_name.py > cdd_REPLIB_list_N.txt

### group TEs by the domains they contain
cat pfam_REPLIB_list.txt cdd_REPLIB_list_N.txt | python /global/scratch/users/annen/KVKLab/Phase1/group_by_domain.py > domain_groups_REPLIB.txt

### Translate library (REPLIB_DOM.fasta) into protein sequence
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
translate -a -o REPLIB_DOM_trans.fasta REPLIB_DOM.fasta

### make the domain-specific TE library
#cat REPLIB_DOM_trans.fasta | python /global/scratch/users/annen/KVKLab/Phase1/dom_spec_lib.py $name > LIB_DOM_${name}.fasta

### Alignment and filtering

conda deactivate

### Generating tree using RAxML

