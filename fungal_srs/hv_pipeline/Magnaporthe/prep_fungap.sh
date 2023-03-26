#!/bin/bash
#SBATCH --job-name=prep_fungap
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --mail-user=annen@berkeley.edu
#SBATCH --mail-type=ALL

cd /global/scratch/users/annen/000_FUNGAL_SRS_000/MoFunGAP/run_files

### download all RNA-Seq datasets
module load sra-tools

> sra_list.txt
echo "SRR8842990" >> sra_list.txt   # MoO (guy11) that I used
echo "ERR5875670" >> sra_list.txt   # MoO (guy11) that Pierre used
echo "SRR9126640" >> sra_list.txt   # MoT (B71)
echo "SRR8278105" >> sra_list.txt   # MoE (MZ5-1-6)

while read sra; do
    echo ${sra}
    fastq-dump -I --split-files ${sra}
    wc -l ${sra}_[12].fastq
done < sra_list.txt

rm sra_list.txt
