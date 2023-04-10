#!/bin/bash
#SBATCH --job-name=og_raxml
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/REFINEMENT_nlrs

ref=${1}    # name of the refinement directory to look in (Refinement1, Refinement2, etc) that was transferred from local
clade=${2}  # name of a clade that has been split and made it to next refinement step (ie. OG0000110_216_L_149)
new=${3}    # name of new refinement directory to output msa and tree to
OG=$(echo ${clade} | awk -v FS="_" '{ print $1; }')     # get the name of the orthogroup from the clade name

mkdir -p ${new}     # create the new refinement directory if it doesn't already exist

### make new fasta file of genes just in the CLADE
module load seqtk
fa=../OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa
cat ${ref}/${clade}.afa | awk '/>/ { print substr($1, 2); }' > tmp.${clade}.list.txt
seqtk subseq -l 60 ${fa} tmp.${clade}.list.txt > tmp.${clade}.fa

### run mafft
mafft --maxiterate 1000 --localpair --thread 24 --quiet tmp.${clade}.fa > ${new}/${clade}.afa

### run raxml
cd ${new}
raxmlHPC-PTHREADS-SSE3 -s ${clade}.afa -n RAxML.${clade} -T 24 -m PROTCATJTT -f a -x 12345 -p 12345 -# 100

### remove the temporary fasta and list files
rm ../${clade}.fa ../tmp.${clade}.list.txt
