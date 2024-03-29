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

### maize initial
# Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > HValn_OGs_list.txt
# Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R | awk '/[1]/' > HValn_OGs_cutoff_dist_Zm.txt
# cat HValn_OGs_cutoff_dist_Zm.txt | awk '{ print substr($2,2,9) "\t" $3 "\t" substr($4,1,length($4)-1); }' > HValn_OGs_cutoff_dist_Zm_formatted.txt

### magnaporthe initial
# Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > MoHValn_OGs_list.txt
# Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R | awk '/[1]/' > MoHValn_OGs_cutoff_dist.txt
# cat MoHValn_OGs_cutoff_dist.txt | awk '{ print substr($2,2,9) "\t" $3 "\t" substr($4,1,length($4)-1); }' > MoHValn_OGs_cutoff_dist_formatted.txt

### maize final clades
# Rscript KVKLab/fungal_srs/hv_pipeline/assess_alignment.R | awk '/[1]/ { print substr($2,2,9); }' > ZmHV_final_clades.txt

### NLR hv-site distributions from NLRCladeFinder
Arabidopsis_dir=/global/scratch/users/annen/222_HV_Parameters_Distributions_222/Atha_NLR_FINAL_AFA
Maize_dir=/global/scratch/users/annen/222_HV_Parameters_Distributions_222/Maize_NLR_FINAL_AFA
Soy_dir=/global/scratch/users/annen/222_HV_Parameters_Distributions_222/Soy_NLR_FINAL_AFA

Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R -w ${Arabidopsis_dir} | awk '/Int/ { print substr($2,2,length($2)-5) "\t" $3 "\t" substr($4,1,length($4)-1); }' > 222_HV_Parameters_Distributions_222/Atha_NLR_hvsites.txt
Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R -w ${Maize_dir} | awk '/Int/ { print substr($2,2,length($2)-5) "\t" $3 "\t" substr($4,1,length($4)-1); }' > 222_HV_Parameters_Distributions_222/Maize_NLR_hvsites.txt
Rscript KVKLab/fungal_srs/hv_pipeline/assess_aln_cutoff_dist.R -w ${Soy_dir} | awk '/Int/ { print substr($2,2,length($2)-5) "\t" $3 "\t" substr($4,1,length($4)-1); }' > 222_HV_Parameters_Distributions_222/Soy_NLR_hvsites.txt

source deactivate
