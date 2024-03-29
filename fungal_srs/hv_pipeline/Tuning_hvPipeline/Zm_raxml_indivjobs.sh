#!/bin/bash
#SBATCH --job-name=Zm_raxml_jobs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

#cd /global/scratch/users/annen
cd /global/scratch/users/annen

### range of OGs to run raxml for [1, 3086] for initial Refinement 1
###     [1, 818] for initial Refinement 2
start=${1}
stop=${2}
part=${3}
tasks=${4}
lst=${5}
raxml_dir=${6}
aln_dir=${7}

#cat HValn_OGs_list.txt 
cat ${lst} | sed -n "${start},${stop}p" | while read OG; do
    if [ ! -f "000_FUNGAL_SRS_000/${raxml_dir}/RAxML_bipartitionsBranchLabels.RAxML.${OG}" ]; then
        rm 000_FUNGAL_SRS_000/${raxml_dir}/*${OG}
        echo "*********** ${OG} starting job ***********"
        sbatch -A co_minium --qos=savio_lowprio -p ${part} --ntasks-per-node=${tasks} --requeue KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/og_mafft_raxml.sh ${OG} ${raxml_dir} ${aln_dir}
    else
        echo "*********** ${OG} already done ***********"
    fi
done
