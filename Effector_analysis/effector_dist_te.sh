#!/bin/bash
#SBATCH --job-name=effector_dist_TE
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find the 5' (upstream) and 3' (downstream) distances of genes/effectors to TEs
###     Gene bedfiles are:      visualize_OGs/E_SCO_OG_${GENOME}.bed
###     Effector bedfiles are:  visualize_OGs/EFF_${GENOME}.bed
###     TE bedfiles are:        visualize_TEs/${TE}.${GENOME}.bed
###     Output: gene    x-axis          y-axis
###     Output: gene    upstream(5')    downstream(3')

cd /global/scratch/users/annen/Effector_dist_TE

while read GENOME; do
    ### Find the distance of ALL genes in GENOME to ALL genes
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all genes to all genes ***"
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/E_SCO_OG_${GENOME}.bed > SORTED/E_SCO_OG_${GENOME}.bed
    bedtools closest -D a -io -id -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/E_SCO_OG_${GENOME}.bed > genes_genes.U.${GENOME}.bed
    bedtools closest -D a -io -iu -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/E_SCO_OG_${GENOME}.bed > genes_genes.D.${GENOME}.bed
    ### parse the data
    echo "*** ${GENOME}: parsing data for all genes to all genes ***"
    > genes_genes.${GENOME}.DATA.txt
    cat genes_genes.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep -m 1 "${LINE}" genes_genes.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep -m 1 "${LINE}" genes_genes.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        echo -e "${gene}\t${us}\t${ds}" | awk '!/none/' >> genes_genes.${GENOME}.DATA.txt
    done
    
    ### Find the distance of ALL genes in GENOME to the nearest TE (any)
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all genes to all TEs ***"
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/E_SCO_OG_${GENOME}.bed > SORTED/E_SCO_OG_${GENOME}.bed
    cat /global/scratch/users/annen/visualize_TEs/*${GENOME}.bed | sort -k1,1 -k2,2n > SORTED/all_TEs.${GENOME}.bed
    bedtools closest -D a -id -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/all_TEs.${GENOME}.bed > genes_TEs.U.${GENOME}.bed
    bedtools closest -D a -iu -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/all_TEs.${GENOME}.bed > genes_TEs.D.${GENOME}.bed\
    ### parse the data
    echo "*** ${GENOME}: parsing data for all genes to all TEs ***"
    > genes_TEs.${GENOME}.DATA.txt
    cat genes_TEs.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep "${LINE}" genes_TEs.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep "${LINE}" genes_TEs.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        echo -e "${gene}\t${us}\t${ds}" | awk '!/none/' >> genes_TEs.${GENOME}.DATA.txt
    done

    ### Find the distance of ALL genes in GENOME to ALL effectors
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all genes to all effectors ***"
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/E_SCO_OG_${GENOME}.bed > SORTED/E_SCO_OG_${GENOME}.bed
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
    bedtools closest -D a -io -id -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/EFF_${GENOME}.sorted.bed > genes_eff.U.${GENOME}.bed
    bedtools closest -D a -io -iu -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/EFF_${GENOME}.sorted.bed > genes_eff.D.${GENOME}.bed
    ### parse the data
    echo "*** ${GENOME}: parsing data for all genes to all effectors ***"
    > genes_eff.${GENOME}.DATA.txt
    cat genes_eff.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep -m 1 "${LINE}" genes_eff.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep -m 1 "${LINE}" genes_eff.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        echo -e "${gene}\t${us}\t${ds}" | awk '!/none/' >> genes_eff.${GENOME}.DATA.txt
    done
    
    ### Find the distance of ALL effectors in GENOME to the nearest TE (any)
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all effectors to all TEs ***"
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
    cat /global/scratch/users/annen/visualize_TEs/*${GENOME}.bed | sort -k1,1 -k2,2n > SORTED/all_TEs.${GENOME}.bed
    bedtools closest -D a -id -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/all_TEs.${GENOME}.bed > eff_TEs.U.${GENOME}.bed
    bedtools closest -D a -iu -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/all_TEs.${GENOME}.bed > eff_TEs.D.${GENOME}.bed\
    ### parse the data
    echo "*** ${GENOME}: parsing data for all effectors to TEs ***"
    > eff_TEs.${GENOME}.DATA.txt
    cat eff_TEs.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep "${LINE}" eff_TEs.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep "${LINE}" eff_TEs.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        echo -e "${gene}\t${us}\t${ds}" | awk '!/none/' >> eff_TEs.${GENOME}.DATA.txt
    done

    ### Find the distance of effectors in GENOME to the nearest individual TE (the ones that had expansions in that genome)
    while read TE; do
        echo "*** ${GENOME}: all effectors to ${TE} ***"
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed > SORTED/${TE}.${GENOME}.sorted.bed
        bedtools closest -D a -id -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > eff_${TE}.U.${GENOME}.bed
        bedtools closest -D a -iu -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > eff_${TE}.D.${GENOME}.bed
        ### parse the data
        echo "*** ${GENOME}: parsing data for all effectors to ${TE} ***"
        > eff_${TE}.${GENOME}.DATA.txt
        cat eff_${TE}.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
            gene=$(echo ${LINE} | awk '{ print $4 }')
            us=$(grep "${LINE}" eff_${TE}.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
            ds=$(grep "${LINE}" eff_${TE}.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
            echo -e "${gene}\t${us}\t${ds}" | awk '!/none/' >> eff_${TE}.${GENOME}.DATA.txt
        done
        
    done < te_list.txt 
done < genome_list.txt


