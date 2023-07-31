#!/bin/bash
#SBATCH --job-name=clade_tree
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

working_dir=${1}    ## NLR_CTRL dir
species=${2}        ## Mo, Zt, Sc, or Nc
clade=${3}          ## the clade to generate an alignment and tree for (ie. NLR_Clade12_57)

cd ${working_dir}
mkdir -p CLADE_TREES

echo "Running mafft..."
mafft --maxiterate 1000 --localpair --thread ${SLURM_NTASKS} --quiet ${species}.${clade}.fa > ${species}.${clade}.afa
echo "DONE"

echo "*********** ${clade} starting raxml ***********"
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING: ${dt}"
raxmlHPC-PTHREADS-SSE3 -s ${species}.${clade}.afa -n RAxML.${species}.${clade} -w ${working_dir}/CLADE_TREES -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE: ${dt}"

