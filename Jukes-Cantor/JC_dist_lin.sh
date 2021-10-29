#!/bin/bash
#SBATCH --job-name=ref_jukes_cantor
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     find Jukes-Cantor distances for one TE between one reference sequence and sequences in a library file
###     separate by the different lineages, create a consensus for each lineage

TE=$1           ### name of the TE
DOM=$2          ### name of the domain for filtering
GEN=$3          ### name of the lineage (genome)
LIB_PATH=/global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta     ### path to fasta file containing library of many sequences
                ### /global/scratch/users/annen/Rep_TE_Lib/Align_TEs/REPHITS_${TE}.fasta 

cd /global/scratch/users/annen/JC_dist_indiv_TEs/${TE}

### filter TE library by domain (filtered library in ${TE}.${GEN}.filt_lib.fasta.filt_lib.fasta)
#cat /global/scratch/users/annen/Rep_TE_Lib/PFAM_lib/1${TE}.${DOM}.fa_align.Matches.* | awk -v gen=${GEN} '$0 ~ gen { print substr($1, 1, length($1)-2) }' | tr \# \: | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/filter_te_lib.py ${LIB_PATH} ${TE} > ${TE}.${GEN}.filt_lib.fasta
#echo "*** created filtered ${TE} ${GEN} library ***"

### generate MSA and remove all-gap columns
#mafft --localpair ${TE}.${GEN}.filt_lib.fasta > ${TE}.${GEN}.filt_lib.aligned
#source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl
#esl-reformat --mingap -o ${TE}.${GEN}.filt_al.nogap afa ${TE}.${GEN}.filt_lib.aligned
#conda deactivate
#echo "*** finished ${TE} ${GEN} MSA ***"

### generate consensus sequence
#cons -sequence ${TE}.${GEN}.filt_al.nogap -outseq ${TE}.${GEN}.filt.cons.fasta -name ${TE}.${GEN}
#echo "*** generated ${TE} ${GEN} consensus sequence ***"
#cat ${TE}.${GEN}.filt.cons.fasta | awk '{ gsub("n", ""); print; }' > ${TE}.${GEN}.CONS.fasta 
#echo "*** removed unknown (n) characters from consensus ***"

### use needle to align each TE to the consensus and find the percent identity, then compute JC dist in python
needle -asequence ${TE}.CONS.fasta  -bsequence ${TE}.${GEN}.filt_lib.fasta -outfile ${TE}.${GEN}.filt.needle -gapopen 10.0 -gapextend 0.5
echo "*** finished needle for ${TE} ${GEN} ***"
cat ${TE}.${GEN}.filt.needle | awk '/# Identity:/ { print $3 }' | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/simple_JC.py ${TE}.${GEN} > ${TE}.${GEN}.filt.JC.out.txt
echo "*** finished computing JC discances ***"
