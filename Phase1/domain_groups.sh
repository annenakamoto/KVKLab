#!/bin/bash
#SBATCH --job-name=domain_groups
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/CDD_Profiles
while read acc; do
    acc2=${acc%.smp}
    grep -m 1 acc2 cdd.versions | awk '{ print "CDD:" $3, $2 }' >> cdd_NAMES.txt
done < CDD_profiles_acc.pn

cd /global/scratch/users/annen/


# Translate CDD accession output into domain names
#cat cdd_LIB_list.txt | python KVKLab/Phase1/cdd_to_name.py > cdd_LIB_list_N.txt
#echo "python finished"

# group TEs by the domains they contain
#cat pfam_LIB_list.txt cdd_LIB_list_N.txt | python KVKLab/Phase1/group_by_domain.py > domain_groups_LIB.txt

