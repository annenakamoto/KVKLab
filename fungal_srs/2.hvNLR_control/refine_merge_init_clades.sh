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

cd ${working_dir}

### python script to combine the NACHT and NB_ARC clades
# source activate /global/scratch/users/annen/anaconda3/envs/Biopython
# python /global/scratch/users/annen/KVKLab/fungal_srs/2.hvNLR_control/combine_init_clades.py ${working_dir} ${species}
# source deactivate

module load seqtk
ls ${species}.NLR_Clade* | while read list; do
    clade_name=$(echo ${list} | awk -v FS="." '{ print $2; }')
    seqtk subseq -l 60 WD/${species}_PANPROTEOME.faa ${list} > ${species}.${clade_name}.fa
done
