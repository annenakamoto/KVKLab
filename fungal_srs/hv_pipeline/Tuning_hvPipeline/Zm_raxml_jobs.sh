#!/bin/bash
#SBATCH --job-name=Zm_raxml_jobs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

#cd /global/scratch/users/annen
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OG_RAXML

### range of OGs to run raxml for [1, 3086]
start=${1}
stop=${2}

cat ../../../HValn_OGs_list.txt | sed -n "${start},${stop}p" | while read OG; do
    #sbatch -A co_minium --qos=savio_lowprio --requeue KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/og_mafft_raxml.sh ${OG}
    if [ ! -f "RAxML_bipartitionsBranchLabels.RAxML.${OG}" ]; then
        echo "*********** ${OG} starting raxml ***********"
        dt=$(date '+%m/%d/%Y %H:%M:%S')
        echo "STARTING: ${dt}"
        raxmlHPC-PTHREADS-SSE3 -s ../OG_MAFFT/${OG}.afa -n RAxML.${OG} -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
        dt=$(date '+%m/%d/%Y %H:%M:%S')
        echo "DONE: ${dt}"
    else
        echo "*********** ${OG} already done ***********"
    fi
done
