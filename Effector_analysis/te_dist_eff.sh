#!/bin/bash
#SBATCH --job-name=TE_dist_eff
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find the 5' (upstream) and 3' (downstream) distances of TEs to effectors
### This makes the median make sense and will allow for permutation test
###     Gene bedfiles are:      visualize_OGs/E_SCO_OG_${GENOME}.bed
###     Effector bedfiles are:  visualize_OGs/EFF_${GENOME}.bed
###     TE bedfiles are:        visualize_TEs/${TE}.${GENOME}.bed
###     Output: gene    x-axis          y-axis
###     Output: gene    upstream(5')    downstream(3')

cd /global/scratch/users/annen/TE_dist_Eff

while read GENOME; do
### Find the distance of ALL TEs in GENOME to the nearest Effector
    echo "*** STARTING ${GENOME} ***"
    echo "*** ${GENOME}: all TEs to effectors ***"
    cat /global/scratch/users/annen/visualize_TEs/*${GENOME}.bed | sort -k1,1 -k2,2n > SORTED/all_TEs.${GENOME}.bed
    sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
    bedtools closest -D a -id -t first -a SORTED/all_TEs.${GENOME}.bed -b SORTED/EFF_${GENOME}.sorted.bed > TEs_eff.U.${GENOME}.bed
    bedtools closest -D a -iu -t first -a SORTED/all_TEs.${GENOME}.bed -b SORTED/EFF_${GENOME}.sorted.bed > TEs_eff.D.${GENOME}.bed
    ### parse the data
    echo "*** ${GENOME}: parsing data for all TEs to effectors ***"
    > TEs_eff.${GENOME}.DATA.txt
    cat TEs_eff.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
        gene=$(echo ${LINE} | awk '{ print $4 }')
        us=$(grep "${LINE}" TEs_eff.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
        ds=$(grep "${LINE}" TEs_eff.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
        sc=$(grep "${LINE}" ${TE}_eff.D.${GENOME}.bed | awk '{ print substr($13, 1, 4) }')
        echo -e "${gene}\t${us}\t${ds}\t${sc}" | awk '!/none/' >> TEs_eff.${GENOME}.DATA.txt
    done

    ### Find the distance of an individual TE (the ones that had expansions in that genome) in GENOME to the nearest Effector
    while read TE; do
        echo "*** ${GENOME}: all ${TE} to all effectors ***"
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed > SORTED/${TE}.${GENOME}.sorted.bed
        sort -k1,1 -k2,2n /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed > SORTED/EFF_${GENOME}.sorted.bed
        bedtools closest -D a -id -t first -a SORTED/${TE}.${GENOME}.sorted.bed -b SORTED/EFF_${GENOME}.sorted.bed > ${TE}_eff.U.${GENOME}.bed
        bedtools closest -D a -iu -t first -a SORTED/${TE}.${GENOME}.sorted.bed -b SORTED/EFF_${GENOME}.sorted.bed > ${TE}_eff.D.${GENOME}.bed
        ### parse the data
        echo "*** ${GENOME}: parsing data for all ${TE} to effectors ***"
        > ${TE}_eff.${GENOME}.DATA.txt
        cat ${TE}_eff.U.${GENOME}.bed | awk -v OFS='\t' '{ print $1, $2, $3, $4 }' | while read LINE; do
            gene=$(echo ${LINE} | awk '{ print $4 }')
            us=$(grep "${LINE}" ${TE}_eff.U.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print -$14 }')
            ds=$(grep "${LINE}" ${TE}_eff.D.${GENOME}.bed | awk '$14 == "-1" { print "none" } $14 != "-1" { print $14 }')
            sc=$(grep "${LINE}" ${TE}_eff.D.${GENOME}.bed | awk '{ print substr($13, 1, 4) }')
            echo -e "${gene}\t${us}\t${ds}\t${sc}" | awk '!/none/' >> ${TE}_eff.${GENOME}.DATA.txt
        done  
    done < te_list.txt 
done < genome_list.txt

