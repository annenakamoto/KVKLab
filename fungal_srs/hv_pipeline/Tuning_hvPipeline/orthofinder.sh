#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/maize_NAM_proteomes

# ls *.protein.fa | while read fa; do
#     cat ${fa} | awk -v RS=">" '/P001/ { print ">" substr($0, 1, length($0)-1); }' > /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline/OrthoFinder_in/${fa}
# done

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/Tuning_hvPipeline

### Run OrthoFinder on maize NAM proteomes
# module purge
# rm -r OrthoFinder_out
# source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder
# orthofinder -oa -f OrthoFinder_in -t 24 -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -X -o OrthoFinder_out
# conda deactivate

### check orthogroups, were any clades from Maize_NLRome_GeneTable.txt broken?
python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Tuning_hvPipeline/check_ogs.py > check_OGs_REPORT.txt
