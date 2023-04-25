#!/bin/bash
#SBATCH --job-name=deeptmhmm
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run DeepTMHMM on Mo orthogroups to predict surface receptors

start=${1}  ## Parallelize: specify a range of OGs [1, 18934]
stop=${2}

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
mkdir -p DEEPTMHMM_OG
tmp_dir=tmp_deeptmhmm_${start}_${stop}
mkdir ${tmp_dir}
cd ${tmp_dir}

og_dir=../OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences
source activate /global/scratch/users/annen/anaconda3/envs/DeepTMHMM
ls ${og_dir} | awk '{ print substr($1,1,9); }' | sed -n "${start},${stop}p" | while read OG; do
    biolib run DTU/DeepTMHMM --fasta ${og_dir}/${OG}.fa
    cp biolib_results/TMRs.gff3 ../DEEPTMHMM_OG/${OG}.gff
    cp biolib_results/deeptmhmm_results.md ../DEEPTMHMM_OG/${OG}.md
    cp biolib_results/predicted_topologies.3line ../DEEPTMHMM_OG/${OG}.3line
    rm -r biolib_results
    echo "${OG} DeepTMHMM done"
done
source deactivate
