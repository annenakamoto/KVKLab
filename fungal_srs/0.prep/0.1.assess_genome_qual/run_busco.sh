#!/bin/bash

### Run BUSCO for a list of genomes (each in a separate job)

cd /global/scratch/users/annen

sbatch_A=${1}       # account for job submission
sbatch_qos=${2}     # qos for job submission
sbatch_p=${3}       # partition for job submission
sbatch_t=${4}       # qos for job submission
working_dir=${5}    # full path to working directory
genome_path=${6}    # path prefix for where the genomes are located
busco_list=${7}     # list of genome names to run busco for

while read genome_name; do 
    sbatch -A ${sbatch_A} --qos=${sbatch_qos} -p savio4_htc --ntasks-per-node=${sbatch_t} KVKLab/fungal_srs/0.prep/0.1.assess_genome_qual/busco_one.sh ${working_dir} ${genome_path} ${genome_name}
done < ${working_dir}/${busco_list}

### ZYMO ncbi: bash KVKLab/fungal_srs/0.prep/0.1.assess_genome_qual/run_busco.sh co_minium savio_lowprio savio2 24 /global/scratch/users/annen/000_FUNGAL_SRS_000/ZYMO/NCBI_genomes BUSCO busco_list.txt
