#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=savio
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run OrthoFinder on Magnaporthe proteomes

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder
module purge

source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

orthofinder -op -S diamond_ultra_sens -f MoPROTEOMES_72 -n out -o OrthoFinder_out | grep "diamond blastp" > jobqueue

N_NODES=3

mv jobqueue jobqueue_old

shuf jobqueue_old > jobqueue

split -a 3 --number=l/${N_NODES} --numeric-suffixes=1 jobqueue jobqueue_

for node in $(seq -f "%03g" 1 ${N_NODES})
do
    echo $node
    sbatch -p savio4_htc -A co_minium --ntasks-per-node=56 --qos=minium_htc4_normal --job-name=$node.blast --export=ALL,node=$node /global/scratch/users/annen/KVKLab/fungal_srs/Magnaporthe/orthofinder_blast.sh
done

### for after parallel diamond blastp
#orthofinder -oa -M msa -A mafft -T fasttree -t ${SLURM_NTASKS} -a 5 -n out -b OrthoFinder_out/Results_out/WorkingDirectory

### running by itself
#orthofinder -os -f MoPROTEOMES_72 -t ${SLURM_NTASKS} -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -X -o OrthoFinder_out
conda deactivate
