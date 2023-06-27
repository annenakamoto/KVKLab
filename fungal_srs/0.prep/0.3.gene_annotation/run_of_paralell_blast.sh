#!/bin/bash
#SBATCH --job-name=of_blast_parallel
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### parallelize diamond blastp searches for orthofinder run

working_dir=${1}    # ORTHOFINDER directory

cd ${working_dir}

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

orthofinder -op -S diamond_ultra_sens -f FAA -n out -o OrthoFinder_out | grep "diamond blastp" > jobqueue

N_NODES=3

mv jobqueue jobqueue_old

shuf jobqueue_old > jobqueue

split -a 3 --number=l/${N_NODES} --numeric-suffixes=1 jobqueue jobqueue_

for node in $(seq -f "%03g" 1 ${N_NODES})
do
    echo $node
    sbatch -p savio4_htc -A co_minium --ntasks-per-node=56 --qos=minium_htc4_normal --job-name=$node.blast --export=ALL,node=$node /global/scratch/users/annen/KVKLab/fungal_srs/0.prep/0.3.gene_annotation/run_of_parallel_jobqueue.sh
done

