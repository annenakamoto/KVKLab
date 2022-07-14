#!/bin/bash
#SBATCH --job-name=gene_dist_TE
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find the 5' (upstream) and 3' (downstream) distances of genes/effectors to TEs
###     Gene bedfiles are:      Expanded_effectors/GENE_BED/genes_${GENOME}.bed
###     TE bedfiles are:        visualize_TEs/${TE}.${GENOME}.bed
###     Output: gene    x-axis          y-axis
###     Output: gene    upstream(5')    downstream(3')

cd /global/scratch/users/annen/Expanded_effectors

while read GENOME; do
### Find the distance of genes in GENOME to the nearest individual TE (the ones that had expansions in that genome)
    while read TE; do
        echo "*** ${GENOME}: all genes to ${TE} ***"
        sort -k1,1 -k2,2n GENE_BED/genes_${GENOME}.bed > SORTED/genes_${GENOME}.sorted.bed
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed > SORTED/${TE}.${GENOME}.sorted.bed
        bedtools closest -D a -id -t first -a SORTED/genes_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > genes_${TE}.U.${GENOME}.bed
        bedtools closest -D a -iu -t first -a SORTED/genes_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > genes_${TE}.D.${GENOME}.bed
        ### parse the data
        echo "*** ${GENOME}: parsing data for all genes to ${TE} ***"
        > DIST_DATA/genes_${TE}.${GENOME}.DATA.txt
        echo -e "chr\tstart\tend\tgene\tMGG_orthogroup\tSCO\tEFF\tEFF_group\tTE_dist_5\tTE_dist_3" >> DIST_DATA/genes_${TE}.${GENOME}.DATA.txt    # col names
        cat genes_${TE}.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
            gene=$(echo ${LINE} | awk '{ print $4 }')
            us=$(grep "${LINE}" genes_${TE}.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
            ds=$(grep "${LINE}" genes_${TE}.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
            info=$(grep ${gene} GENE_BED/info_genes_${GENOME}.bed)
            echo -e "${info}\t${us}\t${ds}" >> DIST_DATA/genes_${TE}.${GENOME}.DATA.txt
        done
    done < te_list.txt 
done < genome_list.txt





