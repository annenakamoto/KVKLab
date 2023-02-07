#!/bin/bash
#SBATCH --job-name=te_insertions
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### Find the number of TE insertions in effectors (SCO effectors vs other effectors)
###     SCO effectors: no presence absence variation
###     All other effectors: has presence absence variation
###         the number of SCO effectors vs all other effectors is comparable in all the genomes
###     effector bed files are at: /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed
###     TE bed files are at: /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed

cd /global/scratch/users/annen/TE_insert_eff

> DATA.eff_ins.txt
while read GENOME; do
    while read TE; do
        # find TEs inserted into effectors (counted as inserted if they overlap with the effector)
        bedtools intersect -a /global/scratch/users/annen/visualize_OGs/EFF_${GENOME}.bed -b /global/scratch/users/annen/visualize_TEs/${TE}.${GENOME}.bed -wo > eff_ins.${GENOME}.${TE}.bed
        # parse the results to count SCO effectors vs non-SCO effectors
        sco=$(grep -c "E_SCO" eff_ins.${GENOME}.${TE}.bed)
        non=$(grep -c "E_OG" eff_ins.${GENOME}.${TE}.bed)
        tot=$(grep -c "" eff_ins.${GENOME}.${TE}.bed)
        chk=$((${sco} + ${non}))
        if [ ${tot} != ${chk} ]; then
            echo "ERROR: total and sum of SCO effectors + non-SCO effectors not equal!"
        fi
        echo -e "${GENOME}\t${TE}\tSCO\t${sco}" >> DATA.eff_ins.txt
        echo -e "${GENOME}\t${TE}\tNON\t${non}" >> DATA.eff_ins.txt
    done < te_list.txt
done < genome_list.txt
