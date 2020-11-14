#!/bin/bash
#SBATCH --job-name=guy11rep_keywords
#SBATCH --account=fc_kvkallow
#SBATCH --partition=savio2
#SBATCH --qos=savio_normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL
cd /global/scratch/users/annen/
export MODULEPATH=/clusterfs/vector/home/groups/software/sl-7.x86_64/modfiles:$MODULEPATH
module load biopython/1.7.0
python keywords.py > keywords.out
