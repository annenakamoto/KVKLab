#!/bin/bash
#SBATCH --job-name=ref_jukes_cantor
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     find Jukes-Cantor distances between one reference sequence and sequences in a library file

LIB_PATH=$1     ### path to fasta file containing library of many sequences
                ### /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta                
NAME=$2         ### name of the TE, or "SCOs"

########### I'll use the filtered TE set from the cleaner-looking domain based trees, and the full TE nucleotide sequences
########### Actually, trying with the full REPHITS libraries first

lib=$(basename $1)

# TEST RUN: sbatch KVKLab/Jukes-Cantor/JC_dist_ref.sh 
cd /global/scratch/users/annen/JC_Dist

mafft ${LIB_PATH} > ${NAME}.aligned
trimal -in ${NAME}.aligned -out ${NAME}.al.nogap -noallgaps
cons -sequence ${NAME}.al.nogap -outseq ${NAME}.cons.fasta -name ${NAME}_cons


module unload python
source activate /global/scratch/users/annen/anaconda3/envs/Biopython

python /global/scratch/users/annen/KVKLab/Jukes-Cantor/JC_dist_ref.py ${LIB_PATH} ${NAME}.cons.fasta > ${NAME}_jc.out

conda deactivate
module load python
