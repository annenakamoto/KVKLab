#!/bin/bash
#SBATCH --job-name=Nc_raxml_NBARC_NACHT_AAA
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=9:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/333_NEUROSPORA_GS_MTK_333/RefGenome_NC12_NLRs

DOM=${1}

source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

hmmsearch -A Nc_${DOM}.sto ${DOM}.hmm Nc_OR74A_PROTEOME.fa
tr a-z - < Nc_${DOM}.sto > Nc_${DOM}.noins.sto                            ## convert lower case characters (insertions) to gaps
esl-reformat --mingap -o Nc_${DOM}.nogap.sto afa Nc_${DOM}.noins.sto      ## remove all-gap columns so that the number of columns matches HMM length
esl-alimanip -o Nc_${DOM}.filt.sto --lmin 10 Nc_${DOM}.nogap.sto          ## remove sequences with less than 10 AA
esl-reformat -o Nc_${DOM}.filt.afa afa Nc_${DOM}.filt.sto                 ## reformat to fasta
cat Nc_${DOM}.filt.afa | awk -v d=NB-ARC '!/>/ { print; } />/ { split($1,a,"/"); print ">" substr($0,length($0)-9) "|" a[2] "|" d; }' > Nc_${DOM}.filt.final.afa    ## fix gene names

source deactivate

echo "*********** ${DOM} starting raxml ***********"
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING: ${dt}"
raxmlHPC-PTHREADS-SSE3 -s Nc_${DOM}.filt.final.afa -n RAxML.Nc_${DOM} -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE: ${dt}"
