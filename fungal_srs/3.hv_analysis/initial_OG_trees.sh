#!/bin/bash
#SBATCH --job-name=OG_trees
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### run raxml to produce initial OG trees (potentially containing hv clades)

working_dir=${1}    ## HV_ANALYSIS dir
species=${2}        ## Mo, Zt, Sc, Nc
OG=${3}             ## orthogroup, ie. OG0000001

cd ${working_dir}

cp OG_ALIGNMENTS/${OG}.afa OG_ALIGNMENTS_filtered/${OG}.afa
cd OG_ALIGNMENTS_filtered

tree_file=../OG_TREES_filtered/RAxML_bipartitionsBranchLabels.RAxML.${species}.${OG}
if [[ -f "${tree_file}" && -s "${tree_file}" ]]; then
    echo "${OG} tree done (RAxML_bipartitionsBranchLabels.RAxML.${species}.${OG} is present and nonempty)"
else
    echo "*********** ${OG} starting raxml ***********"
    dt=$(date '+%m/%d/%Y %H:%M:%S')
    echo "STARTING: ${dt}"
    raxmlHPC-PTHREADS-SSE3 -s ${OG}.afa -n RAxML.${species}.${OG} -w ${working_dir}/OG_TREES_filtered -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
    dt=$(date '+%m/%d/%Y %H:%M:%S')
    echo "DONE: ${dt}"
fi
