#!/bin/bash
#SBATCH --job-name=filter_OG_alignments
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run R script to filter OGs based on alignment cutoffs, to keep only OGs that potentially contain hv clades

working_dir=${1}    ## dir containing OG alignments
mgf=${2}            ## 0.9 standard, 1 to only mask if all rows have the gap
out_file=${3}       ## output file name, ex. Mo_OGalign_filt_GAP.txt, Mo_OGalign_filt_NOGAP.txt

cd /global/scratch/users/annen

module purge
source activate /global/scratch/users/annen/anaconda3/envs/R
Rscript KVKLab/fungal_srs/3.hv_analysis/assess_aln_cutoff_dist.R -d ${working_dir} -f ${mgf} -w 3 | awk '/OG0/ { print substr($2,2,9) "\t" $3 "\t" substr($4,1,length($4)-1); }' > ${working_dir}/../${out_file}
conda deactivate
