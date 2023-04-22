#!/bin/bash
#SBATCH --job-name=og_raxml
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### run mafft on OG
# ls OrthoFinder_out/Results_Mar16/MultipleSequenceAlignments/ | awk '/OG/ { print substr($1,1,9); }' | while read OG; do
#     mafft --maxiterate 1000 --localpair --thread 24 --quiet OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa > OG_MAFFT/${OG}.afa
#     echo "${OG} done"
# done

### ran out of memory after OG0028794, run what's left (starting with OG0028795)
# cat ../../remaining_OG.txt | while read OG; do
#     mafft --maxiterate 1000 --localpair --thread 24 --quiet OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa > OG_MAFFT/${OG}.afa
#     echo "${OG} done"
# done

OG=${1}
### run raxml on OG alignment
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/REFINEMENT/RAxML_ref2
echo "*********** ${OG} starting raxml ***********"
rm RAxML.${OG}
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "STARTING: ${dt}"
raxmlHPC-PTHREADS-SSE3 -s ../Refinement2_init/${OG}.afa -n RAxML.${OG} -T ${SLURM_NTASKS} -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
dt=$(date '+%m/%d/%Y %H:%M:%S')
echo "DONE: ${dt}"

