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
    ### Find the distance of ALL genes in GENOME to the nearest TE (any)
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all genes to all TEs ***"
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/E_SCO_OG_${GENOME}.bed > SORTED/E_SCO_OG_${GENOME}.bed
    cat /global/scratch/users/annen/visualize_TEs/*${GENOME}.bed | sort -k1,1 -k2,2n > SORTED/all_TEs.${GENOME}.bed
    bedtools closest -D a -id -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/all_TEs.${GENOME}.bed > genes_TEs.U.${GENOME}.bed
    bedtools closest -D a -iu -t first -a SORTED/E_SCO_OG_${GENOME}.bed -b SORTED/all_TEs.${GENOME}.bed > genes_TEs.D.${GENOME}.bed

    ### parse the data
    > genes_TEs.${GENOME}.DATA.txt
    cat genes_TEs.U.${GENOME}.bed | awk '{ print $4 }' | while read GENE; do
        us=$(grep ${GENE} genes_TEs.U.${GENOME}.bed | awk '{ print -$14 }')
        ds=$(grep ${GENE} genes_TEs.D.${GENOME}.bed | awk '{ print $14 }')
        echo -e "${GENE}\t${us}\t${ds}" >> genes_TEs.${GENOME}.DATA.txt
    done

    ### Find the distance of effectors in GENOME to the nearest individual TE (the ones that had expansions in that genome)
    while read TE; do
        echo "*** ${GENOME}: all effectors to ${TE} ***"
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed > SORTED/${TE}.${GENOME}.sorted.bed
        bedtools closest -D a -id -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > eff_${TE}.U.${GENOME}.bed
        bedtools closest -D a -iu -t first -a SORTED/EFF_${GENOME}.sorted.bed -b SORTED/${TE}.${GENOME}.sorted.bed > eff_${TE}.D.${GENOME}.bed
    
        ### parse the data
        > eff_${TE}.${GENOME}.DATA.txt
        cat eff_${TE}.U.${GENOME}.bed | awk '{ print $4 }' | while read GENE; do
            us=$(grep ${GENE} eff_${TE}.U.${GENOME}.bed | awk '{ print -$14 }')
            ds=$(grep ${GENE} eff_${TE}.D.${GENOME}.bed | awk '{ print $14 }')
            echo -e "${GENE}\t${us}\t${ds}" >> eff_${TE}.${GENOME}.DATA.txt
        
    done < te_list.txt 
done < genome_list.txt


