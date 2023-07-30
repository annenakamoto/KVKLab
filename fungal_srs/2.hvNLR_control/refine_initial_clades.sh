#!/bin/bash
#SBATCH --job-name=initial_nlr_clades
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### split the domain-based NLR trees into initial clades to generate alignments and trees for further refinement
working_dir=${1}    ## NLR_CTRL dir
species=${2}        ## Mo, Zt, Sc, or Nc
DOM=${3}            ## NB-ARC or NACHT

cd ${working_dir}
# out_dir=TREESPLIT_OUT_${DOM}
# mkdir -p ${out_dir}

module purge

### run autorefinement tree-splitting R script on the domain-based tree
# source activate /global/scratch/users/annen/anaconda3/envs/R
# Rscript /global/scratch/users/annen/KVKLab/fungal_srs/3.hv_analysis/autorefinement.R \
#     --working_dir ${working_dir} \
#     --tree_path DOMAIN_TREES/RAxML_bipartitionsBranchLabels.RAxML.${species}.${DOM} \
#     --alignment_path ${species}.${DOM}.filt.F.afa \
#     --min_eco_overlap 0 \
#     --max_branch_length 1 \
#     --min_branch_length 0.3 \
#     --min_bs_support 90 \
#     --out_dir ${out_dir}
# source deactivate

### python script to combine the NACHT and NB_ARC clades
source activate /global/scratch/users/annen/anaconda3/envs/Biopython
python /global/scratch/users/annen/KVKLab/fungal_srs/2.hvNLR_control/combine_init_clades.py ${working_dir} ${species}
source deactivate

module load seqtk
