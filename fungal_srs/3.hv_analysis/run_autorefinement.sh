#!/bin/bash
#SBATCH --job-name=treesplit
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Run R script for autorefinement with different parameters

working_dir=${1}    ## HV_ANALYSIS dir
species=${2}        ## Mo, Zt, Sc
min_eco=${3}        ## was ~2/3 of the total number of accessions [adjust this first, ]
max_bl=${4}         ## was 0.5 (or 0.3 before that)
min_bl=${5}         ## was 0.05
min_bs=${6}         ## was 90

cd ${working_dir}
out_dir=TREESPLIT_OUT_${min_eco}_${max_bl}_${min_bl}_${min_bs}  ## create a unique directory for every different combination of parameters tried
mkdir -p ${out_dir}

module purge
source activate /global/scratch/users/annen/anaconda3/envs/R

### run autorefinement tree-splitting R script on each OG
# ls OG_TREES_filtered/RAxML_bipartitionsBranchLabels.RAxML* | awk -v FS="." '{ print $4; }' | while read OG; do
#     Rscript /global/scratch/users/annen/KVKLab/fungal_srs/3.hv_analysis/autorefinement.R \
#         --working_dir ${working_dir} \
#         --tree_path OG_TREES_filtered/RAxML_bipartitionsBranchLabels.RAxML.${species}.${OG} \
#         --alignment_path OG_ALIGNMENTS_filtered/${OG}.afa\
#         --min_eco_overlap ${min_eco} \
#         --max_branch_length ${max_bl} \
#         --min_branch_length ${min_bl} \
#         --min_bs_support ${min_bs} \
#         --out_dir ${out_dir}
# done

### run alignment filtering script to assess #hvsites of subalignments generated by tree splitting
# mkdir -p ${out_dir}/SUBALIGNMENTS
# cp ${out_dir}/*.subali.afa ${out_dir}/SUBALIGNMENTS
# cd ${out_dir}/SUBALIGNMENTS
# Rscript /global/scratch/users/annen/KVKLab/fungal_srs/3.hv_analysis/assess_aln_cutoff_dist.R \
#     --working_dir . \
#     --MinGapFraction 0.9 \
#     --MinGapBlockWidth 3 | awk '/subali.afa/ { print substr($2,2,length($2)-12) "\t" $3 "\t" substr($4,1,length($4)-1); }' > ${working_dir}/${out_dir}.HVSITE_RESULTS.txt

cd ${working_dir}
# echo -e "DATASET_STYLE\nSEPARATOR COMMA\nDATASET_LABEL,hv genes\nCOLOR,#ffff00\nDATA" > ${out_dir}.HV_HILIGHT.iTOL.txt
# echo -e "GENE\tREFINED_CLADE\tFINAL_CLADE\tHV\tHVSITES\tHVSITES_LEN_NORM" > ${out_dir}.GENE_TABLE.txt
# cat ${out_dir}.HVSITE_RESULTS.txt | while read line; do
#     clade_f=$(echo ${line} | awk '{ print $1; }')
#     OG=$(echo ${clade_f} | awk '{ split($1,n,"_"); print n[1]; }')
#     hv=$(echo ${line} | awk '{ if ($2 >= 10) { print "1"; } else { print "0"; } }')
#     hvsites=$(echo ${line} | awk '{ print $2; }')
#     hvsitenorm=$(echo ${line} | awk '{ print $3; }')
#     data=$(echo -e "${clade_f}\t${clade_f}\t${hv}\t${hvsites}\t${hvsitenorm}")
#     cat ${out_dir}/${OG}.subclade_list.txt | awk -v data="${data}" -v cf=${clade_f} '$3 ~ cf { print $1 "\t" data; }' >> ${out_dir}.GENE_TABLE.txt
#     if [ "${hv}" -eq "1" ]; then
#         cat ${out_dir}/${OG}.subclade_list.txt | awk -v cf=${clade_f} '$3 ~ cf { print $1 ",label,node,#000000,1,normal,#fff93d"; }' >> ${out_dir}.HV_HILIGHT.iTOL.txt
#     fi
# done

### calculate precision and recall
dm_tbl=../NLR_CTRL/TREESPLIT_OUT_*_0.5_0.05_90.GENE_TABLE.txt
og_tbl=${out_dir}.GENE_TABLE.txt

> ${out_dir}.PRECISION_RECALL.txt
cat ${dm_tbl} | awk '/NLR_Clade/' | while read c; do
    gene=$(echo ${c} | awk '{ print $1; }')
    ishv=$(echo ${c} | awk '{ print $4; }')
    calledhv=$(cat ${og_tbl} | awk -v g=${gene} 'BEGIN { p=0; } $1 ~ g { p=$4; } END { print p; }')
    echo -e "${gene}\t${ishv}\t${calledhv}" >> ${out_dir}.PRECISION_RECALL.txt
done

TP=$(cat ${out_dir}.PRECISION_RECALL.txt | awk '$2 ~ 1 && $3 ~ 1' | wc -l)
FP=$(cat ${out_dir}.PRECISION_RECALL.txt | awk '$2 ~ 0 && $3 ~ 1' | wc -l)
FN=$(cat ${out_dir}.PRECISION_RECALL.txt | awk '$2 ~ 1 && $3 ~ 0' | wc -l)
TN=$(cat ${out_dir}.PRECISION_RECALL.txt | awk '$2 ~ 0 && $3 ~ 0' | wc -l)

PRECISION=$(awk -v tp=${TP} -v fp=${FP} 'BEGIN { print (tp / (tp + fp)); }')
RECALL=$(awk -v tp=${TP} -v fn=${FN} 'BEGIN { print (tp / (tp + fn)); }')
echo -e "\nTP\tFP\tFN\tTN" >> ${out_dir}.PRECISION_RECALL.txt
echo -e "${TP}\t${FP}\t${FN}\t${TN}\n" >> ${out_dir}.PRECISION_RECALL.txt
echo "Precision = ${TP} / (${TP} + ${FP}) = ${PRECISION}" >> ${out_dir}.PRECISION_RECALL.txt
echo "Recall = ${TP} / (${TP} + ${FN}) = ${RECALL}" >> ${out_dir}.PRECISION_RECALL.txt

conda deactivate
