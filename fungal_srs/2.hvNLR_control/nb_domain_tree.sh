#!/bin/bash
#SBATCH --job-name=tree_nb_domain
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### make a domain-based (NB-ARC, NACHT) tree

working_dir=${1}    ## NLR_CTRL dir
species=${2}        ## Mo, Zt, Sc, or Nc
DOM=${3}            ## NB-ARC or NACHT

cd ${working_dir}
mkdir -p DOMAIN_TREES

module purge
module load module load /global/home/groups/consultsw/sl-7.x86_64/modfiles/raxml/8.2.11     ## has pthreads version

echo "*********** ${DOM} starting raxml ***********"
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING: ${dt}"
raxmlHPC-PTHREADS-SSE3 -s ${species}.${DOM}.filt.F.afa -n RAxML.${species}.${DOM} -w DOMAIN_TREES -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE: ${dt}"
