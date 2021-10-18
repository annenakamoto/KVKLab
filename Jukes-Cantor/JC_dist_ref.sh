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

NAME=$1         ### name of the TE, or "SCOs"
DOM=$2          ### name of the domain for filtering
LIB_PATH=/global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${NAME}.fasta     ### path to fasta file containing library of many sequences
                ### /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta                

########### I'll use the filtered TE set from the cleaner-looking domain based trees, and the full TE nucleotide sequences
########### Actually, trying with the full REPHITS libraries first

lib=$(basename $1)

# TEST RUN: sbatch KVKLab/Jukes-Cantor/JC_dist_ref.sh 
cd /global/scratch/users/annen/JC_Dist_filt

### filter TE library (filtered library in ${NAME}.filt_lib.fasta)
cat /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib/1${NAME}.${DOM}.fa_align.Matches.* | awk '/>/ { print substr($1, 1, length($1)-2) }' | tr \# \: | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/filter_te_lib.py ${LIB_PATH} ${NAME} > ${NAME}.filt_lib.fasta
echo "*** created filtered ${NAME} library ***"

### generate MSA and remove all-gap columns
mafft ${NAME}.filt_lib.fasta > ${NAME}.filt_lib.aligned
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
esl-reformat --mingap -o ${NAME}.filt_al.nogap afa ${NAME}.filt_lib.aligned
source deactivate
echo "*** finished ${NAME} MSA ***"

### generate consensus sequence
cons -sequence ${NAME}.filt_al.nogap -outseq ${NAME}.filt.cons.fasta -name ${NAME}
echo "*** generated ${NAME} consensus sequence ***"

### use needle to align each TE to the consensus and find the percent identity, then compute JC dist in python
needle -asequence ${NAME}.filt.cons.fasta -bsequence ${NAME}.filt_lib.fasta -outfile ${NAME}.filt.needle -gapopen 10.0 -gapextend 0.5
echo "*** finished needle for ${NAME} ***"
cat ${NAME}.filt.needle | awk '/# Identity:/ { print $3 }' | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/simple_JC.py ${NAME} > ${NAME}.filt.JC.out.txt
echo "*** finished computing JC discances ***"

### compute jukes-cantor distances using Boyan's modified python script
#source activate /global/scratch/users/annen/anaconda3/envs/Biopython
#python /global/scratch/users/annen/KVKLab/Jukes-Cantor/JC_dist_ref.py ${LIB_PATH} ${NAME}.cons.fasta > ${NAME}_jc.txt
#conda deactivate
