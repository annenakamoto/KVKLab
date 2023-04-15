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

### parallelize diamond blastp part
# source activate /global/scratch/users/annen/anaconda3/envs/OrthoFinder

# orthofinder -op -S diamond_ultra_sens -f MoPROTEOMES_72 -n out -o OrthoFinder_out | grep "diamond blastp" > jobqueue

# N_NODES=3

# mv jobqueue jobqueue_old

# shuf jobqueue_old > jobqueue

# split -a 3 --number=l/${N_NODES} --numeric-suffixes=1 jobqueue jobqueue_

# for node in $(seq -f "%03g" 1 ${N_NODES})
# do
#     echo $node
#     sbatch -p savio4_htc -A co_minium --ntasks-per-node=56 --qos=minium_htc4_normal --job-name=$node.blast --export=ALL,node=$node /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Magnaporthe/orthofinder_blast.sh
# done
### end parallelize

### for after parallel diamond blastp
# orthofinder -os -M msa -A mafft -T fasttree -t ${SLURM_NTASKS} -a 5 -n out -b OrthoFinder_out/Results_out/WorkingDirectory

### command for single orthofinder run with no parallelization
#orthofinder -os -f MoPROTEOMES_72 -t ${SLURM_NTASKS} -a 5 -M msa -S diamond_ultra_sens -A mafft -T fasttree -X -o OrthoFinder_out
# source deactivate

### MAKE GENOME TREE ###

### align SCOs
# sco_dir=/global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Single_Copy_Orthologue_Sequences
# mkdir -p SCO_Alignments
# part=${1}
# ls ${sco_dir}/OG000${part}* | awk -v FS="." '{ print substr($1, length($1)-8, length($1)) }' | while read sco; do
#     mafft --maxiterate 1000 --globalpair --thread ${SLURM_NTASKS} --quiet ${sco_dir}/${sco}.fa > SCO_Alignments/${sco}.afa
#     echo "${sco} done"
# done

### align other OGs
og_dir=/global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/OrthoFinder_out/Results_out/WorkingDirectory/OrthoFinder/Results_out/Orthogroup_Sequences
mkdir -p OG_Alignments
part=${1}   ## 00 to 18
ls ${og_dir}/OG00${part}* | awk -v FS="." '{ print substr($1, length($1)-8, length($1)) }' | while read sco; do
    if [ -f "SCO_Alignments/${sco}.afa" ]; then 
        cp SCO_Alignments/${sco}.afa OG_Alignments/${sco}.afa
        echo "copied over ${sco}"
    else 
        echo "aligning ${sco}..."
        mafft --maxiterate 1000 --globalpair --thread ${SLURM_NTASKS} --quiet ${og_dir}/${sco}.fa > OG_Alignments/${sco}.afa
        echo "${sco} done"
    fi
done

### Concatenate MSAs
# source activate /global/scratch/users/annen/anaconda3/envs/Biopython
# cat tmp_gn.txt | python /global/scratch/users/annen/KVKLab/fungal_srs/hv_pipeline/Magnaporthe/concat_msa.py SCO_Alignments ALL_SCOs.afa
# source deactivate
# echo "done concatenating alignment"

### Trim alignment
# module load trimal
# trimal -gt 1 -in ALL_SCOs.afa -out ALL_SCOs.trim.afa
# echo "done trimming alignment"

# module load fasttreeMP
# echo "starting fasttree"
# FastTreeMP -gamma -out ALL_SCOs.tree.mp ALL_SCOs.trim.afa 
