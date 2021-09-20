#!/bin/bash
#SBATCH --job-name=classify_lib
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Produce tree for an individual TE using all RepeatMasker hits
###     following method in Phase1/tree_def.sh

TE=$1   # RepBase element (ex. MAGGY)
bootstraps=$2 # number of RAxML bootstraps to perform (normall 100)

cd /global/scratch/users/annen/Rep_TE_Lib

> Align_TEs/REPHITS_${TE}.fasta
while read genome; do
    cat RMask_out/${genome}.RM.fasta | python /global/scratch/users/annen/KVKLab/Rep_TE_Lib/spec_te_hits.py $TE $genome >> Align_TEs/REPHITS_${TE}.fasta
done < rep_genome_list.txt 
echo "created RepeatMasker hits library for ${TE}"

# cd /global/scratch/users/annen/MAFFT_out
# mafft Align_TEs/REPHITS_${TE}.fasta > Align_TEs/aligned_${TE}.afa
# echo "completed MSA for ${TE}"

# cd Align_TEs
# raxml -T 24 -n Raxml_${TE}.out -f a -x 12345 -p 12345 -# $bootstraps -m GTRCAT -s aligned_${TE}.afa
# echo "ran RAXML for ${TE}"