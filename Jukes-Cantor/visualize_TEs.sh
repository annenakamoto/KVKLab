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

### produce itol dataset file to visualize JC dist (one consensus for all) around each of the TE trees
# while read TE; do
#     > itol_JC_ds.${TE}.txt
#     echo "DATASET_GRADIENT" >> itol_JC_ds.${TE}.txt
#     echo "SEPARATOR SPACE" >> itol_JC_ds.${TE}.txt
#     echo "DATASET_LABEL JC" >> itol_JC_ds.${TE}.txt
#     echo "COLOR #ff0000" >> itol_JC_ds.${TE}.txt
#     echo "COLOR_MIN #ff0000" >> itol_JC_ds.${TE}.txt
#     echo "COLOR_MAX #0000ff" >> itol_JC_ds.${TE}.txt
#     echo "DATA" >> itol_JC_ds.${TE}.txt
#     while read genome; do
#         cat ${TE}.${genome}.filt_lib.fasta | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/itol_JC_ds.py ${TE}.${genome}.filt.JC.out.txt >> itol_JC_ds.${TE}.txt
#     done < genome_list.txt
# done < TE_list.txt

### produce itol dataset file to visualize JC dist (consensus per lineage) around each of the TE trees
# cd /global/scratch/users/annen/JC_dist_indiv_TEs
# while read TE; do
#     > itol_JC_ds_lin.${TE}.txt
#     echo "DATASET_GRADIENT" >> itol_JC_ds_lin.${TE}.txt
#     echo "SEPARATOR SPACE" >> itol_JC_ds_lin.${TE}.txt
#     echo "DATASET_LABEL JC_lin" >> itol_JC_ds_lin.${TE}.txt
#     echo "COLOR #ff0000" >> itol_JC_ds_lin.${TE}.txt
#     echo "COLOR_MIN #ff0000" >> itol_JC_ds_lin.${TE}.txt
#     echo "COLOR_MAX #0000ff" >> itol_JC_ds_lin.${TE}.txt
#     echo "DATA" >> itol_JC_ds_lin.${TE}.txt
#     while read genome; do
#         grep ${genome} ${TE}.ALL_LIN.JC.txt | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/itol_JC_lin_ds.py ${TE}/${TE}.${genome}.filt_lib.fasta >> itol_JC_ds_lin.${TE}.txt
#     done < genome_list.txt
# done < TE_list.txt


### produce itol dataset file to visualize LTR divergence around each of the TE trees
###     LTR_DIV_RESULTS/ALL_RESULTS.LTRdiv.txt contains columns: LTR(name)	pair(#)	genome	divergence
###     MAPPING/${TE}.${GENOME}_mapping.txt contains columns:   pair(#): chrom  start   end LTR(name)   score(0)    strand
###         EXAMPLE:    1: MQOP01000001.1	2161562	2169220	MAGGY_I	0	+
cd /global/scratch/users/annen/LTR_divergence
while read TE; do
    > itol_LTR_ds.${TE}.txt
    echo "DATASET_GRADIENT" >> itol_LTR_ds.${TE}.txt
    echo "SEPARATOR SPACE" >> itol_LTR_ds.${TE}.txt
    echo "DATASET_LABEL LTR" >> itol_LTR_ds.${TE}.txt
    echo "COLOR #ff0000" >> itol_LTR_ds.${TE}.txt
    echo "COLOR_MIN #ff0000" >> itol_LTR_ds.${TE}.txt
    echo "COLOR_MAX #0000ff" >> itol_LTR_ds.${TE}.txt
    echo "DATA" >> itol_LTR_ds.${TE}.txt
    TE_short=$(echo ${TE} | awk -v FS="_" '{ print $1 }')
    while read genome; do
        cat LTR_DIV_RESULTS/ALL_RESULTS.LTRdiv.txt awk -v g=${genome} -v t=${TE_short} '$1 ~ t && $3 ~ g' | python /global/scratch/users/annen/KVKLab/Jukes-Cantor/itol_LTR_ds.py MAPPING/${TE}.${genome}_mapping.txt ${genome} >> itol_LTR_ds.${TE}.txt
    done < genome_list.txt
done < TE_list.txt

