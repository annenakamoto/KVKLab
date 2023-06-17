#!/bin/bash
#SBATCH --job-name=busco_one
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

working_dir=${1}    # full path to working directory
genome_path=${2}    # path to genome from working directory, not including fna file name
genome_name=${3}    # isolate name or other identifier 

cd ${working_dir}

### run busco on a genome
module purge    # loaded modules interfere with busco
source activate /global/scratch/users/annen/anaconda3/envs/busco
busco -i ${genome_path}/${genome_name}.fna -o ${genome_name} -l sordariomycetes_odb10 -m genome -c ${SLURM_NTASKS} -f
conda deactivate
