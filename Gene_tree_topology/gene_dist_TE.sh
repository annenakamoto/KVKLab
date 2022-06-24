#!/bin/bash
#SBATCH --job-name=gene_dist_TE
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Determine the distance of genes with congruent vs incongruent trees to the nearest TE (5' and 3')
### OrthoFinder results used here are from: /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21
###     This includes the 70-15 genome for easy mapping to known AVRs and effector structural groups

cd /global/scratch/users/annen/treeKO_analysis

GENOME=$1
# contains the positions of genes: /global/scratch/users/annen/visualize_OGs/${GENOME}.bed
#   gene names are original ones from fungap, need to be mapped to names in orthofinder output (gene_00001 -> gene_0_guy11)

   
### Find the distance of genes in GENOME to the nearest individual TE
while read TE; do
    echo "*** ${GENOME}: genes to ${TE} ***"
    cat /global/scratch/users/annen/visualize_OGs/${GENOME}.bed | python /global/scratch/users/annen/KVKLab/Gene_tree_topology/rename_genes.py ${GENOME} > UNSORTED/GENES_${GENOME}.bed
    sort -k1,1 -k2,2n UNSORTED/GENES_${GENOME}.bed > SORTED/GENES_${GENOME}.sorted.bed
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed > SORTED/${TE}.${GENOME}.sorted.bed
    bedtools closest -D a -id -t first -a SORTED/GENES_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > UPSTREAM/gene_${TE}.U.${GENOME}.bed
    bedtools closest -D a -iu -t first -a SORTED/GENES_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > DOWNSTREAM/gene_${TE}.D.${GENOME}.bed
    ### parse the data
    echo "*** ${GENOME}: parsing data for genes to ${TE} ***"
    > gene_${TE}.${GENOME}.DATA.txt
    cat UPSTREAM/gene_${TE}.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep "${LINE}" UPSTREAM/gene_${TE}.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep "${LINE}" DOWNSTREAM/gene_${TE}.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        OG=$(grep "${gene}" /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups.txt | awk -v FS=':' '{ print $1; }')
        SCO=$(grep "${OG}" /global/scratch/users/annen/GENOME_TREE/OrthoFinder_out/Results_Jun21/Orthogroups/Orthogroups_SingleCopyOrthologues.txt | awk '/OG/ { print "SCO"; }')
        if [ -z "${SCO}" ]; then
            SCO="x"
        fi
        EFF=$(grep "${gene}" /global/scratch/users/annen/Effector_analysis/${GENOME}_effector_protein_names | awk '/gene/ { print "EFF"; }')
        if [ -z "${EFF}" ]; then
            EFF="x"
        fi
        SD=$(grep ${OG} /global/scratch/users/annen/treeKO_analysis/treeKO_output_table.txt | awk '/OG/ { print $2; }')
        if [ -z "${SD}" ]; then
            SD="x"
        fi
        echo -e "${gene}\t${us}\t${ds}\t${OG}\t${SCO}\t${EFF}\t${SD}" >> gene_${TE}.${GENOME}.DATA.txt
        ### columns: gene_name, upstream_dist_TE, downstream_dist_TE, Orthogrup, SCO?, EFF?, strict_distance, congruent_or_incongruent?
    done
done < te_list.txt 


