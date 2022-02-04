#!/bin/bash
#SBATCH --job-name=map_reads ## name of your job
#SBATCH --partition=savio2 ## partition to use
#SBATCH --qos=savio_normal ## dont worry about it
#SBATCH --account=ic_pmb200b ## dont worry about it
#SBATCH --nodes=1 ## number of nodes used
#SBATCH --ntasks-per-node=24 ## number of cpus in the node
#SBATCH --time=72:00:00 ## max time for job
#SBATCH --mail-user=${USER}@berkeley.edu ## email job completion
#SBATCH --mail-type=ALL
#SBATCH --output=/global/home/users/${USER}/slurm_stderr/slurm-%j.out
#SBATCH --error=/global/home/users/${USER}/slurm_stdout/slurm-%j.out

cd ${WORKING_DIR} ## add the directory where reads and genome are here

### argument 1 is the genome accession: B71 (SRR6232156) or MZ5-1-6 (SRR8258942)

ACCESSION=$1
REFERENCE_GENOME=guy11.fna

module load bwa

bwa index ${REFERENCE_GENOME} ## need genome to be indexed before mapping

### in order for bwa mem
# read group labels
# number of threads, should be same as ntasks in header
# reference
# read file one
# read file two
# output mapped reads file

bwa mem -R "@RG\tID:${ACCESSION}\tSM:${ACCESSION}" \
    -t 24 \
    ${REFERENCE_GENOME} \
    ${ACCESSION}_1.fastq \
    ${ACCESSION}_2.fastq \
    -o ${ACCESSION}.bam