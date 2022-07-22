#!/bin/bash
#SBATCH --job-name=visualize_TEs
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Generate bed files to visualize TE position and JC distance

cd /global/scratch/users/annen/visualize_TEs

# while read TE; do
#     while read genome; do
#         cat ${TE}.${genome}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/visualize.py ${TE}.${genome}.filt.JC.out.txt > ${TE}.${genome}.bed
#     done < genome_list.txt
# done < TE_list.txt


while read TE; do
    > itol_JC_ds.${TE}.txt
    echo "DATASET_GRADIENT" >> itol_JC_ds.${TE}.txt
    echo "SEPARATOR SPACE" >> itol_JC_ds.${TE}.txt
    echo "DATASET_LABEL GC content" >> itol_JC_ds.${TE}.txt
    echo "COLOR #ff0000" >> itol_JC_ds.${TE}.txt
    echo "COLOR_MIN #ff0000" >> itol_JC_ds.${TE}.txt
    echo "COLOR_MAX #0000ff" >> itol_JC_ds.${TE}.txt
    echo "DATA" >> itol_JC_ds.${TE}.txt
    while read genome; do
        cat ${TE}.${genome}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/itol_JC_ds.py ${TE}.${genome}.filt.JC.out.txt >> itol_JC_ds.${TE}.txt
    done < genome_list.txt
done < TE_list.txt

