#!/bin/bash
#SBATCH --job-name=raxml_NBARC_NACHT_AAA
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/NBARC_NACHT_AAA_hvAnalysis

DOM=${1}

echo "*********** ${DOM} starting raxml ***********"
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING: ${dt}"
raxmlHPC-PTHREADS-SSE3 -s ${DOM}.Mo.filt.afa -n RAxML.${DOM} -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE: ${dt}"
