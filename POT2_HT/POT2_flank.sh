#!/bin/bash
#SBATCH --job-name=pot2_flank
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

###     Grab all flanking genes of POT2 copies in B71 and guy11 to find potentially transferred regions
###     Then I can manually look at those gene trees

cd /global/scratch/users/annen/POT2_flank

### Get POT2 coordinates + 50,000 bp flank on each side
bedtools slop -i POT2.guy11.bed -g guy11.len -b 50000 > guy11.POT2_flank.bed
bedtools slop -i POT2.B71.bed -g B71.len -b 50000 > B71.POT2_flank.bed

### Grab all genes in that region OG_guy11.bed
bedtools intersect

### 