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
#Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R | awk '/[1]/' > HValn_OGs_cutoff_dist_Zm.txt
#cat HValn_OGs_cutoff_dist_Zm.txt | awk -v FS="t" '/[1]/ { print substr($1,6,9) "\t" substr($2,1,length($2)-1); }' > HValn_OGs_cutoff_dist_Zm_formatted.txt

### magnaporthe
#Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > MoHValn_OGs_list.txt
Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R | awk '/[1]/' > MoHValn_OGs_cutoff_dist.txt
#cat MoHValn_OGs_cutoff_dist.txt | awk -v FS="t" '/[1]/ { print substr($1,6,9) "\t" substr($2,1,length($2)-1); }' > MoHValn_OGs_cutoff_dist_formatted.txt

conda deactivate
