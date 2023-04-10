#!/bin/bash
#SBATCH --job-name=busco_Mo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=6:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoOrthoFinder/MoBUSCO

genome=${1}
mkdir -p ${genome}
cd ${genome}
### run busco on a genome
module purge    # loaded modules interfere with busco
source activate /global/scratch/users/annen/anaconda3/envs/busco
busco -i ../../MoASSEMBLIES/${genome}.fna -l sordariomycetes_odb10 -m genome -c ${SLURM_NTASKS} -f
conda deactivate

