#!/bin/bash
#SBATCH --job-name=Zm_raxml_jobs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen

### range of OGs to run raxml for [1, 3086]
start=${1}
stop=${2}

cat HValn_OGs_list.txt | sed -n "${start},${stop}p" | while read OG; do
    sbatch -A co_minium --qos=savio_lowprio --requeue KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/og_mafft_raxml.sh ${OG}
done
