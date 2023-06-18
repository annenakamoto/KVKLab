#!/bin/bash
#SBATCH --job-name=assm_zymo
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

### assemble the Zymo genome specified
### follows: https://github.com/afeurtey/WW_PopGen/blob/master/Data_prep/Assemble_array.sh

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/ZYMO/1000_assemble

sample=${1} # to name assembly
read_prefix=${2} # SRA accession

### get the fastq files from SRA
module purge
source activate /global/scratch/users/annen/anaconda3/envs/sra-tools
while [ ! -d "${read_prefix}" ]; do
    prefetch -p ${read_prefix}
done
fasterq-dump ${read_prefix}
conda deactivate

read1=${read_prefix}_1.fastq
read2=${read_prefix}_2.fastq

echo ${sample} ${read1} ${read2} ;
mkdir -p ${sample}

source activate /global/scratch/users/annen/anaconda3/envs/spades
spades.py  \
  --careful \
  --threads ${SLURM_NTASKS} \
  -1 ${read1} \
  -2 ${read2} \
  -o ${sample}
conda deactivate
