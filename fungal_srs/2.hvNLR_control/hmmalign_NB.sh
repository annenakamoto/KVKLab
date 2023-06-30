#!/bin/bash
#SBATCH --job-name=hmmalign_NB_domain
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Search for NLR-like genes in fungal genomes and make alignment based on NB domain

working_dir=${1}    ## NLR_CTRL/WD dir containing pfam/hmm files
species=${2}        ## Mo, Zt, Sc, or Nc
DOM=${3}            ## NB-ARC or NACHT

cd ${working_dir}

module purge
module load hmmer
source activate /global/scratch/users/annen/anaconda3/envs/pfam_scan.pl

### generate the panproteome
cat ../../ORTHOFINDER/FAA/${species}*.faa > ${species}_PANPROTEOME.faa

### Initial domain search and regenerating profile
echo "*** Initial ${DOM} search in ${species} panproteome to regenerate HMM ***"
hmmalign --trim --amino --informat fasta -o ${species}.${DOM}.sto ${DOM}.hmm ${species}_PANPROTEOME.faa     ## align domain using hmmalign
esl-reformat --mingap -o ${species}.${DOM}.nogap.sto afa ${species}.${DOM}.sto                 ## remove all-gap columns
leng=$(grep LENG ${DOM}.hmm | awk '{ print int($2*0.7) }')
esl-alimanip -o ${species}.${DOM}.filt.sto --lmin 30 ${species}.${DOM}.nogap.sto          ## remove sequences with less than 30 AA
esl-reformat -o ${species}.${DOM}.filt.afa afa ${species}.${DOM}.filt.sto                      ## reformat to fasta
hmmbuild ${species}.${DOM}.hmm ${species}.${DOM}.filt.afa                                      ## rebuild profile to be species-specific

### Search back in the panproteome to generate alignment for making tree
echo "*** Final ${DOM} search in ${species} panproteome to make alignment ***"
hmmalign --trim --amino --informat fasta -o ${species}.${DOM}.F.sto ${species}.${DOM}.hmm ${species}_PANPROTEOME.faa     ## align species-specific domain model using hmmalign
cat ${species}.${DOM}.F.sto | awk '{ gsub(/[a-z]/, "-", $(NF)); print; }' > ${species}.${DOM}.noins.F.sto                              ## convert lower case characters (insertions) to gaps
esl-reformat --mingap -o ${species}.${DOM}.nogap.F.sto afa ${species}.${DOM}.noins.F.sto                  ## remove all-gap columns
leng=$(grep LENG ${species}.${DOM}.hmm | awk '{ print int($2*0.7) }')
esl-alimanip -o ${species}.${DOM}.filt.F.sto --lmin 30 ${species}.${DOM}.nogap.F.sto          ## remove sequences with less than ~70% of the model length
esl-reformat -o ${species}.${DOM}.filt.F.afa afa ${species}.${DOM}.filt.F.sto                      ## reformat to fasta

cp ${species}.${DOM}.filt.F.afa ../${species}.${DOM}.filt.F.afa     ## copy result alignment, next make tree

conda deactivate
