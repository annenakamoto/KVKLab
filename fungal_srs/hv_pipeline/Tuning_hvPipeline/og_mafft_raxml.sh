#!/bin/bash
#SBATCH --job-name=og_mafft_raxml
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=FAIL

OG=${1}     # the orthogroup is taken as input

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### run mafft on OG
mafft --maxiterate 1000 --localpair --thread 24 OrthoFinder_out/Results_Mar16/Orthogroup_Sequences/${OG}.fa > OG_MAFFT/${OG}.afa

### run raxml on OG alignment
cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OG_RAXML
raxmlHPC-PTHREADS-SSE3 -s /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OG_MAFFT/${OG}.afa -n RAxML.${OG} -T 24 -m PROTCATJTT -f a -x 12345 -p 12345 -# 100
