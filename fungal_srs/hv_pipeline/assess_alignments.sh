#!/bin/bash
#SBATCH --job-name=R_assess_alignments
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen

source activate /global/scratch/users/annen/anaconda3/envs/R

### run the R script that outputs a list of OGs with alignments that pass hv parameters

### maize
#Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > HValn_OGs_list.txt
Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R | awk '/[1]/ { print substr($2,2,9); }' > HValn_OGs_cutoff_dist_Zm.txt

### magnaporthe
#Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > MoHValn_OGs_list.txt


conda deactivate
